import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';

class StatusToast extends StatefulWidget {
  final String title;
  final String? message;
  final DialogType type;
  final Duration duration;
  final VoidCallback? onDismiss;
  final Duration? callbackDelay;

  const StatusToast({
    super.key,
    required this.title,
    this.message,
    required this.type,
    this.duration = const Duration(seconds: 3),
    this.onDismiss,
    this.callbackDelay,
  });

  @override
  State<StatusToast> createState() => _StatusToastState();
}

class _StatusToastState extends State<StatusToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _dismissTimer;
  Timer? _callbackTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    _dismissTimer = Timer(widget.duration, () {
      _dismiss();
    });

    if (widget.callbackDelay != null && widget.onDismiss != null) {
      _callbackTimer = Timer(widget.callbackDelay!, () {
        widget.onDismiss?.call();
      });
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _callbackTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (!mounted) return;

    _dismissTimer?.cancel();

    _controller.reverse().then((_) {
      if (!mounted) return;

      if (widget.callbackDelay == null && widget.onDismiss != null) {
        widget.onDismiss?.call();
      }

      try {
        final navigator = Navigator.of(context, rootNavigator: true);
        if (navigator.canPop()) {
          navigator.pop();
        }
      } catch (e) {
        debugPrint('⚠️ StatusToast: Error dismissing toast: $e');
      }
    });
  }

  Color _getIconColor() {
    switch (widget.type) {
      case DialogType.success:
        return AppColors.success600;
      case DialogType.error:
        return AppColors.supportRedDeep;
      case DialogType.warning:
        return AppColors.warning;
      case DialogType.info:
        return AppColors.blue600;
      case DialogType.destructive:
        return AppColors.supportRedDeep;
    }
  }

  Widget _getIcon() {
    String iconPath;
    switch (widget.type) {
      case DialogType.success:
        iconPath = 'assets/icons/check-circle.svg';
        break;
      case DialogType.error:
        iconPath = 'assets/icons/x-circle.svg';
        break;
      case DialogType.warning:
        iconPath = 'assets/icons/alert-triangle.svg';
        break;
      case DialogType.destructive:
        iconPath = 'assets/icons/alert-triangle.svg';
        break;
      case DialogType.info:
        return Icon(Icons.info_outline, color: _getIconColor(), size: 24);
    }
    return SvgPicture.asset(
      iconPath,
      colorFilter: ColorFilter.mode(_getIconColor(), BlendMode.srcIn),
      width: 24,
      height: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 16),
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: _dismiss,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 512,
                      minWidth: 400,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(child: _getIcon()),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.title,
                                  style: GoogleFonts.anuphan(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.baseDarkGrey,
                                  ),
                                ),
                                if (widget.message != null &&
                                    widget.message!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.message!,
                                    style: GoogleFonts.anuphan(
                                      fontSize: 12,
                                      color: AppColors.baseDarkGrey,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: _dismiss,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                'assets/icons/x.svg',
                                width: 12,
                                height: 12,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.baseGrey,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
