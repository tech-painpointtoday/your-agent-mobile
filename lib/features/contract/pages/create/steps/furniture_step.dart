import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/furniture_item.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';
import 'package:youragent/widgets/painters/dashed_border_painter.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/l10n/app_localizations.dart';

class FurnitureStep extends StatefulWidget {
  final bool hideHeader;

  const FurnitureStep({super.key, this.hideHeader = false});

  @override
  State<FurnitureStep> createState() => _FurnitureStepState();
}

class _FurnitureStepState extends State<FurnitureStep> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(String furnitureId) async {
    final bloc = context.read<ContractFormBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(
                AppLocalizations.of(context)!.takePhotoButton,
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
                Navigator.pop(sheetContext);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  debugPrint('Picked image (Camera): ${image.path}');
                  bloc.add(
                    ContractFormFurnitureImagesAdded(furnitureId, [image.path]),
                  );
                }
              },
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(
                AppLocalizations.of(context)!.selectFromAlbumButton,
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
                Navigator.pop(sheetContext);
                final List<XFile> images = await _picker.pickMultiImage();
                if (images.isNotEmpty) {
                  debugPrint('Picked ${images.length} images from gallery');
                  bloc.add(
                    ContractFormFurnitureImagesAdded(
                      furnitureId,
                      images.map((img) => img.path).toList(),
                    ),
                  );
                }
              },
            ),
            if (bloc.state.contractCreateData != null &&
                bloc.state.contractCreateData!.propertyImages.isNotEmpty)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text(
                  AppLocalizations.of(context)!.select,
                  style: GoogleFonts.anuphan(fontSize: 16),
                ),
                trailing: SvgPicture.asset(
                  'assets/icons/home.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.baseDarkGrey,
                    BlendMode.srcIn,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showPropertyPhotosSelection(furnitureId);
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showPropertyPhotosSelection(String furnitureId) {
    final bloc = context.read<ContractFormBloc>();
    final photos = bloc.state.contractCreateData?.propertyImages ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.select,
              style: GoogleFonts.anuphan(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  return InkWell(
                    onTap: () {
                      if (photo.id != null && photo.url != null) {
                        bloc.add(
                          ContractFormFurniturePropertyImageSelected(
                            furnitureId: furnitureId,
                            propertyImageId: photo.id!,
                            url: photo.url!,
                          ),
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        photo.url ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showDeleteAllConfirmation(String furnitureId) {
    AppConfirmationBottomSheet.show(
      context: context,
      title: AppLocalizations.of(context)!.deleteAllImagesConfirmTitle,
      description: AppLocalizations.of(context)!.deleteAllImagesConfirmMessage,
      confirmLabel: AppLocalizations.of(context)!.deleteAllConfirmLabel,
      cancelLabel: AppLocalizations.of(context)!.statusCancelled,
      style: ConfirmationStyle.destructive,
      onConfirm: () {
        final state = context.read<ContractFormBloc>().state;
        final item = state.furnitureItems.firstWhere(
          (i) => i.id == furnitureId,
        );
        context.read<ContractFormBloc>().add(
          ContractFormFurnitureUpdated(
            item.copyWith(images: [], clearPropertyImage: true),
          ),
        );
        StatusDialog.showSuccess(
          context: context,
          title: AppLocalizations.of(context)!.successTitle,
          message: AppLocalizations.of(context)!.imagesDeletedMessage,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContractFormBloc, ContractFormState>(
      builder: (context, state) {
        return SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                if (!widget.hideHeader)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppBadge(
                        color: BadgeColor.default_,
                        label: AppLocalizations.of(context)!.furniture_photos,
                        fontSize: 16,
                      ),
                      AppBadge(
                        color: BadgeColor.default_,
                        label: '${state.step}/7',
                        fontSize: 16,
                      ),
                    ],
                  ),
                if (!widget.hideHeader) const SizedBox(height: 24),

                if (state.furnitureItems.isEmpty)
                  _buildAddItemButton(context)
                else ...[
                  ...state.furnitureItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        _FurnitureItemCard(
                          index: index + 1,
                          item: item,
                          onDelete: () {
                            if (item.hasData) {
                              AppConfirmationBottomSheet.show(
                                context: context,
                                title: AppLocalizations.of(context)!.deleteItemQuestion,
                                description:
                                    AppLocalizations.of(context)!.deleteAllImagesConfirmMessage,
                                confirmLabel: AppLocalizations.of(context)!.delete,
                                cancelLabel: AppLocalizations.of(context)!.statusCancelled,
                                style: ConfirmationStyle.destructive,
                                onConfirm: () {
                                  context.read<ContractFormBloc>().add(
                                    ContractFormFurnitureRemoved(item.id),
                                  );
                                },
                              );

                              return;
                            }

                            context.read<ContractFormBloc>().add(
                              ContractFormFurnitureRemoved(item.id),
                            );
                          },
                          onUpdate: (updatedItem) => context
                              .read<ContractFormBloc>()
                              .add(ContractFormFurnitureUpdated(updatedItem)),
                          onPickImage: () => _pickImage(item.id),
                          onPickPropertyImage:
                              (state
                                      .contractCreateData
                                      ?.propertyImages
                                      .isNotEmpty ??
                                  false)
                              ? () => _showPropertyPhotosSelection(item.id)
                              : null,
                          onRemoveImage: (path) {
                            if (path == item.existingPhotoUrl) {
                              context.read<ContractFormBloc>().add(
                                ContractFormFurnitureUpdated(
                                  item.copyWith(clearPropertyImage: true),
                                ),
                              );
                            } else {
                              context.read<ContractFormBloc>().add(
                                ContractFormFurnitureImageRemoved(
                                  item.id,
                                  path,
                                ),
                              );
                            }
                          },
                          onDeleteAllImages: () =>
                              _showDeleteAllConfirmation(item.id),
                        ),
                        if (index < state.furnitureItems.length - 1)
                          const SizedBox(height: 24),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
                  _buildAddItemButton(context),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddItemButton(BuildContext context) {
    return InkWell(
      onTap: () => context.read<ContractFormBloc>().add(
        const ContractFormFurnitureAdded(),
      ),
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, color: AppColors.baseGrey, size: 20),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.add_item,
                style: GoogleFonts.anuphan(
                  color: AppColors.baseDarkGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FurnitureItemCard extends StatelessWidget {
  final int index;
  final FurnitureItem item;
  final VoidCallback onDelete;
  final Function(FurnitureItem) onUpdate;
  final VoidCallback onPickImage;
  final VoidCallback? onPickPropertyImage;
  final Function(String) onRemoveImage;
  final VoidCallback onDeleteAllImages;

  const _FurnitureItemCard({
    required this.index,
    required this.item,
    required this.onDelete,
    required this.onUpdate,
    required this.onPickImage,
    this.onPickPropertyImage,
    required this.onRemoveImage,
    required this.onDeleteAllImages,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'รายการที่ $index',
              style: GoogleFonts.anuphan(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: SvgPicture.asset(
                'assets/icons/x-circle-filled.svg',
                colorFilter: const ColorFilter.mode(
                  AppColors.baseGrey,
                  BlendMode.srcIn,
                ),
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
        const Divider(height: 32),
        AppTextField(
          label: AppLocalizations.of(context)!.full_name,
          isRequired: true,
          hintText: AppLocalizations.of(context)!.furnitureExampleHint,
          controller: TextEditingController(text: item.name)
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: item.name.length),
            ),
          onChanged: (val) => onUpdate(item.copyWith(name: val)),
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: AppLocalizations.of(context)!.descriptionLabel,
          hintText: AppLocalizations.of(context)!.furnitureDescExampleHint,
          controller: TextEditingController(text: item.description ?? '')
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: (item.description ?? '').length),
            ),
          onChanged: (val) => onUpdate(item.copyWith(description: val)),
        ),
        const SizedBox(height: 24),

        if (onPickPropertyImage != null) ...[
          InkWell(
            onTap: onPickPropertyImage,
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: AppColors.primary,
                strokeWidth: 1,
                dashWidth: 6,
                dashSpace: 4,
                radius: 12,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/image.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.select,
                      style: GoogleFonts.anuphan(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Upload Button
        InkWell(
          onTap: onPickImage,
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
              child: Row(
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
                    AppLocalizations.of(context)!.uploadImagesButton,
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseDarkGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
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
              color: AppColors.baseDarkGrey,
              fontSize: 12,
            ),
          ),
        ),

        if (item.images.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.imageSampleLabel,
                style: GoogleFonts.anuphan(
                  color: AppColors.baseBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: onDeleteAllImages,
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
                      AppLocalizations.of(context)!.deleteAllImagesButton,
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
            itemCount:
                item.images.length + (item.existingPhotoUrl != null ? 1 : 0),
            itemBuilder: (context, imgIndex) {
              final hasExisting = item.existingPhotoUrl != null;
              final isExisting = hasExisting && imgIndex == 0;
              final path = isExisting
                  ? item.existingPhotoUrl!
                  : item.images[imgIndex - (hasExisting ? 1 : 0)];

              final isNetwork =
                  path.startsWith('http') || path.startsWith('https');
              final fileName = isExisting ? AppLocalizations.of(context)!.propertyPhotos : path.split('/').last;

              return Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: isNetwork
                          ? Image.network(
                              path,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                            )
                          : Image.file(
                              File(path),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
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
                          fileName,
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
                      onTap: () => onRemoveImage(path),
                      child: SvgPicture.asset(
                        'assets/icons/x-circle-filled.svg',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
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
        ],
      ],
    );
  }
}
