import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';

/// Status bottom sheet with the same API as [StatusDialog] (showSuccess, showError, etc.)
/// and UI layout like [AppConfirmationBottomSheet]: image/icon, title, description, single OK button.
class AppStatusBottomSheet extends StatelessWidget {
  final String title;
  final String? message;
  final String buttonText;
  final VoidCallback? onOk;
  final DialogType type;
  final String? iconPath;

  const AppStatusBottomSheet({
    super.key,
    required this.title,
    this.message,
    this.buttonText = 'OK',
    this.onOk,
    this.iconPath,
    required this.type,
  });

  /// Show success status bottom sheet (green icon, single OK button).
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onOk,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      onOk: onOk,
      type: DialogType.success,
    );
  }

  /// Show error status bottom sheet (red icon, single OK button).
  static Future<void> showError({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onOk,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      onOk: onOk,
      type: DialogType.error,
    );
  }

  /// Show warning status bottom sheet (orange icon, single OK button).
  static Future<void> showWarning({
    required BuildContext context,
    required String title,
    String? message,
    String? iconPath,
    String buttonText = 'OK',
    VoidCallback? onOk,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      iconPath: iconPath,
      onOk: onOk,
      type: DialogType.warning,
    );
  }

  /// Show info status bottom sheet (blue icon, single OK button).
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onOk,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      onOk: onOk,
      type: DialogType.info,
    );
  }

  /// Show destructive status bottom sheet (red icon, single OK button).
  static Future<void> showDestructive({
    required BuildContext context,
    required String title,
    String? message,
    String buttonText = 'OK',
    VoidCallback? onOk,
  }) {
    return show(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      onOk: onOk,
      type: DialogType.destructive,
    );
  }

  /// Generic show: builds and displays the status bottom sheet.
  static Future<void> show({
    required BuildContext context,
    required String title,
    String? message,
    String? iconPath,
    String buttonText = 'OK',
    VoidCallback? onOk,
    required DialogType type,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AppStatusBottomSheet(
        title: title,
        message: message,
        buttonText: buttonText,
        iconPath: iconPath,
        onOk: onOk,
        type: type,
      ),
    );
  }

  AppButtonStyle get _buttonStyle {
    switch (type) {
      case DialogType.error:
      case DialogType.destructive:
        return AppButtonStyle.destructive;
      default:
        return AppButtonStyle.primary;
    }
  }

  Color? get _buttonBackgroundColor {
    switch (type) {
      case DialogType.success:
        return AppColors.supportGreenDark;
      case DialogType.warning:
        return AppColors.supportOrangeDark;
      case DialogType.info:
        return AppColors.supportBlueDeep;
      case DialogType.error:
      case DialogType.destructive:
        return null; // use destructive style default
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            32,
            24,
            MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status icon (larger than dialog version)
              SizedBox(
                height: 80,
                width: 80,
                child: Center(child: _StatusIconLarge(type: type)),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                title,
                style: GoogleFonts.anuphan(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.baseBlack,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  style: GoogleFonts.anuphan(
                    fontSize: 14,
                    color: AppColors.baseGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              // Single action button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: buttonText,
                  style: _buttonStyle,
                  backgroundColor: _buttonBackgroundColor,
                  textColor: AppColors.baseWhite,
                  onPressed: () {
                    Navigator.pop(context);
                    onOk?.call();
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/icons/x-circle-filled.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.baseLightGrey,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Larger status icon for bottom sheet (same logic as [StatusIcon], bigger size).
class _StatusIconLarge extends StatelessWidget {
  final DialogType type;

  const _StatusIconLarge({required this.type});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String iconPath;
    Color iconColor;

    switch (type) {
      case DialogType.success:
        bgColor = AppColors.supportGreenLight;
        iconPath = 'assets/icons/check-circle.svg';
        iconColor = AppColors.supportGreenDark;
        break;
      case DialogType.error:
        bgColor = AppColors.supportRedLight;
        iconPath = 'assets/icons/x-circle.svg';
        iconColor = AppColors.supportRedDark;
        break;
      case DialogType.destructive:
        bgColor = AppColors.supportRedLight;
        iconPath = 'assets/icons/alert-triangle.svg';
        iconColor = AppColors.supportRedDark;
        break;
      case DialogType.warning:
        bgColor = AppColors.supportOrangeLight;
        iconPath = 'assets/icons/alert-triangle.svg';
        iconColor = AppColors.supportOrangeDark;
        break;
      case DialogType.info:
        bgColor = AppColors.supportBlueLight;
        iconPath = 'assets/icons/info.svg';
        iconColor = AppColors.supportBlueDeep;
        break;
    }

    final Widget iconWidget = type == DialogType.info
        ? Icon(Icons.info_outline, color: iconColor, size: 40)
        : SvgPicture.asset(
            iconPath,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            width: 40,
            height: 40,
          );

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(child: iconWidget),
    );
  }
}
