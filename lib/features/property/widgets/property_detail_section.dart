import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class PropertyDetailSection extends StatelessWidget {
  final String title;
  final String svgIcon;
  final List<PropertyDetailRow> rows;

  const PropertyDetailSection({
    super.key,
    required this.title,
    required this.svgIcon,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1, color: AppColors.baseGrey),
            ),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                svgIcon,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF181D27),
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.anuphan(
                  color: const Color(0xFF181D27),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...rows,
      ],
    );
  }
}

class PropertyDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const PropertyDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.anuphan(
              color: AppColors.baseDarkGrey,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.anuphan(
              color: const Color(0xFF181D27),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
