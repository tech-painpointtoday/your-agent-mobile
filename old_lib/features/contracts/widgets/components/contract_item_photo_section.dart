import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';

import 'xfile_image.dart';

class ContractItemPhotoSection extends StatelessWidget {
  final AppLocalizations l10n;
  final bool isReadOnly;
  final List<XFile> photos;
  final VoidCallback onPickPhotos;
  final VoidCallback onRemoveAllPhotos;
  final ValueChanged<int> onRemovePhotoAt;

  const ContractItemPhotoSection({
    super.key,
    required this.l10n,
    required this.isReadOnly,
    required this.photos,
    required this.onPickPhotos,
    required this.onRemoveAllPhotos,
    required this.onRemovePhotoAt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Photo Section Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รูปภาพทรัพย์',
                    style: GoogleFonts.anuphan(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.eerieBlack,
                    ),
                  ),
                  if (!isReadOnly) ...[
                    const SizedBox(height: 4),
                    Text(
                      'กรุณาอัปโหลดรูปภาพอย่างน้อย 1 รูป',
                      style: GoogleFonts.anuphan(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isReadOnly)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (photos.isNotEmpty)
                    TextButton(
                      onPressed: onRemoveAllPhotos,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error600,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.delete_outline, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'ลบรูปภาพทั้งหมด',
                            style: GoogleFonts.anuphan(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: onPickPhotos,
                      icon: const Icon(Icons.image_outlined, size: 18),
                      label: Text(
                        'เลือกไฟล์ของคุณ',
                        style: GoogleFonts.anuphan(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Photo Grid or Empty State
        if (photos.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return Stack(
                children: [
                  // Image Container
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grayBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: XFileImage(
                        file: photo,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Delete Button
                  if (!isReadOnly)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => onRemovePhotoAt(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.gray600,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  // Filename Label
                  Positioned(
                    bottom: 6,
                    left: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        photo.name.length > 20
                            ? '${photo.name.substring(0, 20)}...'
                            : photo.name,
                        style: GoogleFonts.anuphan(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        if (photos.isEmpty)
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grayBorder, width: 1.5),
              color: isReadOnly ? AppColors.white : AppColors.gray50,
            ),
            child: Center(
              child: isReadOnly
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.image_not_supported_outlined,
                          size: 24,
                          color: AppColors.gray400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.no_images,
                          style: GoogleFonts.anuphan(
                            color: AppColors.gray400,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: AppColors.gray400.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ตัวอย่างรูปภาพ',
                          style: GoogleFonts.anuphan(
                            color: AppColors.gray400,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
      ],
    );
  }
}

