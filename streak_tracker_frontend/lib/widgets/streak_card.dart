import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StreakCard extends StatefulWidget {
  final int currentStreak;
  final int longestStreak;
  final String? lastCheckInDate;
  final int totalCheckIns;
  final bool isNewRecord;

  const StreakCard({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    this.lastCheckInDate,
    required this.totalCheckIns,
    this.isNewRecord = false,
  });

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _scaleController.forward();

    if (widget.isNewRecord) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Never';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _getStreakEmoji(int streak) {
    if (streak == 0) return '😴';
    if (streak < 3) return '🌱';
    if (streak < 7) return '🔥';
    if (streak < 30) return '⚡';
    if (streak < 100) return '🚀';
    return '👑';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Card(
                  elevation: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // New record badge
                          if (widget.isNewRecord) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.emoji_events, size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'NEW RECORD!',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Current streak display
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmallScreen = constraints.maxWidth < 300;
                              return Column(
                                children: [
                                  Text(
                                    _getStreakEmoji(widget.currentStreak),
                                    style: TextStyle(fontSize: isSmallScreen ? 28 : 36),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${widget.currentStreak}',
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontSize: isSmallScreen ? 28 : 36,
                                    ),
                                  ),
                                  Text(
                                    widget.currentStreak == 1 ? 'day streak' : 'days streak',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Stats row
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmallScreen = constraints.maxWidth < 300;
                              if (isSmallScreen) {
                                return Column(
                                  children: [
                                    _buildStatItem(
                                      context,
                                      'Longest Streak',
                                      '${widget.longestStreak} days',
                                      Icons.emoji_events,
                                      Colors.amber,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildStatItem(
                                      context,
                                      'Total Check-ins',
                                      '${widget.totalCheckIns}',
                                      Icons.check_circle,
                                      Colors.green,
                                    ),
                                  ],
                                );
                              } else {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(
                                      context,
                                      'Longest Streak',
                                      '${widget.longestStreak} days',
                                      Icons.emoji_events,
                                      Colors.amber,
                                    ),
                                    _buildStatItem(
                                      context,
                                      'Total Check-ins',
                                      '${widget.totalCheckIns}',
                                      Icons.check_circle,
                                      Colors.green,
                                    ),
                                  ],
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 20),

                          // Last check-in info
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Last check-in: ${_formatDate(widget.lastCheckInDate)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
