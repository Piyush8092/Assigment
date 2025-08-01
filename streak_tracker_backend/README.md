# Streak Tracker Backend

A Node.js Express server that provides API endpoints for tracking daily check-ins and maintaining streak data.

## Features

- **Daily Check-ins**: Users can check in once per day
- **Streak Tracking**: Automatically calculates current and longest streaks
- **Missed Days Detection**: Tracks missed days and resets streaks accordingly
- **Calendar Data**: Provides data for calendar visualization
- **In-Memory Storage**: Uses in-memory storage (no database required)

## API Endpoints

### POST /check-in
Logs today's check-in and updates streak data.

**Response:**
```json
{
  "success": true,
  "message": "Great! You've maintained your 5-day streak!",
  "currentStreak": 5,
  "longestStreak": 10,
  "lastCheckInDate": "2025-07-31"
}
```

### GET /streak
Returns current streak information.

**Response:**
```json
{
  "currentStreak": 5,
  "longestStreak": 10,
  "lastCheckInDate": "2025-07-31",
  "totalCheckIns": 25,
  "canCheckInToday": false
}
```

### GET /missed-days
Lists all missed days in the past 30 days.

**Response:**
```json
{
  "missedDays": ["2025-07-29", "2025-07-27"],
  "totalMissedDays": 2,
  "dateRange": {
    "from": "2025-07-01",
    "to": "2025-07-31"
  }
}
```

### GET /calendar
Returns calendar data for frontend visualization.

**Response:**
```json
{
  "checkInDates": ["2025-07-31", "2025-07-30"],
  "missedDays": ["2025-07-29"],
  "currentStreak": 2
}
```

### GET /health
Health check endpoint.

**Response:**
```json
{
  "status": "OK",
  "timestamp": "2025-07-31T09:17:16.473Z"
}
```

## Installation & Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Start the server:**
   ```bash
   npm start
   ```

3. **Development mode:**
   ```bash
   npm run dev
   ```

The server will start on port 3000 by default. You can access the API at `http://localhost:3000`.

## Dependencies

- **express**: Web framework for Node.js
- **cors**: Enable Cross-Origin Resource Sharing

## Streak Logic

- **New Streak**: First check-in starts a 1-day streak
- **Consecutive Days**: Checking in on consecutive days increments the streak
- **Missed Days**: Missing a day resets the current streak to 1 (on next check-in)
- **Duplicate Check-ins**: Prevented - only one check-in per day allowed
- **Longest Streak**: Automatically tracked and updated

## Data Structure

The server maintains streak data in memory:

```javascript
{
  currentStreak: 0,
  longestStreak: 0,
  lastCheckInDate: null,
  checkInDates: [], // Array of check-in dates in YYYY-MM-DD format
  missedDays: []
}
```

## CORS Configuration

The server is configured to accept requests from any origin, making it suitable for development with Flutter web apps.

## Testing

You can test the API endpoints using curl:

```bash
# Health check
curl -X GET http://localhost:3000/health

# Get current streak
curl -X GET http://localhost:3000/streak

# Check in for today
curl -X POST http://localhost:3000/check-in -H "Content-Type: application/json"

# Get missed days
curl -X GET http://localhost:3000/missed-days

# Get calendar data
curl -X GET http://localhost:3000/calendar
```

## Notes

- Data is stored in memory and will be lost when the server restarts
- All dates are handled in YYYY-MM-DD format
- The server automatically handles timezone considerations using the server's local time
- Streak calculations are performed in real-time based on check-in patterns
