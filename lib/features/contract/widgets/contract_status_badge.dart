import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import '../../../domain/entities/contract_status.dart';
import 'package:youragent/l10n/app_localizations.dart';

class ContractStatusBadge extends StatelessWidget {
  final ContractStatus status;
  final int? signedCount;
  final int? totalCount;

  const ContractStatusBadge({
    super.key,
    required this.status,
    this.signedCount,
    this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(context, status);
    final countSuffix = (signedCount != null && totalCount != null)
        ? ' ($signedCount/$totalCount)'
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          const SizedBox(width: 8),
          Text(
            '${config.label}$countSuffix',
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

  _StatusConfig _getStatusConfig(BuildContext context, ContractStatus status) {
    final l10n = AppLocalizations.of(context);
    switch (status) {
      case ContractStatus.draft:
        return _StatusConfig(
          label: l10n.draftLabel,
          backgroundColor: AppColors.supportPurpleLight,
          dotColor: AppColors.supportPurpleDark,
          textColor: AppColors.supportPurpleDark,
        );
      case ContractStatus.pendingSignature:
        return _StatusConfig(
          label: l10n.statusPendingSignature,
          backgroundColor: AppColors.supportOrangeLight,
          dotColor: AppColors.supportOrangeDark,
          textColor: AppColors.supportOrangeDark,
        );
      case ContractStatus.signed:
      case ContractStatus.completed:
        return _StatusConfig(
          label: l10n.statusComplete,
          backgroundColor: AppColors.supportGreenLight,
          dotColor: AppColors.supportGreenDark,
          textColor: AppColors.supportGreenDark,
        );
      case ContractStatus.cancelled:
        return _StatusConfig(
          label: l10n.statusCancelled,
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
