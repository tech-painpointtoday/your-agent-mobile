import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final style = GoogleFonts.anuphan(
          color: const Color(0xFF181D27),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        );

        final span = TextSpan(text: widget.text, style: style);
        final tp = TextPainter(
          text: span,
          maxLines: widget.maxLines,
          textDirection: Directionality.of(context),
        );
        tp.layout(maxWidth: constraints.maxWidth);

        final isOverflowing = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: _isExpanded ? null : widget.maxLines,
              overflow: _isExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: style,
            ),
            if (isOverflowing) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      _isExpanded
                          ? AppLocalizations.of(context).showLessButton
                          : AppLocalizations.of(context).showMoreButton,
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
          ],
        );
      },
    );
  }
}
