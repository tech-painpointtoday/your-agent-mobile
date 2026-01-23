import 'package:flutter/material.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/contract_status.dart';

/// Global contract status chip for displaying draft / pending_signature / signed / completed / cancelled.
class ContractStatusChip extends StatelessWidget {
  final ContractStatus? status;

  const ContractStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final effective = status ?? ContractStatus.draft;

    late final Color dotColor;
    late final Color bgColor;
    late final Color textColor;

    switch (effective) {
      case ContractStatus.draft:
      case ContractStatus.pendingSignature:
        dotColor = AppColors.warning600;
        textColor = AppColors.warning600;
        bgColor = AppColors.warning600.withValues(alpha: 0.12);
        break;
      case ContractStatus.signed:
      case ContractStatus.completed:
        dotColor = AppColors.success600;
        textColor = AppColors.success600;
        bgColor = AppColors.success600.withValues(alpha: 0.12);
        break;
      case ContractStatus.cancelled:
        dotColor = AppColors.error600;
        textColor = AppColors.error600;
        bgColor = AppColors.error600.withValues(alpha: 0.12);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            effective.getLabel(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
          ),
        ],
      ),
    );
  }
}

