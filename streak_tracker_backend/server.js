const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// In-memory storage
let streakData = {
  currentStreak: 0,
  longestStreak: 0,
  lastCheckInDate: null,
  checkInDates: [], // Array of check-in dates in YYYY-MM-DD format
  missedDays: []
};

// Helper function to get today's date in YYYY-MM-DD format (local timezone)
function getTodayDate() {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// Helper function to get yesterday's date in YYYY-MM-DD format (local timezone)
function getYesterdayDate() {
  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);
  const year = yesterday.getFullYear();
  const month = String(yesterday.getMonth() + 1).padStart(2, '0');
  const day = String(yesterday.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// Helper function to calculate days between two dates
function daysBetween(date1, date2) {
  const oneDay = 24 * 60 * 60 * 1000;
  const firstDate = new Date(date1 + 'T00:00:00');
  const secondDate = new Date(date2 + 'T00:00:00');
  return Math.round(Math.abs((firstDate - secondDate) / oneDay));
}

// Helper function to get date N days ago
function getDateNDaysAgo(n) {
  const date = new Date();
  date.setDate(date.getDate() - n);
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// Helper function to check if a date is valid
function isValidDate(dateString) {
  const regex = /^\d{4}-\d{2}-\d{2}$/;
  if (!regex.test(dateString)) return false;
  const date = new Date(dateString + 'T00:00:00');
  return date instanceof Date && !isNaN(date);
}

// Helper function to update streak logic with improved accuracy
function updateStreakLogic() {
  const today = getTodayDate();
  const yesterday = getYesterdayDate();

  // First check-in ever
  if (streakData.checkInDates.length === 1) {
    streakData.currentStreak = 1;
    streakData.longestStreak = Math.max(streakData.longestStreak, 1);
    return;
  }

  const lastCheckIn = streakData.lastCheckInDate;

  if (lastCheckIn === yesterday) {
    // Consecutive day - increment streak
    streakData.currentStreak += 1;
    streakData.longestStreak = Math.max(streakData.longestStreak, streakData.currentStreak);
  } else if (lastCheckIn === today) {
    // Already checked in today - no change needed
    return;
  } else {
    // Gap in check-ins - calculate missed days and reset streak
    const daysMissed = daysBetween(today, lastCheckIn) - 1;

    if (daysMissed > 0) {
      // Add missed days to tracking (but not today)
      const missedDates = [];
      for (let i = 1; i <= daysMissed; i++) {
        const missedDate = new Date(lastCheckIn + 'T00:00:00');
        missedDate.setDate(missedDate.getDate() + i);
        const year = missedDate.getFullYear();
        const month = String(missedDate.getMonth() + 1).padStart(2, '0');
        const day = String(missedDate.getDate()).padStart(2, '0');
        const missedDateStr = `${year}-${month}-${day}`;

        if (missedDateStr !== today && !streakData.missedDays.includes(missedDateStr)) {
          missedDates.push(missedDateStr);
        }
      }
      streakData.missedDays.push(...missedDates);
    }

    // Reset current streak to 1 (today's check-in)
    streakData.currentStreak = 1;
  }
}

// Helper function to calculate current streak from scratch (for validation)
function recalculateStreak() {
  if (streakData.checkInDates.length === 0) {
    return { currentStreak: 0, longestStreak: 0 };
  }

  // Sort check-in dates
  const sortedDates = [...streakData.checkInDates].sort();
  const today = getTodayDate();

  let currentStreak = 0;
  let longestStreak = 0;
  let tempStreak = 0;

  // Calculate streaks by checking consecutive dates
  for (let i = 0; i < sortedDates.length; i++) {
    if (i === 0) {
      tempStreak = 1;
    } else {
      const prevDate = new Date(sortedDates[i - 1] + 'T00:00:00');
      const currDate = new Date(sortedDates[i] + 'T00:00:00');
      const dayDiff = (currDate - prevDate) / (24 * 60 * 60 * 1000);

      if (dayDiff === 1) {
        tempStreak++;
      } else {
        longestStreak = Math.max(longestStreak, tempStreak);
        tempStreak = 1;
      }
    }
  }

  longestStreak = Math.max(longestStreak, tempStreak);

  // Current streak is only valid if it includes today or yesterday
  const lastCheckIn = sortedDates[sortedDates.length - 1];
  const yesterday = getYesterdayDate();

  if (lastCheckIn === today || lastCheckIn === yesterday) {
    currentStreak = tempStreak;
  } else {
    currentStreak = 0;
  }

  return { currentStreak, longestStreak };
}

// Helper function to get missed days in the past 30 days with improved accuracy
function getMissedDaysInPast30Days() {
  const today = getTodayDate();
  const checkInSet = new Set(streakData.checkInDates);
  const missedInRange = [];

  // Only count days where user could have checked in (exclude today and future dates)
  for (let i = 1; i <= 30; i++) {
    const date = new Date();
    date.setDate(date.getDate() - i);
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const dateStr = `${year}-${month}-${day}`;

    // Only consider it missed if user had started checking in by then
    const firstCheckIn = streakData.checkInDates.length > 0 ?
      Math.min(...streakData.checkInDates.map(d => new Date(d + 'T00:00:00').getTime())) :
      new Date().getTime();
    const dateTime = new Date(dateStr + 'T00:00:00').getTime();

    if (dateTime >= firstCheckIn && !checkInSet.has(dateStr)) {
      missedInRange.push(dateStr);
    }
  }

  return missedInRange.sort();
}

// Helper function to validate and clean up streak data
function validateStreakData() {
  // Remove duplicate check-in dates
  streakData.checkInDates = [...new Set(streakData.checkInDates)].sort();

  // Remove duplicate missed days
  streakData.missedDays = [...new Set(streakData.missedDays)].sort();

  // Remove any check-in dates that are in the future
  const today = getTodayDate();
  streakData.checkInDates = streakData.checkInDates.filter(date => date <= today);

  // Recalculate streak for accuracy
  const calculated = recalculateStreak();
  streakData.currentStreak = calculated.currentStreak;
  streakData.longestStreak = Math.max(streakData.longestStreak, calculated.longestStreak);

  // Update last check-in date
  if (streakData.checkInDates.length > 0) {
    streakData.lastCheckInDate = Math.max(...streakData.checkInDates);
  }
}

// Routes

// POST /check-in - Log today's check-in with enhanced validation
app.post('/check-in', (req, res) => {
  const today = getTodayDate();

  // Validate and clean data first
  validateStreakData();

  // Check if already checked in today
  if (streakData.checkInDates.includes(today)) {
    return res.status(400).json({
      success: false,
      message: 'Already checked in today! Come back tomorrow to continue your streak.',
      currentStreak: streakData.currentStreak,
      longestStreak: streakData.longestStreak,
      lastCheckInDate: streakData.lastCheckInDate,
      nextCheckInAvailable: getYesterdayDate() // Tomorrow
    });
  }

  // Add today's check-in
  streakData.checkInDates.push(today);
  streakData.lastCheckInDate = today;

  // Update streak logic with improved calculation
  updateStreakLogic();

  // Generate appropriate success message
  let message;
  if (streakData.currentStreak === 1) {
    message = "Great start! You've begun your streak journey! 🌱";
  } else if (streakData.currentStreak < 7) {
    message = `Awesome! You're on a ${streakData.currentStreak}-day streak! Keep it up! 🔥`;
  } else if (streakData.currentStreak < 30) {
    message = `Amazing! ${streakData.currentStreak} days strong! You're on fire! ⚡`;
  } else if (streakData.currentStreak < 100) {
    message = `Incredible! ${streakData.currentStreak}-day streak! You're unstoppable! 🚀`;
  } else {
    message = `LEGENDARY! ${streakData.currentStreak} days! You're a streak master! 👑`;
  }

  res.json({
    success: true,
    message: message,
    currentStreak: streakData.currentStreak,
    longestStreak: streakData.longestStreak,
    lastCheckInDate: streakData.lastCheckInDate,
    totalCheckIns: streakData.checkInDates.length,
    isNewRecord: streakData.currentStreak === streakData.longestStreak && streakData.currentStreak > 1
  });
});

// GET /streak - Get current streak information
app.get('/streak', (req, res) => {
  res.json({
    currentStreak: streakData.currentStreak,
    longestStreak: streakData.longestStreak,
    lastCheckInDate: streakData.lastCheckInDate,
    totalCheckIns: streakData.checkInDates.length,
    canCheckInToday: !streakData.checkInDates.includes(getTodayDate())
  });
});

// GET /missed-days - Get missed days in the past 30 days
app.get('/missed-days', (req, res) => {
  const missedDays = getMissedDaysInPast30Days();
  
  res.json({
    missedDays: missedDays,
    totalMissedDays: missedDays.length,
    dateRange: {
      from: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      to: getTodayDate()
    }
  });
});

// GET /calendar - Get calendar data for frontend
app.get('/calendar', (req, res) => {
  res.json({
    checkInDates: streakData.checkInDates,
    missedDays: getMissedDaysInPast30Days(),
    currentStreak: streakData.currentStreak
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Start server on all interfaces to allow emulator access
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Streak Tracker Backend running on port ${PORT}`);
  console.log(`📊 API endpoints available:`);
  console.log(`   POST http://localhost:${PORT}/check-in`);
  console.log(`   GET  http://localhost:${PORT}/streak`);
  console.log(`   GET  http://localhost:${PORT}/missed-days`);
  console.log(`   GET  http://localhost:${PORT}/calendar`);
  console.log(`   GET  http://localhost:${PORT}/health`);
  console.log(`\n🔗 For Android emulator, use: http://10.0.2.2:${PORT}`);
  console.log(`🔗 For iOS simulator, use: http://localhost:${PORT}`);
});

module.exports = app;
