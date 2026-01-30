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
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final ConfirmationStyle style;
  final String? icon;

  const AppConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.confirmLabel,
    this.cancelLabel = 'ยกเลิก',
    required this.onConfirm,
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
    required VoidCallback onConfirm,
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
            ? 'assets/images/dialog/confirmation_red.png'
            : 'assets/images/dialog/confirmation_blue.png');

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
            MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image
              Image.asset(
                imageAsset,
                height: 120, // Adjust based on actual asset size/ratio
                fit: BoxFit.contain,
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

              const SizedBox(height: 8),

              // Description
              Text(
                description,
                style: GoogleFonts.anuphan(
                  fontSize: 14,
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
                  onPressed: () {
                    Navigator.pop(context); // Close sheet
                    onConfirm();
                  },
                ),
              ),

              if (cancelLabel.isNotEmpty) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    if (onCancel != null) onCancel!();
                    Navigator.pop(context);
                  },
                  child: Text(
                    cancelLabel,
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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
