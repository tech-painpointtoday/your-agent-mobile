import 'package:flutter/material.dart';
import 'package:yourhome/core/theme/app_colors.dart';

class FormLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const FormLabel({super.key, required this.label, this.isRequired = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text.rich(
        TextSpan(
          text: label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.baseDarkGrey,
          ),
          children: [
            if (!isRequired)
              TextSpan(
                text: ' (ไม่บังคับ)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.baseGrey, // #A4A7AE
                ),
              ),
          ],
        ),
      ),
    );
  }
}
