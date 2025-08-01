import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/streak_card.dart';
import '../widgets/check_in_button.dart';
import '../widgets/reminder_card.dart';
import '../widgets/calendar_view.dart';

class StreakHomeScreen extends StatefulWidget {
  const StreakHomeScreen({super.key});

  @override
  State<StreakHomeScreen> createState() => _StreakHomeScreenState();
}

class _StreakHomeScreenState extends State<StreakHomeScreen> {
  Map<String, dynamic> streakData = {};
  Map<String, dynamic> calendarData = {};
  bool isLoading = true;
  bool isServerConnected = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Use the enhanced batch loading method
      final initialData = await ApiService.getInitialData();

      final serverStatus = initialData['serverStatus'];
      isServerConnected = serverStatus['isHealthy'] ?? false;

      if (!isServerConnected) {
        setState(() {
          errorMessage = serverStatus['message'] ?? 'Cannot connect to server';
          isLoading = false;
        });
        return;
      }

      // Extract data with error handling
      final streakResult = initialData['streak'];
      final calendarResult = initialData['calendar'];

      // Check for individual errors
      if (streakResult['error'] != null || calendarResult['error'] != null) {
        setState(() {
          errorMessage = streakResult['error'] ?? calendarResult['error'] ?? 'Failed to load data';
          isLoading = false;
        });
        return;
      }

      setState(() {
        streakData = streakResult;
        calendarData = calendarResult;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Unexpected error: ${e.toString()}';
        isLoading = false;
        isServerConnected = false;
      });
    }
  }

  Future<void> _handleCheckIn() async {
    if (!isServerConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot connect to server'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final result = await ApiService.checkIn();

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Check-in successful!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadData(); // Refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Check-in failed'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  bool _shouldShowReminder() {
    final now = DateTime.now();
    final canCheckIn = streakData['canCheckInToday'] ?? true;

    // Show reminder after 8 PM if not checked in today
    return now.hour >= 20 && canCheckIn;
  }

  bool _isUrgentReminder() {
    final now = DateTime.now();
    // Consider it urgent after 11 PM
    return now.hour >= 23;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(
              isServerConnected ? Icons.cloud_done : Icons.cloud_off,
              color: isServerConnected ? Colors.green : Colors.red,
            ),
            onPressed: _loadData,
            tooltip: isServerConnected ? 'Connected' : 'Disconnected - Tap to retry',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? _buildErrorView()
                : _buildMainContent(),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Troubleshooting:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Ensure backend server is running'),
                    const Text('2. Backend should be on port 3000'),
                    const Text('3. For Android emulator: http://10.0.2.2:3000'),
                    const Text('4. For iOS simulator: http://localhost:3000'),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Test connectivity
                        final result = await ApiService.testConnectivity();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['hasWorkingConnection']
                                  ? 'Connection test: SUCCESS ✅'
                                  : 'Connection test: FAILED ❌'
                              ),
                              backgroundColor: result['hasWorkingConnection']
                                ? Colors.green
                                : Colors.red,
                            ),
                          );
                          if (result['hasWorkingConnection']) {
                            _loadData();
                          }
                        }
                      },
                      icon: const Icon(Icons.network_check),
                      label: const Text('Test Connection'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reminder card (shown after 8 PM if not checked in)
          if (_shouldShowReminder()) ...[
            ReminderCard(
              onCheckIn: _handleCheckIn,
              currentStreak: streakData['currentStreak'] ?? 0,
              isUrgent: _isUrgentReminder(),
            ),
            const SizedBox(height: 16),
          ],
          
          // Main streak card
          StreakCard(
            currentStreak: streakData['currentStreak'] ?? 0,
            longestStreak: streakData['longestStreak'] ?? 0,
            lastCheckInDate: streakData['lastCheckInDate'],
            totalCheckIns: streakData['totalCheckIns'] ?? 0,
            isNewRecord: streakData['isNewRecord'] ?? false,
          ),
          
          const SizedBox(height: 24),
          
          // Check-in button
          CheckInButton(
            canCheckIn: streakData['canCheckInToday'] ?? true,
            onCheckIn: _handleCheckIn,
          ),
          
          const SizedBox(height: 24),
          
          // Calendar view
          CalendarView(
            checkInDates: List<String>.from(calendarData['checkInDates'] ?? []),
            missedDays: List<String>.from(calendarData['missedDays'] ?? []),
          ),
        ],
      ),
    );
  }
}
