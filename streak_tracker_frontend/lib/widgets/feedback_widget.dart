import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// A widget that provides visual feedback to users with different types and animations
class FeedbackWidget extends StatefulWidget {
  final String message;
  final FeedbackType type;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Duration? duration;
  final bool showIcon;
  final bool isDismissible;

  const FeedbackWidget({
    super.key,
    required this.message,
    this.type = FeedbackType.info,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
    this.duration,
    this.showIcon = true,
    this.isDismissible = true,
  });

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideController.forward();
    _fadeController.forward();
    
    // Auto-dismiss after duration if specified
    if (widget.duration != null) {
      Future.delayed(widget.duration!, () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _fadeController.reverse();
    if (mounted) {
      widget.onDismiss?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(AppConstants.defaultPadding),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getBackgroundColor(context),
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            border: Border.all(
              color: _getBorderColor(context),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              if (widget.showIcon) ...[
                Icon(
                  _getIcon(),
                  color: _getIconColor(context),
                  size: 24,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getTextColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.onAction != null && widget.actionLabel != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: widget.onAction,
                        style: TextButton.styleFrom(
                          foregroundColor: _getActionColor(context),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 32),
                        ),
                        child: Text(
                          widget.actionLabel!,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.isDismissible) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _dismiss,
                  icon: Icon(
                    Icons.close,
                    color: _getIconColor(context).withValues(alpha: 0.7),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (widget.type) {
      case FeedbackType.success:
        return Colors.green[50]!;
      case FeedbackType.error:
        return Colors.red[50]!;
      case FeedbackType.warning:
        return Colors.orange[50]!;
      case FeedbackType.info:
        return Colors.blue[50]!;
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (widget.type) {
      case FeedbackType.success:
        return Colors.green[300]!;
      case FeedbackType.error:
        return Colors.red[300]!;
      case FeedbackType.warning:
        return Colors.orange[300]!;
      case FeedbackType.info:
        return Colors.blue[300]!;
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (widget.type) {
      case FeedbackType.success:
        return Colors.green[700]!;
      case FeedbackType.error:
        return Colors.red[700]!;
      case FeedbackType.warning:
        return Colors.orange[700]!;
      case FeedbackType.info:
        return Colors.blue[700]!;
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (widget.type) {
      case FeedbackType.success:
        return Colors.green[800]!;
      case FeedbackType.error:
        return Colors.red[800]!;
      case FeedbackType.warning:
        return Colors.orange[800]!;
      case FeedbackType.info:
        return Colors.blue[800]!;
    }
  }

  Color _getActionColor(BuildContext context) {
    switch (widget.type) {
      case FeedbackType.success:
        return Colors.green[600]!;
      case FeedbackType.error:
        return Colors.red[600]!;
      case FeedbackType.warning:
        return Colors.orange[600]!;
      case FeedbackType.info:
        return Colors.blue[600]!;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case FeedbackType.success:
        return Icons.check_circle;
      case FeedbackType.error:
        return Icons.error;
      case FeedbackType.warning:
        return Icons.warning;
      case FeedbackType.info:
        return Icons.info;
    }
  }
}

/// Types of feedback that can be displayed
enum FeedbackType {
  success,
  error,
  warning,
  info,
}

/// Helper class for showing feedback messages
class FeedbackHelper {
  /// Shows a success feedback message
  static void showSuccess(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration? duration = const Duration(seconds: 4),
  }) {
    _showFeedback(
      context,
      message,
      FeedbackType.success,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  /// Shows an error feedback message
  static void showError(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    _showFeedback(
      context,
      message,
      FeedbackType.error,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  /// Shows a warning feedback message
  static void showWarning(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration? duration = const Duration(seconds: 6),
  }) {
    _showFeedback(
      context,
      message,
      FeedbackType.warning,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  /// Shows an info feedback message
  static void showInfo(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration? duration = const Duration(seconds: 5),
  }) {
    _showFeedback(
      context,
      message,
      FeedbackType.info,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  static void _showFeedback(
    BuildContext context,
    String message,
    FeedbackType type, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration? duration,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: FeedbackWidget(
            message: message,
            type: type,
            onAction: onAction,
            actionLabel: actionLabel,
            duration: duration,
            onDismiss: () => overlayEntry.remove(),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }
}
