import 'package:flutter/material.dart';
import 'package:gallery_fe/presentation/constants/colors_items.dart';
import 'package:google_fonts/google_fonts.dart';

enum AlertStyle {
  toast, // Alert di atas tanpa tombol
  modal, // Alert di tengah dengan tombol
  banner, // Alert banner di atas
}

enum AlertType {
  success,
  error,
  warning,
  info,
}

class EnhancedModernAlert extends StatefulWidget {
  final String message;
  final String? title;
  final AlertStyle style;
  final AlertType type;
  final Duration duration;
  final VoidCallback? onPressed;
  final List<Widget>? actions;
  final bool showIcon;
  final bool autoDismiss;
  final EdgeInsets? padding;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? iconColor;

  const EnhancedModernAlert({
    super.key,
    required this.message,
    this.title,
    this.style = AlertStyle.toast,
    this.type = AlertType.info,
    this.duration = const Duration(seconds: 3),
    this.onPressed,
    this.actions,
    this.showIcon = true,
    this.autoDismiss = true,
    this.padding,
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<EnhancedModernAlert> createState() => _EnhancedModernAlertState();
}

class _EnhancedModernAlertState extends State<EnhancedModernAlert> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    if (widget.autoDismiss) {
      Future.delayed(widget.duration, () {
        if (mounted) {
          _animationController.reverse();
        }
      });
    }

    // Start the animation after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  IconData get _icon {
    switch (widget.type) {
      case AlertType.success:
        return Icons.check_circle_rounded;
      case AlertType.error:
        return Icons.error;
      case AlertType.warning:
        return Icons.warning_rounded;
      case AlertType.info:
        return Icons.info_rounded;
    }
  }

  Color _getColorByType(BuildContext context) {
    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }

    switch (widget.type) {
      case AlertType.success:
        return AppColors.green.withOpacity(0.7);
      case AlertType.error:
        return Colors.red.withOpacity(0.7);
      case AlertType.warning:
        return Colors.orange.withOpacity(0.7);
      case AlertType.info:
        return Theme.of(context).colorScheme.primary.withOpacity(0.7);
    }
  }

  Color _getTitleColor(BuildContext context) {
    switch (widget.type) {
      case AlertType.success:
        return AppColors.stoneground; // Title color for success
      case AlertType.error:
        return AppColors.stoneground; // Title color for error
      case AlertType.warning:
        return AppColors.stoneground; // Title color for warning
      case AlertType.info:
        return AppColors.stoneground; // Title color for info
    }
  }

  Color _getDescriptionColor(BuildContext context) {
    switch (widget.type) {
      case AlertType.success:
        return AppColors.stoneground; // Description color for success
      case AlertType.error:
        return AppColors.stoneground; // Description color for error
      case AlertType.warning:
        return AppColors.stoneground; // Description color for warning
      case AlertType.info:
        return AppColors.stoneground; // Description color for info
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0.0, -50 * (1 - _fadeAnimation.value)),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Margin
                padding: widget.padding ?? const EdgeInsets.all(7.0), // Reduced padding
                decoration: BoxDecoration(
                  color: _getColorByType(context),
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                  border: Border.all(
                    color: _getColorByType(context).withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.abyssal.withOpacity(0.1),
                      blurRadius: widget.elevation ?? 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onPressed,
                      borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, // Reduced padding
                          vertical: 8.0, // Reduced padding
                        ),
                        child: Row(
                          children: [
                            if (widget.showIcon) ...[
                              Icon(
                                _icon,
                                color: widget.iconColor ?? _getColorByType(context),
                                size: 35,
                              ),
                              const SizedBox(width: 8), // Reduced spacing
                            ],
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.title != null)
                                    Text(
                                      widget.title!,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: _getTitleColor(context), // Title color based on type
                                      ),
                                    ),
                                  Text(
                                    widget.message,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: _getDescriptionColor(context), // Description color based on type
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.actions != null) ...widget.actions!,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Extension untuk memudahkan penggunaan
extension EnhancedModernAlertExtension on BuildContext {
  Future<void> showEnhancedModernAlert({
    required String message,
    String? title,
    AlertStyle style = AlertStyle.toast,
    AlertType type = AlertType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onPressed,
    List<Widget>? actions,
    bool showIcon = true,
    bool autoDismiss = true,
    EdgeInsets? padding,
    double? elevation,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? iconColor,
  }) async {
    OverlayEntry? entry;

    if (style == AlertStyle.modal) {
      return showDialog(
        context: this,
        builder: (context) => EnhancedModernAlert(
          message: message,
          title: title,
          style: style,
          type: type,
          onPressed: onPressed,
          actions: actions,
          showIcon: showIcon,
          padding: padding,
          elevation: elevation,
          borderRadius: borderRadius,
          backgroundColor: backgroundColor,
          iconColor: iconColor,
        ),
      );
    }

    entry = OverlayEntry(
      builder: (context) => EnhancedModernAlert(
        message: message,
        title: title,
        style: style,
        type: type,
        onPressed: onPressed,
        actions: actions,
        showIcon: showIcon,
        autoDismiss: autoDismiss,
        padding: padding,
        elevation: elevation,
        borderRadius: borderRadius,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
      ),
    );

    Overlay.of(this).insert(entry);

    if (autoDismiss) {
      await Future.delayed(duration);
      if (entry.mounted) {
        entry.remove();
      }
    }

    return;
  }
}