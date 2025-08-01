# Streak Tracker Flutter App

A beautiful Flutter application for tracking daily check-ins and maintaining streaks. Features a modern UI with calendar visualization, streak statistics, and reminder notifications.

## Features

### 🔥 Streak Tracking
- **Current Streak Display**: Shows your current consecutive days streak
- **Longest Streak**: Tracks and displays your best streak achievement
- **Total Check-ins**: Counts all your check-ins over time
- **Dynamic Emojis**: Visual feedback based on streak length (🌱 → 🔥 → ⚡ → 🚀 → 👑)

### 📅 Calendar View
- **Visual Calendar**: Interactive calendar showing check-in history
- **Color-coded Days**:
  - Green: Successful check-ins
  - Red: Missed days
  - Blue: Today
- **Statistics**: Check-in rate and missed days count
- **Legend**: Clear visual indicators for different day types

### ⏰ Smart Reminders
- **Evening Reminders**: Automatic reminder card after 8 PM if not checked in
- **Dismissible**: Can be dismissed or acted upon immediately
- **Animated**: Smooth slide-in animation for better UX

### 🎯 Daily Check-in
- **One-Click Check-in**: Large, prominent check-in button
- **Duplicate Prevention**: Prevents multiple check-ins per day
- **Visual Feedback**: Button state changes based on check-in status
- **Animated Interactions**: Press animations for better feedback

### 🌐 Real-time Sync
- **API Integration**: Connects to Node.js backend
- **Connection Status**: Visual indicator of server connectivity
- **Error Handling**: Graceful handling of network issues
- **Pull-to-Refresh**: Swipe down to refresh data

## Screenshots

The app features a modern Material Design 3 interface with:
- Gradient cards for visual appeal
- Smooth animations and transitions
- Responsive layout for different screen sizes
- Intuitive navigation and interactions

## Installation & Setup

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- A running Streak Tracker backend server

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App

**For Web (Chrome):**
```bash
flutter run -d chrome
```

**For Mobile (iOS/Android):**
```bash
flutter run
```

**For Desktop:**
```bash
flutter run -d macos    # macOS
flutter run -d windows  # Windows
flutter run -d linux    # Linux
```

### 3. Backend Connection
Make sure the backend server is running on `http://localhost:3000` before using the app.

## Dependencies

### Core Dependencies
- **http**: HTTP client for API communication
- **intl**: Internationalization and date formatting
- **table_calendar**: Interactive calendar widget

### Dev Dependencies
- **flutter_test**: Testing framework
- **flutter_lints**: Linting rules for code quality

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/
│   └── streak_home_screen.dart   # Main screen
├── widgets/
│   ├── streak_card.dart          # Streak statistics display
│   ├── check_in_button.dart      # Daily check-in button
│   ├── reminder_card.dart        # Evening reminder
│   └── calendar_view.dart        # Calendar visualization
└── services/
    └── api_service.dart          # Backend API communication
```

## API Integration

The app communicates with the backend through the `ApiService` class:

- **Health Check**: Monitors server connectivity
- **Streak Data**: Fetches current streak information
- **Check-in**: Submits daily check-ins
- **Calendar Data**: Gets historical data for calendar
- **Missed Days**: Retrieves missed days information

## Testing

Run the test suite:
```bash
flutter test
```

## Notes

- The app requires an active internet connection to sync with the backend
- Data is persisted on the server, not locally
- Calendar view shows the last 30 days of activity
- Reminder notifications are simulated (not actual system notifications)
