import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/utils/permission_helper.dart';

import 'package:youragent/l10n/app_localizations.dart';

class AppImagePickerBottomSheet extends StatelessWidget {
  final Function(List<String> paths) onImagesPicked;
  final bool isMultiImage;

  const AppImagePickerBottomSheet({
    super.key,
    required this.onImagesPicked,
    this.isMultiImage = false,
  });

  static Future<void> show({
    required BuildContext context,
    required Function(List<String> paths) onImagesPicked,
    bool isMultiImage = false,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => AppImagePickerBottomSheet(
        onImagesPicked: onImagesPicked,
        isMultiImage: isMultiImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ImagePicker picker = ImagePicker();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.baseLightGrey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            title: Text(
              AppLocalizations.of(context).takePhotoButton,
              style: GoogleFonts.anuphan(fontSize: 16),
            ),
            trailing: SvgPicture.asset(
              'assets/icons/camera.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.baseDarkGrey,
                BlendMode.srcIn,
              ),
            ),
            onTap: () async {
              final hasPermission = await PermissionHelper.ensureCameraReady(
                context,
              );
              if (!hasPermission) return;

              if (context.mounted) Navigator.pop(context);
              final XFile? image = await picker.pickImage(
                source: ImageSource.camera,
                maxWidth: 1920,
                maxHeight: 1920,
                imageQuality: 80,
              );
              if (image != null) {
                onImagesPicked([image.path]);
              }
            },
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            title: Text(
              AppLocalizations.of(context).selectFromAlbumButton,
              style: GoogleFonts.anuphan(fontSize: 16),
            ),
            trailing: SvgPicture.asset(
              'assets/icons/image.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.baseDarkGrey,
                BlendMode.srcIn,
              ),
            ),
            onTap: () async {
              final hasPermission = await PermissionHelper.ensurePhotosReady(
                context,
              );
              if (!hasPermission) return;

              if (context.mounted) Navigator.pop(context);
              if (isMultiImage) {
                final List<XFile> images = await picker.pickMultiImage(
                  maxWidth: 1920,
                  maxHeight: 1920,
                  imageQuality: 80,
                );
                if (images.isNotEmpty) {
                  onImagesPicked(images.map((img) => img.path).toList());
                }
              } else {
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1920,
                  maxHeight: 1920,
                  imageQuality: 80,
                );
                if (image != null) {
                  onImagesPicked([image.path]);
                }
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
