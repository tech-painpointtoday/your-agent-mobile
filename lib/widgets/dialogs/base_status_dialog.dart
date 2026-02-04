import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'status_dialog.dart';

class BaseStatusDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String confirmText;
  final String? cancelText;
  final Color confirmColor;
  final bool isDestructive;
  final bool isSingleAction;
  final VoidCallback? onConfirm;
  final DialogType type;

  const BaseStatusDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    required this.confirmText,
    this.cancelText,
    required this.confirmColor,
    this.isDestructive = false,
    this.isSingleAction = false,
    this.onConfirm,
    this.type = DialogType.info,
  }) : assert(
         message != null || content != null,
         'Either message or content must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIllustration(),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: GoogleFonts.anuphan(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.baseBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (message != null || content != null) ...[
                  const SizedBox(height: 8),
                  if (content != null)
                    content!
                  else
                    Text(
                      message!,
                      style: GoogleFonts.anuphan(
                        fontSize: 16,
                        color: AppColors.baseGrey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
                const SizedBox(height: 32),
                _buildActions(context),
              ],
            ),
          ),
          const Positioned(top: 16, right: 16, child: StatusCloseButton()),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    String? assetPath;
    switch (type) {
      case DialogType.destructive:
        assetPath = 'assets/images/dialog/confirmation_red.png';
        break;
      case DialogType.info:
        assetPath = 'assets/images/dialog/confirmation_blue.png';
        break;
      case DialogType.success:
        assetPath =
            'assets/images/dialog/confirmation_blue.png'; // Fallback or specific success image
        break;
      default:
        return StatusIcon(type: type);
    }

    return Image.asset(assetPath, height: 140, fit: BoxFit.contain);
  }

  Widget _buildActions(BuildContext context) {
    final primaryButton = SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop(true);
          onConfirm?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: confirmColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.anuphan(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        child: Text(confirmText),
      ),
    );

    if (isSingleAction) return primaryButton;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        primaryButton,
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText ?? 'Cancel',
            style: GoogleFonts.anuphan(
              color: AppColors.baseGrey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
