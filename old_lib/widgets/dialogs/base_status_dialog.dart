import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'status_dialog_components.dart';
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
  }) : assert(message != null || content != null, 'Either message or content must be provided');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              if (confirmText.isNotEmpty || !isSingleAction) ...[const SizedBox(height: 24), _buildActions(context)],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final bool showIcon = type == DialogType.success || type == DialogType.warning || type == DialogType.error;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showIcon) ...[StatusIcon(type: type), const SizedBox(width: 16)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.anuphan(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.gray900),
              ),
              const SizedBox(height: 4),
              if (content != null)
                content!
              else
                Text(message!, style: GoogleFonts.anuphan(fontSize: 14, color: AppColors.gray600, height: 1.5)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const StatusCloseButton(),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    if (isSingleAction) {
      return SizedBox(
        height: 44,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: GoogleFonts.anuphan(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          child: Text(confirmText),
        ),
      );
    }

    // Aligned to right as per design
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 36,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: GoogleFonts.anuphan(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            child: Text(confirmText),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 36,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gray700,
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.gray300),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: GoogleFonts.anuphan(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            child: Text(cancelText ?? 'Cancel'),
          ),
        ),
      ],
    );
  }
}
