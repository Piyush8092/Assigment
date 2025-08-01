/// Application-wide constants and configuration values
class AppConstants {
  // API Configuration
  // Use 10.0.2.2 for Android emulator to access host machine's localhost
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const Duration apiTimeout = Duration(seconds: 10);
  static const int maxRetries = 3;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration pulseAnimation = Duration(seconds: 2);
  
  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Streak Thresholds
  static const int beginnerStreakThreshold = 3;
  static const int intermediateStreakThreshold = 7;
  static const int advancedStreakThreshold = 30;
  static const int expertStreakThreshold = 100;
  
  // Time Constants
  static const int reminderHour = 20; // 8 PM
  static const int missedDaysLookback = 30;
  
  // Error Messages
  static const String connectionErrorMessage = 'Cannot connect to server. Please check your connection.';
  static const String serverErrorMessage = 'Server error occurred. Please try again.';
  static const String dataErrorMessage = 'Invalid data received. Please refresh.';
  static const String unknownErrorMessage = 'An unexpected error occurred.';
  
  // Success Messages
  static const String checkInSuccessMessage = 'Great! Check-in successful!';
  static const String newRecordMessage = 'NEW RECORD! Amazing achievement!';
  
  // Streak Emojis and Messages
  static const Map<String, String> streakEmojis = {
    'sleeping': '😴',
    'seedling': '🌱',
    'fire': '🔥',
    'lightning': '⚡',
    'rocket': '🚀',
    'crown': '👑',
  };
  
  static const Map<String, String> streakMessages = {
    'first': "Great start! You've begun your streak journey! 🌱",
    'beginner': "Awesome! You're building momentum! Keep it up! 🔥",
    'intermediate': "Amazing! You're on fire! Don't stop now! ⚡",
    'advanced': "Incredible! You're unstoppable! 🚀",
    'expert': "LEGENDARY! You're a streak master! 👑",
  };
  
  // Validation Rules
  static const int minYear = 2020;
  static const int maxFutureYears = 1;
  
  // Feature Flags
  static const bool enableAnimations = true;
  static const bool enableHapticFeedback = true;
  static const bool enableNotifications = true;
  
  // Accessibility
  static const double minTouchTargetSize = 44.0;
  static const double accessibleFontScale = 1.2;
  
  // Colors (as hex values for consistency)
  static const int primaryColorValue = 0xFF673AB7; // Deep Purple
  static const int successColorValue = 0xFF4CAF50; // Green
  static const int warningColorValue = 0xFFFF9800; // Orange
  static const int errorColorValue = 0xFFF44336; // Red
  static const int infoColorValue = 0xFF2196F3; // Blue
}

/// Utility class for responsive design helpers
class ResponsiveUtils {
  static bool isMobile(double width) => width < AppConstants.mobileBreakpoint;
  static bool isTablet(double width) => width >= AppConstants.mobileBreakpoint && width < AppConstants.tabletBreakpoint;
  static bool isDesktop(double width) => width >= AppConstants.desktopBreakpoint;
  
  static double getResponsivePadding(double width) {
    if (isMobile(width)) return AppConstants.defaultPadding;
    if (isTablet(width)) return AppConstants.defaultPadding * 1.5;
    return AppConstants.defaultPadding * 2;
  }
  
  static double getResponsiveFontSize(double width, double baseFontSize) {
    if (isMobile(width)) return baseFontSize * 0.9;
    if (isTablet(width)) return baseFontSize;
    return baseFontSize * 1.1;
  }
}

/// Utility class for streak-related calculations and messages
class StreakUtils {
  static String getStreakEmoji(int streak) {
    if (streak == 0) return AppConstants.streakEmojis['sleeping']!;
    if (streak < AppConstants.beginnerStreakThreshold) return AppConstants.streakEmojis['seedling']!;
    if (streak < AppConstants.intermediateStreakThreshold) return AppConstants.streakEmojis['fire']!;
    if (streak < AppConstants.advancedStreakThreshold) return AppConstants.streakEmojis['lightning']!;
    if (streak < AppConstants.expertStreakThreshold) return AppConstants.streakEmojis['rocket']!;
    return AppConstants.streakEmojis['crown']!;
  }
  
  static String getStreakMessage(int streak) {
    if (streak == 1) return AppConstants.streakMessages['first']!;
    if (streak < AppConstants.intermediateStreakThreshold) return AppConstants.streakMessages['beginner']!;
    if (streak < AppConstants.advancedStreakThreshold) return AppConstants.streakMessages['intermediate']!;
    if (streak < AppConstants.expertStreakThreshold) return AppConstants.streakMessages['advanced']!;
    return AppConstants.streakMessages['expert']!;
  }
  
  static String getStreakLevel(int streak) {
    if (streak == 0) return 'Inactive';
    if (streak < AppConstants.beginnerStreakThreshold) return 'Beginner';
    if (streak < AppConstants.intermediateStreakThreshold) return 'Building';
    if (streak < AppConstants.advancedStreakThreshold) return 'Strong';
    if (streak < AppConstants.expertStreakThreshold) return 'Expert';
    return 'Legendary';
  }
}

/// Utility class for date operations
class DateUtils {
  static String formatDate(String? dateString) {
    if (dateString == null) return 'Never';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;
      
      if (difference == 0) return 'Today';
      if (difference == 1) return 'Yesterday';
      if (difference < 7) return '$difference days ago';
      
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
  
  static bool isToday(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      return date.year == now.year && date.month == now.month && date.day == now.day;
    } catch (e) {
      return false;
    }
  }
  
  static bool isValidDateString(String dateString) {
    try {
      final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      if (!regex.hasMatch(dateString)) return false;
      
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      return date.year >= AppConstants.minYear && 
             date.year <= now.year + AppConstants.maxFutureYears;
    } catch (e) {
      return false;
    }
  }
}
