import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class ExpandableDescription extends StatefulWidget {
  final String text;
  final int maxLines;

  const ExpandableDescription({
    super.key,
    required this.text,
    this.maxLines = 4,
  });

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _isExpanded ? null : widget.maxLines,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: GoogleFonts.anuphan(
            color: const Color(0xFF181D27),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            children: [
              Text(
                _isExpanded ? 'เเสดงน้อยลง' : 'ดูเพิ่มเติม',
                style: GoogleFonts.anuphan(
                  color: AppColors.brandGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(
                _isExpanded
                    ? 'assets/icons/chevron-up.svg'
                    : 'assets/icons/chevron-down.svg',
                colorFilter: ColorFilter.mode(
                  AppColors.brandGreen,
                  BlendMode.srcIn,
                ),
                width: 16,
                height: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
