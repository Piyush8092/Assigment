# Streak Tracker - Full Stack Application

A complete streak tracking application built with Flutter (Frontend) and Node.js (Backend). Track daily check-ins, maintain streaks, and visualize progress with an interactive calendar.

## 🚀 Project Overview

This project demonstrates a full-stack implementation of a productivity tracking app where users can:
- Check in daily to maintain their streak
- View streak statistics and achievements
- See their progress on an interactive calendar
- Get reminded to check in after 8 PM
- Track missed days and longest streaks

## 📁 Project Structure

```
streak_tracker/
├── streak_tracker_backend/     # Node.js Express API
│   ├── server.js              # Main server file
│   ├── package.json           # Dependencies and scripts
│   └── README.md              # Backend documentation
├── streak_tracker_frontend/    # Flutter application
│   ├── lib/                   # Flutter source code
│   ├── pubspec.yaml           # Flutter dependencies
│   └── README.md              # Frontend documentation
└── README.md                  # This file
```

## 🛠️ Technology Stack

### Backend
- **Node.js**: Runtime environment
- **Express.js**: Web framework
- **CORS**: Cross-origin resource sharing
- **In-memory storage**: No database required

### Frontend
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **HTTP**: API communication
- **Table Calendar**: Calendar widget
- **Material Design 3**: UI design system

## ⚡ Quick Start

### 1. Start the Backend Server

```bash
cd streak_tracker_backend
npm install
npm start
```

The server will start on `http://localhost:3000`

### 2. Run the Flutter App

```bash
cd streak_tracker_frontend
flutter pub get
flutter run -d chrome
```

The app will open in your default browser.

## 🎯 Features

### Backend API
- **POST /check-in**: Log daily check-in
- **GET /streak**: Get current streak data
- **GET /missed-days**: Get missed days in past 30 days
- **GET /calendar**: Get calendar visualization data
- **GET /health**: Health check endpoint

### Frontend App
- **Streak Display**: Current and longest streak with dynamic emojis
- **Daily Check-in**: Large, animated check-in button
- **Calendar View**: Interactive calendar with color-coded days
- **Smart Reminders**: Evening reminders after 8 PM
- **Real-time Sync**: Live connection to backend API
- **Error Handling**: Graceful handling of network issues

## 🧪 Testing

### Backend Testing
```bash
cd streak_tracker_backend

# Test health endpoint
curl -X GET http://localhost:3000/health

# Test streak endpoint
curl -X GET http://localhost:3000/streak

# Test check-in endpoint
curl -X POST http://localhost:3000/check-in -H "Content-Type: application/json"
```

### Frontend Testing
```bash
cd streak_tracker_frontend
flutter test
```

## 📱 Supported Platforms

The Flutter app supports:
- **Web**: Chrome, Firefox, Safari, Edge
- **Mobile**: iOS and Android
- **Desktop**: macOS, Windows, Linux

## 🎨 UI/UX Features

- **Material Design 3**: Modern, consistent design language
- **Gradient Cards**: Beautiful visual elements
- **Smooth Animations**: 60fps animations and transitions
- **Responsive Layout**: Adapts to different screen sizes
- **Dark/Light Theme**: Follows system preferences
- **Accessibility**: Screen reader support and proper contrast

## 🔧 Development

### Backend Development
- Hot reload with nodemon (optional)
- RESTful API design
- CORS enabled for development
- Comprehensive error handling

### Frontend Development
- Hot reload for instant updates
- Widget-based architecture
- State management with setState
- Modular component structure

## 📊 Streak Logic

1. **First Check-in**: Starts a 1-day streak
2. **Consecutive Days**: Increments streak counter
3. **Missed Days**: Resets current streak to 1 on next check-in
4. **Duplicate Prevention**: Only one check-in per day allowed
5. **Longest Streak**: Automatically tracked and updated

## 🌐 API Documentation

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/check-in` | Log today's check-in |
| GET | `/streak` | Get current streak info |
| GET | `/missed-days` | Get missed days (30 days) |
| GET | `/calendar` | Get calendar data |
| GET | `/health` | Health check |

### Response Examples

**GET /streak**
```json
{
  "currentStreak": 5,
  "longestStreak": 10,
  "lastCheckInDate": "2025-07-31",
  "totalCheckIns": 25,
  "canCheckInToday": false
}
```

**POST /check-in**
```json
{
  "success": true,
  "message": "Great! You've maintained your 5-day streak!",
  "currentStreak": 5,
  "longestStreak": 10,
  "lastCheckInDate": "2025-07-31"
}
```

## 🚨 Troubleshooting

### Common Issues

1. **Backend not starting**: Check if port 3000 is available
2. **Flutter app can't connect**: Ensure backend is running on localhost:3000
3. **CORS errors**: Backend includes CORS middleware for development
4. **Calendar not loading**: Check network connection and API responses

### Error Messages

- **"Cannot connect to server"**: Backend is not running
- **"Already checked in today"**: Duplicate check-in attempt
- **Connection timeout**: Network connectivity issues

## 📝 Assignment Requirements Fulfilled

✅ **Streak Home Page**: Current streak display with calendar view  
✅ **Daily Check-in Flow**: One-click check-in with duplicate prevention  
✅ **Reminder Prompt**: Evening reminder card after 8 PM  
✅ **Node.js Backend**: Express server with in-memory storage  
✅ **API Endpoints**: All required endpoints implemented  
✅ **Streak Logic**: Accurate streak calculation and missed day handling  
✅ **UI Quality**: Modern, responsive design with animations  
✅ **Integration**: Seamless frontend-backend communication  
✅ **Code Quality**: Modular, readable, and well-documented code  
✅ **UX Elements**: Reminder cards, validation, and error handling  

## 🎉 Demo

1. Start both backend and frontend
2. Open the app in your browser
3. Click "Check In Today" to start your streak
4. View your progress on the calendar
5. Try checking in again (should show "Already checked in")
6. Wait until after 8 PM to see the reminder card

## 📄 License

This project is created for educational purposes as part of a Flutter developer assignment.

## 🤝 Contributing

This is an assignment project, but feel free to explore the code and suggest improvements!

---

**Built with ❤️ using Flutter and Node.js**
