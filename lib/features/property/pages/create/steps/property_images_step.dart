import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/property/bloc/property_form/property_form_bloc.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';
import 'package:youragent/widgets/painters/dashed_border_painter.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';

class PropertyImagesStep extends StatelessWidget {
  final int? step;
  const PropertyImagesStep({super.key, this.step});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyFormBloc, PropertyFormState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      AppLocalizations.of(context).propertyImagesLabel,
                      style: GoogleFonts.anuphan(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (step != null)
                    AppBadge(color: BadgeColor.default_, label: '$step/5'),
                ],
              ),
              const SizedBox(height: 24),

              InkWell(
                onTap: () => _showImageSourceSheet(context, state),
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: AppColors.baseLightGrey,
                    strokeWidth: 1,
                    dashWidth: 6,
                    dashSpace: 4,
                    radius: 12,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/image.svg',
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                AppColors.baseGrey,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context).uploadImagesButton,
                              style: GoogleFonts.anuphan(
                                color: AppColors.baseDarkGrey,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'อัปโหลดรูปภาพอย่างน้อย 1 รูป (JPEG, PNG, WebP)',
                  style: GoogleFonts.anuphan(
                    color: state.showErrors && state.images.isEmpty
                        ? AppColors.error
                        : AppColors.baseDarkGrey,
                    fontSize: 12,
                    fontWeight: state.showErrors && state.images.isEmpty
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (state.images.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).imageSampleLabel,
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseBlack,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: () => _showDeleteAllConfirmation(context),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/trash.svg',
                            width: 16,
                            height: 16,
                            colorFilter: const ColorFilter.mode(
                              AppColors.error,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context).deleteAllImagesButton,
                            style: GoogleFonts.anuphan(
                              color: AppColors.error,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: state.images.length,
                  itemBuilder: (context, index) {
                    final image = state.images[index];
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: image.isNetwork && image.path.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: image.path,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  )
                                : Image.file(
                                    File(image.path),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            child: Container(
                              width: double.infinity,
                              color: Colors.black.withValues(alpha: 0.5),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              child: Text(
                                image.name,
                                style: GoogleFonts.anuphan(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () {
                              _showDeleteConfirmation(context, index);
                            },
                            child: SvgPicture.asset(
                              'assets/icons/x-circle-filled.svg',
                              width: 16,
                              height: 16,
                              colorFilter: ColorFilter.mode(
                                AppColors.baseWhite,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 100),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showImageSourceSheet(BuildContext context, PropertyFormState state) {
    final bloc = context.read<PropertyFormBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 24),
                title: Text(
                  AppLocalizations.of(context).takePhotoButton,
                  style: GoogleFonts.anuphan(fontSize: 16),
                ),
                trailing: SvgPicture.asset(
                  'assets/icons/camera.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    AppColors.baseDarkGrey,
                    BlendMode.srcIn,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context); // Close the modal first

                  final status = await Permission.camera.request();
                  if (status.isPermanentlyDenied) {
                    if (context.mounted) {
                      StatusDialog.showError(
                        context: context,
                        title: AppLocalizations.of(context).errorLabel,
                        message:
                            'Camera access is permanently denied. Please enable it in settings.',
                      );
                      openAppSettings();
                    }
                    return;
                  }

                  if (!status.isGranted) {
                    if (context.mounted) {
                      StatusDialog.showError(
                        context: context,
                        title: AppLocalizations.of(context).errorLabel,
                        message:
                            'Camera access denied. Please allow camera access to take photos.',
                      );
                    }
                    return;
                  }

                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null && context.mounted) {
                    context.read<PropertyFormBloc>().add(
                      PropertyFormImagesUpdated([
                        ...state.images,
                        PropertyFormImage.fromXFile(image),
                      ]),
                    );
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 24),
                title: Text(
                  AppLocalizations.of(context).selectFromAlbumButton,
                  style: GoogleFonts.anuphan(fontSize: 16),
                ),
                trailing: SvgPicture.asset(
                  'assets/icons/image.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    AppColors.baseDarkGrey,
                    BlendMode.srcIn,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final List<XFile> images = await picker.pickMultiImage();
                  if (images.isNotEmpty) {
                    bloc.add(
                      PropertyFormImagesUpdated([
                        ...state.images,
                        ...images.map(
                          (img) => PropertyFormImage.fromXFile(img),
                        ),
                      ]),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, int index) {
    AppConfirmationBottomSheet.show(
      context: context,
      title: AppLocalizations.of(context).deleteImagesConfirmTitle,
      description: AppLocalizations.of(context).deleteImagesConfirmMessage,
      confirmLabel: AppLocalizations.of(context).deleteConfirmLabel,
      cancelLabel: AppLocalizations.of(context).statusCancelled,
      icon: 'assets/images/dialog/YA_Illustration_ConfirmDelete.png',
      style: ConfirmationStyle.destructive,
      onConfirm: () {
        context.read<PropertyFormBloc>().add(PropertyFormImageDeleted(index));
        StatusDialog.showSuccess(
          context: context,
          title: AppLocalizations.of(context).successTitle,
          message: AppLocalizations.of(context).imageDeletedMessage,
        );
      },
    );
  }

  void _showDeleteAllConfirmation(BuildContext context) {
    AppConfirmationBottomSheet.show(
      context: context,
      title: AppLocalizations.of(context).deleteAllImagesConfirmTitle,
      description: AppLocalizations.of(context).deleteAllImagesConfirmMessage,
      confirmLabel: AppLocalizations.of(context).deleteAllConfirmLabel,
      cancelLabel: AppLocalizations.of(context).statusCancelled,
      icon: 'assets/images/dialog/YA_Illustration_ConfirmDelete.png',
      style: ConfirmationStyle.destructive,
      onConfirm: () {
        context.read<PropertyFormBloc>().add(
          const PropertyFormAllImagesDeleted(),
        );
        StatusDialog.showSuccess(
          context: context,
          title: AppLocalizations.of(context).successTitle,
          message: AppLocalizations.of(context).imagesDeletedMessage,
        );
      },
    );
  }
}
