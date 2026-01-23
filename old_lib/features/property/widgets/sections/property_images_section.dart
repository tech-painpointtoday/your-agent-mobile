import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/domain/entities/property_image.dart';
import 'package:youragent/features/property/widgets/property_form_inputs.dart';
import 'package:youragent/widgets/form_fields/app_image_upload_widget.dart';

/// Property Images Section Widget
/// Displays image upload UI, existing photos grid, and new photos preview
class PropertyImagesSection extends StatelessWidget {
  final List<XFile> newPhotos;
  final List<PropertyImage> existingPhotos;
  final bool isReadOnly;
  final VoidCallback onPickImages;
  final VoidCallback onPickImagesFromCamera;
  final ValueChanged<int> onRemoveNewPhoto;
  final VoidCallback onClearAllNewPhotos;
  final AppLocalizations l10n;

  const PropertyImagesSection({
    super.key,
    required this.newPhotos,
    required this.existingPhotos,
    required this.isReadOnly,
    required this.onPickImages,
    required this.onPickImagesFromCamera,
    required this.onRemoveNewPhoto,
    required this.onClearAllNewPhotos,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    // Convert PropertyImage list to URL list for the general widget
    final existingPhotoUrls = existingPhotos.map((img) => img.displayUrl).toList();

    return PropertyFormSection(
      title: l10n.property_images_section,
      icon: 'assets/icons/form/image.svg',
      iconColor: const Color(0xFF1743C7),
      l10n: l10n,
      child: AppImageUploadWidget(
        newPhotos: newPhotos,
        existingPhotoUrls: existingPhotoUrls,
        isReadOnly: isReadOnly,
        onPickImages: onPickImages,
        onPickImagesFromCamera: onPickImagesFromCamera,
        onRemoveNewPhoto: onRemoveNewPhoto,
        onClearAllNewPhotos: onClearAllNewPhotos,
        l10n: l10n,
        instructionText: 'กรุณาอัปโหลดรูปภาพอย่างน้อย 1 รูป',
      ),
    );
  }
}
