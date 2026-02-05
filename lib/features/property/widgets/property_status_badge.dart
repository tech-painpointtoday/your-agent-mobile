import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/app.dart';
import 'package:youragent/core/theme/app_colors.dart';

import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/l10n/app_localizations.dart';

/// Status badge widget that displays property status with appropriate colors
class PropertyStatusBadge extends StatelessWidget {
  final PropertyApprovalStatus status;
  final bool isDraft;

  const PropertyStatusBadge({
    super.key,
    required this.status,
    this.isDraft = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(context, status, isDraft);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: config.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: ShapeDecoration(
              color: config.dotColor,
              shape: const CircleBorder(),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: GoogleFonts.anuphan(
              color: config.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(
    BuildContext context,
    PropertyApprovalStatus status,
    bool isDraft,
  ) {
    final l10n = AppLocalizations.of(context);
    if (isDraft) {
      return _StatusConfig(
        label: l10n.draftLabel,
        backgroundColor: AppColors.supportPurpleLight,
        dotColor: AppColors.supportPurpleDark,
        textColor: AppColors.supportPurpleDark,
      );
    }

    switch (status) {
      case PropertyApprovalStatus.draft:
        return _StatusConfig(
          label: l10n.draftLabel,
          backgroundColor: AppColors.supportPurpleLight,
          dotColor: AppColors.supportPurpleDark,
          textColor: AppColors.supportPurpleDark,
        );
      case PropertyApprovalStatus.pending:
        return _StatusConfig(
          label: l10n.pendingAt,
          backgroundColor: AppColors.supportOrangeLight,
          dotColor: AppColors.supportOrangeDark,
          textColor: AppColors.supportOrangeDark,
        );
      case PropertyApprovalStatus.approved:
        return _StatusConfig(
          label: l10n.approvedAt,
          backgroundColor: AppColors.supportGreenLight,
          dotColor: AppColors.supportGreenDark,
          textColor: AppColors.supportGreenDark,
        );
      case PropertyApprovalStatus.rejected:
        return _StatusConfig(
          label: l10n.disapprovedAt,
          backgroundColor: AppColors.supportRedLight,
          dotColor: AppColors.supportRedDark,
          textColor: AppColors.supportRedDark,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color backgroundColor;
  final Color dotColor;
  final Color textColor;

  const _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.dotColor,
    required this.textColor,
  });
}
