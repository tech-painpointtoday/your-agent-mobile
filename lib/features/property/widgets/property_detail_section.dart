import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';

/// Property detail section widget for displaying key-value pairs
class PropertyDetailSection extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? svgIcon;
  final List<PropertyDetailRow> rows;
  final bool showDivider;

  const PropertyDetailSection({
    super.key,
    required this.title,
    this.icon,
    this.svgIcon,
    required this.rows,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with optional icon
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 8),
          decoration: showDivider
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1, color: AppColors.baseGrey),
                  ),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (svgIcon != null) ...[
                SvgPicture.asset(
                  svgIcon!,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF181D27),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (icon != null) ...[
                Icon(icon, size: 18, color: const Color(0xFF181D27)),
                const SizedBox(width: 8),
              ],
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

        // Detail rows
        Column(
          mainAxisSize: MainAxisSize.min,
          children: rows.map((row) => _DetailRow(row: row)).toList(),
        ),
      ],
    );
  }
}

/// Represents a single detail row with label and value
class PropertyDetailRow {
  final String label;
  final String value;

  const PropertyDetailRow({required this.label, required this.value});
}

class _DetailRow extends StatelessWidget {
  final PropertyDetailRow row;

  const _DetailRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          SizedBox(
            width: 148,
            child: Text(
              row.label,
              style: GoogleFonts.anuphan(
                color: AppColors.baseDarkGrey,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Value
          Expanded(
            child: Text(
              row.value,
              style: GoogleFonts.anuphan(
                color: const Color(0xFF181D27),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
