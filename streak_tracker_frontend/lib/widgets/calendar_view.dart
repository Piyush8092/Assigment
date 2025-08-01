import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  final List<String> checkInDates;
  final List<String> missedDays;

  const CalendarView({
    super.key,
    required this.checkInDates,
    required this.missedDays,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  bool _isCheckInDay(DateTime day) {
    final dayStr = day.toIso8601String().split('T')[0];
    return widget.checkInDates.contains(dayStr);
  }

  bool _isMissedDay(DateTime day) {
    final dayStr = day.toIso8601String().split('T')[0];
    return widget.missedDays.contains(dayStr);
  }

  bool _isToday(DateTime day) {
    final today = DateTime.now();
    return isSameDay(day, today);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Calendar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(
                  context,
                  'Check-in',
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildLegendItem(
                  context,
                  'Missed',
                  Colors.red[300]!,
                  Icons.cancel,
                ),
                _buildLegendItem(
                  context,
                  'Today',
                  Colors.blue,
                  Icons.today,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Calendar
            TableCalendar<String>(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              
              // Styling
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                holidayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                defaultTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: Theme.of(context).textTheme.titleMedium!,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Theme.of(context).colorScheme.primary,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              
              // Event handling
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              
              // Custom day builder
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return _buildDayCell(context, day);
                },
                todayBuilder: (context, day, focusedDay) {
                  return _buildDayCell(context, day, isToday: true);
                },
                selectedBuilder: (context, day, focusedDay) {
                  return _buildDayCell(context, day, isSelected: true);
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Statistics
            _buildStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime day, {bool isToday = false, bool isSelected = false}) {
    final isCheckIn = _isCheckInDay(day);
    final isMissed = _isMissedDay(day);
    
    Color? backgroundColor;
    Color? textColor;
    Widget? icon;
    
    if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primary;
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = Colors.blue.withOpacity(0.7);
      textColor = Colors.white;
    } else if (isCheckIn) {
      backgroundColor = Colors.green.withOpacity(0.8);
      textColor = Colors.white;
      icon = const Icon(Icons.check, size: 12, color: Colors.white);
    } else if (isMissed) {
      backgroundColor = Colors.red[300];
      textColor = Colors.white;
      icon = const Icon(Icons.close, size: 12, color: Colors.white);
    }
    
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(color: Colors.blue, width: 2)
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: textColor ?? Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (icon != null) icon,
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    final totalDays = widget.checkInDates.length + widget.missedDays.length;
    final checkInRate = totalDays > 0 ? (widget.checkInDates.length / totalDays * 100) : 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Check-ins', '${widget.checkInDates.length}', Colors.green),
          _buildStatItem('Missed', '${widget.missedDays.length}', Colors.red),
          _buildStatItem('Rate', '${checkInRate.toStringAsFixed(1)}%', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
