import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/image_modal.dart';

/// General image upload widget for form usage
/// Displays image upload UI, existing photos grid, and new photos preview
class AppImageUploadWidget extends StatelessWidget {
  final List<XFile> newPhotos;
  final List<String>
  existingPhotoUrls; // Changed from PropertyImage to String URLs
  final bool isReadOnly;
  final VoidCallback onPickImages;
  final VoidCallback? onPickImagesFromCamera;
  final ValueChanged<int> onRemoveNewPhoto;
  final VoidCallback? onClearAllNewPhotos;
  final AppLocalizations l10n;
  final String? instructionText; // Optional custom instruction text
  final String? emptyStateMessage; // Optional custom empty state message

  const AppImageUploadWidget({
    super.key,
    required this.newPhotos,
    required this.existingPhotoUrls,
    required this.isReadOnly,
    required this.onPickImages,
    this.onPickImagesFromCamera,
    required this.onRemoveNewPhoto,
    this.onClearAllNewPhotos,
    required this.l10n,
    this.instructionText,
    this.emptyStateMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show upload instruction only in create/edit mode
        if (!isReadOnly && instructionText != null) ...[
          Text(
            instructionText!,
            style: GoogleFonts.anuphan(
              fontSize: 14,
              color: AppColors.baseDarkGrey,
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Photo upload UI - hidden in read-only mode
        if (!isReadOnly) ...[
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.supportBlueLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onPickImages,
                      icon: SvgPicture.asset(
                        'assets/icons/form/image.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          AppColors.baseWhite,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: Text(l10n.select_file),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.baseWhite,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (onPickImagesFromCamera != null) ...[
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: onPickImagesFromCamera,
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: Text(l10n.take_photo),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.baseWhite,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          elevation: 0,
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'หรือลากวางไฟล์ที่นี่\nรองรับไฟล์ JPG, PNG, WebP ขนาดไม่เกิน 5MB ต่อไฟล์',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.anuphan(
                    fontSize: 12,
                    color: AppColors.baseDarkGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Existing photos (show in edit and view mode)
        if (existingPhotoUrls.isNotEmpty) ...[
          Text(
            '${l10n.current_photos} (${existingPhotoUrls.length})',
            style: GoogleFonts.anuphan(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: existingPhotoUrls.length,
            itemBuilder: (context, index) {
              final imageUrl = existingPhotoUrls[index];
              final imageWidget = ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.basePaleGrey,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.basePaleGrey,
                    child: const Icon(Icons.error),
                  ),
                ),
              );

              // In view mode, make images clickable to show ImageModal
              if (isReadOnly) {
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => ImageModal(
                        images: existingPhotoUrls,
                        initialIndex: index,
                      ),
                    );
                  },
                  child: imageWidget,
                );
              }

              return imageWidget;
            },
          ),
          const SizedBox(height: 24),
        ],
        // New photo preview
        if (newPhotos.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ตัวอย่างรูปภาพ',
                style: GoogleFonts.anuphan(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onClearAllNewPhotos != null)
                TextButton(
                  onPressed: onClearAllNewPhotos,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/form/trash-2.svg',
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFDC2626),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ลบรูปภาพทั้งหมด',
                        style: GoogleFonts.anuphan(
                          color: const Color(0xFFDC2626),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 columns as per design image
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: newPhotos.length,
            itemBuilder: (context, index) {
              final file = newPhotos[index];
              // Extract filename
              String fileName = file.name;
              if (fileName.length > 20) {
                fileName =
                    '${fileName.substring(0, 8)}...${fileName.substring(fileName.length - 8)}';
              }

              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    kIsWeb
                        ? Image.network(
                            file.path,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey[200]),
                          )
                        : Image.file(File(file.path), fit: BoxFit.cover),
                    // Gradient overlay for text readability
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Filename at bottom
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        fileName,
                        style: GoogleFonts.anuphan(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Close button
                    if (!isReadOnly)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () => onRemoveNewPhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: AppColors.baseDarkGrey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
        // Show message when no photos in view mode
        if (isReadOnly && existingPhotoUrls.isEmpty && newPhotos.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.baseGrey),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 24,
                  color: AppColors.baseLightGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  emptyStateMessage ?? 'ไม่มีรูปภาพแนบ',
                  style: GoogleFonts.anuphan(
                    fontSize: 14,
                    color: AppColors.baseDarkGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
