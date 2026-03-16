import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yourhome/domain/entities/property.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/l10n/app_localizations.dart';
import 'package:yourhome/utils/app_utils.dart';
import 'package:yourhome/widgets/badges/app_badge.dart';
import 'property_status_badge.dart';

/// Property list item card widget
class PropertyListItem extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const PropertyListItem({
    super.key,
    required this.property,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => context.push('/property/${property.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFFAFAFA)),
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: property.imageUrl ?? '',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 70,
                  height: 70,
                  color: AppColors.basePaleGrey,
                  child: Center(
                    child: SpinKitFadingCircle(
                      color: AppColors.baseGrey,
                      size: 20,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 70,
                  height: 70,
                  color: AppColors.basePaleGrey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SvgPicture.asset(
                      'assets/icons/image.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        AppColors.baseGrey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Property details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Code
                  Text(
                    '${AppLocalizations.of(context).labelCode}: ${property.id != null ? AppUtils.generatePropertyCode(property) : "???"}',
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Title
                  Text(
                    property.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.anuphan(
                      color: const Color(0xFF181D27),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Location
                  Text(
                    property.address ?? '',
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseDarkGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Status badge and edit button
                  Row(
                    children: [
                      PropertyStatusBadge(
                        status: property.approvalStatus,
                        isDraft: property.isDraft,
                      ),
                      if (property.allowAgentRepresentation) ...[
                        const SizedBox(width: 8),
                        AppBadge(
                          label: AppLocalizations.of(
                            context,
                          ).allowAgentRepresentationLabel,
                          color: BadgeColor.blue,
                          style: BadgeStyle.plain,
                          hasBorder: false,
                          fontSize: 12,
                        ),
                      ],
                      if (onEdit != null) ...[
                        Spacer(),
                        GestureDetector(
                          onTap: onEdit,
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: SvgPicture.asset(
                              'assets/icons/edit.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.baseDarkGrey,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
