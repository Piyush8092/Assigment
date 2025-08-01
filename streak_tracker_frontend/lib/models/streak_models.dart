/// Data models for the Streak Tracker application

/// Represents the current streak data and statistics
class StreakData {
  final int currentStreak;
  final int longestStreak;
  final String? lastCheckInDate;
  final int totalCheckIns;
  final bool canCheckInToday;
  final bool isNewRecord;
  final String? error;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastCheckInDate,
    required this.totalCheckIns,
    required this.canCheckInToday,
    this.isNewRecord = false,
    this.error,
  });

  /// Creates a StreakData instance from a JSON map
  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: (json['currentStreak'] ?? 0).toInt(),
      longestStreak: (json['longestStreak'] ?? 0).toInt(),
      lastCheckInDate: json['lastCheckInDate'],
      totalCheckIns: (json['totalCheckIns'] ?? 0).toInt(),
      canCheckInToday: json['canCheckInToday'] ?? true,
      isNewRecord: json['isNewRecord'] ?? false,
      error: json['error'],
    );
  }

  /// Converts the StreakData to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCheckInDate': lastCheckInDate,
      'totalCheckIns': totalCheckIns,
      'canCheckInToday': canCheckInToday,
      'isNewRecord': isNewRecord,
      'error': error,
    };
  }

  /// Creates a copy of this StreakData with some fields replaced
  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    String? lastCheckInDate,
    int? totalCheckIns,
    bool? canCheckInToday,
    bool? isNewRecord,
    String? error,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      canCheckInToday: canCheckInToday ?? this.canCheckInToday,
      isNewRecord: isNewRecord ?? this.isNewRecord,
      error: error ?? this.error,
    );
  }

  /// Returns true if this streak data has an error
  bool get hasError => error != null;

  /// Returns true if the streak data is valid
  bool get isValid => !hasError && currentStreak >= 0 && longestStreak >= 0;

  @override
  String toString() {
    return 'StreakData(currentStreak: $currentStreak, longestStreak: $longestStreak, '
           'lastCheckInDate: $lastCheckInDate, totalCheckIns: $totalCheckIns, '
           'canCheckInToday: $canCheckInToday, isNewRecord: $isNewRecord, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StreakData &&
        other.currentStreak == currentStreak &&
        other.longestStreak == longestStreak &&
        other.lastCheckInDate == lastCheckInDate &&
        other.totalCheckIns == totalCheckIns &&
        other.canCheckInToday == canCheckInToday &&
        other.isNewRecord == isNewRecord &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentStreak,
      longestStreak,
      lastCheckInDate,
      totalCheckIns,
      canCheckInToday,
      isNewRecord,
      error,
    );
  }
}

/// Represents calendar data for visualization
class CalendarData {
  final List<String> checkInDates;
  final List<String> missedDays;
  final int currentStreak;
  final String? error;

  const CalendarData({
    required this.checkInDates,
    required this.missedDays,
    required this.currentStreak,
    this.error,
  });

  /// Creates a CalendarData instance from a JSON map
  factory CalendarData.fromJson(Map<String, dynamic> json) {
    return CalendarData(
      checkInDates: (json['checkInDates'] as List?)?.cast<String>() ?? [],
      missedDays: (json['missedDays'] as List?)?.cast<String>() ?? [],
      currentStreak: (json['currentStreak'] ?? 0).toInt(),
      error: json['error'],
    );
  }

  /// Converts the CalendarData to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'checkInDates': checkInDates,
      'missedDays': missedDays,
      'currentStreak': currentStreak,
      'error': error,
    };
  }

  /// Creates a copy of this CalendarData with some fields replaced
  CalendarData copyWith({
    List<String>? checkInDates,
    List<String>? missedDays,
    int? currentStreak,
    String? error,
  }) {
    return CalendarData(
      checkInDates: checkInDates ?? this.checkInDates,
      missedDays: missedDays ?? this.missedDays,
      currentStreak: currentStreak ?? this.currentStreak,
      error: error ?? this.error,
    );
  }

  /// Returns true if this calendar data has an error
  bool get hasError => error != null;

  /// Returns the total number of active days
  int get totalActiveDays => checkInDates.length;

  /// Returns the total number of missed days
  int get totalMissedDays => missedDays.length;

  /// Returns the check-in rate as a percentage
  double get checkInRate {
    final totalDays = totalActiveDays + totalMissedDays;
    if (totalDays == 0) return 0.0;
    return (totalActiveDays / totalDays) * 100;
  }

  @override
  String toString() {
    return 'CalendarData(checkInDates: ${checkInDates.length} dates, '
           'missedDays: ${missedDays.length} dates, currentStreak: $currentStreak, error: $error)';
  }
}

/// Represents the server status and health information
class ServerStatus {
  final bool isHealthy;
  final String message;
  final bool isConnectionError;
  final String? timestamp;

  const ServerStatus({
    required this.isHealthy,
    required this.message,
    this.isConnectionError = false,
    this.timestamp,
  });

  /// Creates a ServerStatus instance from a JSON map
  factory ServerStatus.fromJson(Map<String, dynamic> json) {
    return ServerStatus(
      isHealthy: json['isHealthy'] ?? false,
      message: json['message'] ?? 'Unknown status',
      isConnectionError: json['isConnectionError'] ?? false,
      timestamp: json['timestamp'],
    );
  }

  /// Converts the ServerStatus to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'isHealthy': isHealthy,
      'message': message,
      'isConnectionError': isConnectionError,
      'timestamp': timestamp,
    };
  }

  /// Creates a copy of this ServerStatus with some fields replaced
  ServerStatus copyWith({
    bool? isHealthy,
    String? message,
    bool? isConnectionError,
    String? timestamp,
  }) {
    return ServerStatus(
      isHealthy: isHealthy ?? this.isHealthy,
      message: message ?? this.message,
      isConnectionError: isConnectionError ?? this.isConnectionError,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'ServerStatus(isHealthy: $isHealthy, message: $message, '
           'isConnectionError: $isConnectionError, timestamp: $timestamp)';
  }
}

/// Represents the result of a check-in operation
class CheckInResult {
  final bool success;
  final String message;
  final StreakData? streakData;
  final bool isNewRecord;

  const CheckInResult({
    required this.success,
    required this.message,
    this.streakData,
    this.isNewRecord = false,
  });

  /// Creates a CheckInResult instance from a JSON map
  factory CheckInResult.fromJson(Map<String, dynamic> json) {
    return CheckInResult(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown result',
      streakData: json['success'] == true ? StreakData.fromJson(json) : null,
      isNewRecord: json['isNewRecord'] ?? false,
    );
  }

  /// Converts the CheckInResult to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'isNewRecord': isNewRecord,
      if (streakData != null) ...streakData!.toJson(),
    };
  }

  @override
  String toString() {
    return 'CheckInResult(success: $success, message: $message, '
           'isNewRecord: $isNewRecord, streakData: $streakData)';
  }
}

/// Represents the application state
class AppState {
  final StreakData streakData;
  final CalendarData calendarData;
  final ServerStatus serverStatus;
  final bool isLoading;
  final String? errorMessage;

  const AppState({
    required this.streakData,
    required this.calendarData,
    required this.serverStatus,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Creates an AppState with default values
  factory AppState.initial() {
    return AppState(
      streakData: const StreakData(
        currentStreak: 0,
        longestStreak: 0,
        totalCheckIns: 0,
        canCheckInToday: true,
      ),
      calendarData: const CalendarData(
        checkInDates: [],
        missedDays: [],
        currentStreak: 0,
      ),
      serverStatus: const ServerStatus(
        isHealthy: false,
        message: 'Checking server status...',
      ),
      isLoading: true,
    );
  }

  /// Creates a copy of this AppState with some fields replaced
  AppState copyWith({
    StreakData? streakData,
    CalendarData? calendarData,
    ServerStatus? serverStatus,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AppState(
      streakData: streakData ?? this.streakData,
      calendarData: calendarData ?? this.calendarData,
      serverStatus: serverStatus ?? this.serverStatus,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Returns true if the app has any errors
  bool get hasError => errorMessage != null || streakData.hasError || calendarData.hasError;

  /// Returns true if the server is connected and healthy
  bool get isServerConnected => serverStatus.isHealthy;

  @override
  String toString() {
    return 'AppState(isLoading: $isLoading, isServerConnected: $isServerConnected, '
           'hasError: $hasError, errorMessage: $errorMessage)';
  }
}
