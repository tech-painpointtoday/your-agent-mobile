import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import '../../../domain/entities/contract_status.dart';

class ContractStatusBadge extends StatelessWidget {
  final ContractStatus status;

  const ContractStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

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

  _StatusConfig _getStatusConfig(ContractStatus status) {
    switch (status) {
      case ContractStatus.draft:
        return _StatusConfig(
          label: 'ยังไม่สมบูรณ์',
          backgroundColor: AppColors.supportOrangeLight,
          dotColor: AppColors.supportOrangeDark,
          textColor: AppColors.supportOrangeDark,
        );
      case ContractStatus.pendingSignature:
        return _StatusConfig(
          label: 'รอการลงนาม',
          backgroundColor: AppColors.supportOrangeLight,
          dotColor: AppColors.supportOrangeDark,
          textColor: AppColors.supportOrangeDark,
        );
      case ContractStatus.signed:
      case ContractStatus.completed:
        return _StatusConfig(
          label: 'สมบูรณ์',
          backgroundColor: AppColors.supportGreenLight,
          dotColor: AppColors.supportGreenDark,
          textColor: AppColors.supportGreenDark,
        );
      case ContractStatus.cancelled:
        return _StatusConfig(
          label: 'ยกเลิก',
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
