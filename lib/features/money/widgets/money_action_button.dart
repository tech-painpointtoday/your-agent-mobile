import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';

class MoneyActionButton extends StatelessWidget {
  final String label;
  final String iconPath;
  final VoidCallback onTap;

  const MoneyActionButton({
    super.key,
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.basePaleGrey, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: 24,
                height: 24,
                // If the icon should be colored, we can add colorFilter here
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
              fontFamily: 'Anuphan',
            ),
          ),
        ],
      ),
    );
  }
}
