import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const Duration timeout = Duration(seconds: 10);
  static const int maxRetries = 3;

  // Dynamic base URL based on platform
  static String get baseUrl {
    if (kIsWeb) {
      // For web, use localhost
      return 'http://localhost:3000';
    } else if (Platform.isAndroid) {
      // For Android emulator, try multiple possible addresses
      return 'http://10.0.2.2:3000';
    } else if (Platform.isIOS) {
      // For iOS simulator, use localhost
      return 'http://localhost:3000';
    } else {
      // For desktop platforms, use localhost
      return 'http://localhost:3000';
    }
  }

  // Alternative URLs to try if the primary fails
  static List<String> get fallbackUrls {
    if (Platform.isAndroid) {
      return [
        'http://10.0.2.2:3000',  // Standard Android emulator
        'http://192.168.1.100:3000',  // Common local network IP
        'http://127.0.0.1:3000',  // Localhost
        'http://localhost:3000',  // Localhost alternative
      ];
    }
    return ['http://localhost:3000'];
  }

  // Enhanced error handling and retry mechanism with fallback URLs
  static Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    int retryCount = 0,
    int urlIndex = 0,
  }) async {
    final urlsToTry = [baseUrl, ...fallbackUrls];
    final currentUrl = urlIndex < urlsToTry.length ? urlsToTry[urlIndex] : baseUrl;

    try {
      final uri = Uri.parse('$currentUrl$endpoint');
      final headers = {'Content-Type': 'application/json'};

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(timeout);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success! Store this URL as working for future requests
        if (kDebugMode) {
          print('✅ API Success: $currentUrl$endpoint');
        }
        return json.decode(response.body);
      } else {
        // Handle HTTP errors
        try {
          final errorBody = json.decode(response.body);
          return {
            'success': false,
            'message': errorBody['message'] ?? 'Server error (${response.statusCode})',
            'statusCode': response.statusCode,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error (${response.statusCode})',
            'statusCode': response.statusCode,
          };
        }
      }
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('❌ Connection failed: $currentUrl$endpoint - ${e.message}');
      }
      return _handleConnectionError(method, endpoint, body: body, retryCount: retryCount, urlIndex: urlIndex);
    } on HttpException catch (e) {
      if (kDebugMode) {
        print('❌ HTTP error: $currentUrl$endpoint - ${e.message}');
      }
      return _handleConnectionError(method, endpoint, body: body, retryCount: retryCount, urlIndex: urlIndex);
    } on FormatException {
      return {
        'success': false,
        'message': 'Invalid response format from server',
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Request error: $currentUrl$endpoint - ${e.toString()}');
      }

      // Try next URL if available
      if (urlIndex + 1 < urlsToTry.length) {
        return _makeRequest(method, endpoint, body: body, retryCount: retryCount, urlIndex: urlIndex + 1);
      }

      // Try retry with same URL
      if (retryCount < maxRetries) {
        await Future.delayed(Duration(seconds: retryCount + 1));
        return _makeRequest(method, endpoint, body: body, retryCount: retryCount + 1, urlIndex: 0);
      }

      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> _handleConnectionError(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    int retryCount = 0,
    int urlIndex = 0,
  }) async {
    final urlsToTry = [baseUrl, ...fallbackUrls];

    // Try next URL if available
    if (urlIndex + 1 < urlsToTry.length) {
      if (kDebugMode) {
        print('🔄 Trying next URL: ${urlsToTry[urlIndex + 1]}');
      }
      return _makeRequest(method, endpoint, body: body, retryCount: retryCount, urlIndex: urlIndex + 1);
    }

    // All URLs failed, try retry with first URL
    if (retryCount < maxRetries) {
      if (kDebugMode) {
        print('🔄 Retrying attempt ${retryCount + 1}/$maxRetries');
      }
      await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
      return _makeRequest(method, endpoint, body: body, retryCount: retryCount + 1, urlIndex: 0);
    }

    return {
      'success': false,
      'message': 'Cannot connect to server. Please check your connection and ensure the backend is running on port 3000.',
      'isConnectionError': true,
      'triedUrls': urlsToTry,
    };
  }

  // Check in for today with enhanced error handling
  static Future<Map<String, dynamic>> checkIn() async {
    final result = await _makeRequest('POST', '/check-in');

    // Add client-side validation
    if (result['success'] == true) {
      final currentStreak = result['currentStreak'];
      final longestStreak = result['longestStreak'];

      if (currentStreak != null && longestStreak != null) {
        if (currentStreak < 0 || longestStreak < 0) {
          return {
            'success': false,
            'message': 'Invalid streak data received from server',
          };
        }

        if (currentStreak > longestStreak) {
          return {
            'success': false,
            'message': 'Data inconsistency: current streak cannot exceed longest streak',
          };
        }
      }
    }

    return result;
  }
  
  // Get current streak information with validation
  static Future<Map<String, dynamic>> getStreak() async {
    final result = await _makeRequest('GET', '/streak');

    if (result['success'] == false) {
      return {
        'currentStreak': 0,
        'longestStreak': 0,
        'lastCheckInDate': null,
        'totalCheckIns': 0,
        'canCheckInToday': true,
        'error': result['message'],
      };
    }

    // Validate data integrity
    final currentStreak = result['currentStreak'] ?? 0;
    final longestStreak = result['longestStreak'] ?? 0;
    final totalCheckIns = result['totalCheckIns'] ?? 0;

    return {
      'currentStreak': currentStreak.clamp(0, double.infinity).toInt(),
      'longestStreak': longestStreak.clamp(0, double.infinity).toInt(),
      'lastCheckInDate': result['lastCheckInDate'],
      'totalCheckIns': totalCheckIns.clamp(0, double.infinity).toInt(),
      'canCheckInToday': result['canCheckInToday'] ?? true,
      'isNewRecord': result['isNewRecord'] ?? false,
    };
  }

  // Get missed days with validation
  static Future<Map<String, dynamic>> getMissedDays() async {
    final result = await _makeRequest('GET', '/missed-days');

    if (result['success'] == false) {
      return {
        'missedDays': <String>[],
        'totalMissedDays': 0,
        'dateRange': {
          'from': DateTime.now().subtract(const Duration(days: 30)).toIso8601String().split('T')[0],
          'to': DateTime.now().toIso8601String().split('T')[0]
        },
        'error': result['message'],
      };
    }

    // Validate and clean missed days data
    final missedDays = (result['missedDays'] as List?)?.cast<String>() ?? <String>[];
    final validMissedDays = missedDays.where((date) => _isValidDateString(date)).toList();

    return {
      'missedDays': validMissedDays,
      'totalMissedDays': validMissedDays.length,
      'dateRange': result['dateRange'] ?? {
        'from': DateTime.now().subtract(const Duration(days: 30)).toIso8601String().split('T')[0],
        'to': DateTime.now().toIso8601String().split('T')[0]
      },
    };
  }

  // Get calendar data with validation
  static Future<Map<String, dynamic>> getCalendarData() async {
    final result = await _makeRequest('GET', '/calendar');

    if (result['success'] == false) {
      return {
        'checkInDates': <String>[],
        'missedDays': <String>[],
        'currentStreak': 0,
        'error': result['message'],
      };
    }

    // Validate and clean calendar data
    final checkInDates = (result['checkInDates'] as List?)?.cast<String>() ?? <String>[];
    final missedDays = (result['missedDays'] as List?)?.cast<String>() ?? <String>[];

    final validCheckInDates = checkInDates.where((date) => _isValidDateString(date)).toList();
    final validMissedDays = missedDays.where((date) => _isValidDateString(date)).toList();

    return {
      'checkInDates': validCheckInDates,
      'missedDays': validMissedDays,
      'currentStreak': (result['currentStreak'] ?? 0).clamp(0, double.infinity).toInt(),
    };
  }

  // Enhanced health check with detailed status
  static Future<Map<String, dynamic>> getServerStatus() async {
    final result = await _makeRequest('GET', '/health');

    if (result['success'] == false) {
      return {
        'isHealthy': false,
        'message': result['message'],
        'isConnectionError': result['isConnectionError'] ?? false,
      };
    }

    return {
      'isHealthy': true,
      'message': 'Server is running normally',
      'timestamp': result['timestamp'],
    };
  }

  // Legacy method for backward compatibility
  static Future<bool> isServerHealthy() async {
    final status = await getServerStatus();
    return status['isHealthy'] ?? false;
  }

  // Helper method to validate date strings
  static bool _isValidDateString(String dateString) {
    try {
      final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      if (!regex.hasMatch(dateString)) return false;

      final date = DateTime.parse(dateString);
      return date.year >= 2020 && date.year <= DateTime.now().year + 1;
    } catch (e) {
      return false;
    }
  }

  // Test connectivity to all possible server URLs
  static Future<Map<String, dynamic>> testConnectivity() async {
    final urlsToTry = [baseUrl, ...fallbackUrls];
    final results = <String, dynamic>{};

    for (int i = 0; i < urlsToTry.length; i++) {
      final url = urlsToTry[i];
      try {
        final uri = Uri.parse('$url/health');
        final response = await http.get(uri).timeout(const Duration(seconds: 5));

        results[url] = {
          'success': response.statusCode == 200,
          'statusCode': response.statusCode,
          'responseTime': DateTime.now().millisecondsSinceEpoch,
        };

        if (response.statusCode == 200) {
          if (kDebugMode) {
            print('✅ Server reachable at: $url');
          }
          break; // Found working server
        }
      } catch (e) {
        results[url] = {
          'success': false,
          'error': e.toString(),
        };
        if (kDebugMode) {
          print('❌ Server unreachable at: $url - $e');
        }
      }
    }

    return {
      'results': results,
      'hasWorkingConnection': results.values.any((result) => result['success'] == true),
    };
  }

  // Batch request for initial data loading
  static Future<Map<String, dynamic>> getInitialData() async {
    try {
      // First test connectivity
      if (kDebugMode) {
        final connectivity = await testConnectivity();
        print('🔍 Connectivity test: ${connectivity['hasWorkingConnection'] ? 'PASS' : 'FAIL'}');
      }

      final results = await Future.wait([
        getStreak(),
        getCalendarData(),
        getServerStatus(),
      ]);

      return {
        'streak': results[0],
        'calendar': results[1],
        'serverStatus': results[2],
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Initial data loading failed: $e');
      }
      return {
        'streak': {'currentStreak': 0, 'longestStreak': 0, 'error': 'Failed to load data'},
        'calendar': {'checkInDates': [], 'missedDays': [], 'error': 'Failed to load data'},
        'serverStatus': {'isHealthy': false, 'message': 'Failed to check server status'},
      };
    }
  }
}
