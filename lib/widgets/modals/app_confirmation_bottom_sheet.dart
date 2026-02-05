import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/buttons/app_button.dart';

enum ConfirmationStyle {
  normal, // Blue
  destructive, // Red
}

class AppConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final ConfirmationStyle style;
  final String? icon;

  const AppConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.confirmLabel,
    this.cancelLabel = 'ยกเลิก',
    this.onConfirm,
    this.onCancel,
    this.style = ConfirmationStyle.normal,
    this.icon,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
    required String confirmLabel,
    String cancelLabel = 'ยกเลิก',
    VoidCallback? onConfirm,
    String? icon,
    VoidCallback? onCancel,
    ConfirmationStyle style = ConfirmationStyle.normal,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AppConfirmationBottomSheet(
        title: title,
        icon: icon,
        description: description,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
        onCancel: onCancel,
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageAsset =
        icon ??
        (style == ConfirmationStyle.destructive
            ? 'assets/images/dialog/YA_Illustration_ConfirmDelete.png'
            : 'assets/images/dialog/YA_Illustration_ConfirmSave.png');

    // The primary button style for "Destructive" is red, for "Normal" is blue (typically primary).
    // AppButtonStyle.destructive usually maps to red. AppButtonStyle.primary usually maps to blue/brand.
    final buttonStyle = style == ConfirmationStyle.destructive
        ? AppButtonStyle.destructive
        : AppButtonStyle.primary;

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
            MediaQuery.of(context).padding.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image
              Image.asset(imageAsset, height: 160, fit: BoxFit.fitHeight),

              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: GoogleFonts.anuphan(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.baseBlack,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                description,
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.baseGrey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: confirmLabel,
                  style: buttonStyle,
                  textStyle: GoogleFonts.anuphan(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm?.call();
                  },
                ),
              ),

              if (cancelLabel.isNotEmpty) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    if (onCancel != null) onCancel!();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: Colors.transparent,
                  ),
                  child: Text(
                    cancelLabel,
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseDarkGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
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
