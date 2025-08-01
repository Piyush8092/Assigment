import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ReminderCard extends StatefulWidget {
  final VoidCallback onCheckIn;
  final int currentStreak;
  final bool isUrgent;

  const ReminderCard({
    super.key,
    required this.onCheckIn,
    this.currentStreak = 0,
    this.isUrgent = false,
  });

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: AppConstants.pulseAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    if (widget.isUrgent) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _dismiss() {
    setState(() => _isDismissed = true);
    _animationController.reverse();
  }

  String _getReminderMessage() {
    if (widget.currentStreak == 0) {
      return 'Start your streak journey! Check in now to begin.';
    } else if (widget.currentStreak == 1) {
      return 'You\'re just getting started! Don\'t lose momentum.';
    } else if (widget.currentStreak < 7) {
      return 'You\'re building a great habit! Keep your ${widget.currentStreak}-day streak alive.';
    } else if (widget.currentStreak < 30) {
      return 'Amazing ${widget.currentStreak}-day streak! Don\'t break it now.';
    } else {
      return 'Incredible ${widget.currentStreak}-day streak! You\'re a legend - keep it going!';
    }
  }

  String _getUrgencyLevel() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 23) return 'URGENT';
    if (hour >= 22) return 'Important';
    return 'Reminder';
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isUrgent ? _pulseAnimation.value : 1.0,
                  child: Card(
                    elevation: widget.isUrgent ? 8 : 6,
                    color: widget.isUrgent ? Colors.red[50] : Colors.orange[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                      side: BorderSide(
                        color: widget.isUrgent ? Colors.red[300]! : Colors.orange[300]!,
                        width: widget.isUrgent ? 2 : 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                widget.isUrgent ? Icons.warning : Icons.notifications_active,
                                color: widget.isUrgent ? Colors.red[700] : Colors.orange[700],
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getUrgencyLevel(),
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: widget.isUrgent ? Colors.red[600] : Colors.orange[600],
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      'Don\'t forget to check in!',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: widget.isUrgent ? Colors.red[800] : Colors.orange[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: widget.isUrgent ? Colors.red[600] : Colors.orange[600],
                                  size: 20,
                                ),
                                onPressed: _dismiss,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Dismiss reminder',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getReminderMessage(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: widget.isUrgent ? Colors.red[700] : Colors.orange[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: _dismiss,
                                child: Text(
                                  'Later',
                                  style: TextStyle(
                                    color: widget.isUrgent ? Colors.red[600] : Colors.orange[600],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  widget.onCheckIn();
                                  _dismiss();
                                },
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Check In Now'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.isUrgent ? Colors.red[600] : Colors.orange[600],
                                  foregroundColor: Colors.white,
                                  elevation: widget.isUrgent ? 4 : 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
