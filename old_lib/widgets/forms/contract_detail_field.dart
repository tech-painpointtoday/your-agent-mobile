import 'package:flutter/material.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Read-only field display widget for contract details
class ContractDetailField extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final bool isRequired;

  const ContractDetailField({
    super.key,
    required this.label,
    required this.value,
    this.suffix,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.gray700, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isRequired)
              Text(' *', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.ruby500)),
          ],
        ),
        const SizedBox(height: 8),
        // Read-only field
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gray300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray900)),
              ),
              if (suffix != null)
                Text(suffix!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray600)),
            ],
          ),
        ),
      ],
    );
  }
}
