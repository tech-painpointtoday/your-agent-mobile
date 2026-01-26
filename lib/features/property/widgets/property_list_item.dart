import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/core/theme/app_colors.dart';
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
      onTap: onTap,
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
                imageUrl: property.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 70,
                  height: 70,
                  color: AppColors.gray100,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.gray400,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 70,
                  height: 70,
                  color: AppColors.gray100,
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.gray400,
                    size: 32,
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
                    'รหัส: ${property.code}',
                    style: GoogleFonts.anuphan(
                      color: AppColors.gray400,
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
                    property.location,
                    style: GoogleFonts.anuphan(
                      color: AppColors.gray500,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Status badge and edit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PropertyStatusBadge(status: property.status),
                      if (onEdit != null)
                        GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: AppColors.gray500,
                            ),
                          ),
                        ),
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
