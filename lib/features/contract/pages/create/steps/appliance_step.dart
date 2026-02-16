import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/appliance_item.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:youragent/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/modals/app_confirmation_bottom_sheet.dart';
import 'package:youragent/widgets/painters/dashed_border_painter.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';
import 'package:youragent/widgets/inputs/app_chip_selection.dart';
import 'package:youragent/widgets/modals/app_image_picker_bottom_sheet.dart';
import 'package:youragent/l10n/app_localizations.dart';

class ApplianceStep extends StatefulWidget {
  final bool hideHeader;

  const ApplianceStep({super.key, this.hideHeader = false});

  @override
  State<ApplianceStep> createState() => _ApplianceStepState();
}

class _ApplianceStepState extends State<ApplianceStep> {
  Future<void> _pickImage(String applianceId) async {
    final bloc = context.read<ContractFormBloc>();
    AppImagePickerBottomSheet.show(
      context: context,
      isMultiImage: true,
      onImagesPicked: (paths) {
        bloc.add(ContractFormApplianceImagesAdded(applianceId, paths));
      },
    );
  }

  void _showPropertyPhotosSelection(String applianceId) {
    final bloc = context.read<ContractFormBloc>();
    final photos = bloc.state.contractCreateData?.propertyImages ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).select,
              style: GoogleFonts.anuphan(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
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
                          ContractFormAppliancePropertyImageSelected(
                            applianceId: applianceId,
                            propertyImageId: photo.id!,
                            url: photo.url!,
                          ),
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: photo.url ?? '',
                        fit: BoxFit.cover,
                        progressIndicatorBuilder: (context, url, progress) =>
                            Container(
                              color: Colors.grey[200],
                              padding: const EdgeInsets.all(32),
                              child: CircularProgressIndicator(
                                value: progress.progress,
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          padding: const EdgeInsets.all(32),
                          child: const Icon(Icons.error),
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

  void _showDeleteAllConfirmation(String applianceId) {
    AppConfirmationBottomSheet.show(
      context: context,
      title: AppLocalizations.of(context).deleteAllImagesConfirmTitle,
      description: AppLocalizations.of(context).deleteAllImagesConfirmMessage,
      confirmLabel: AppLocalizations.of(context).deleteAllConfirmLabel,
      cancelLabel: AppLocalizations.of(context).statusCancelled,
      style: ConfirmationStyle.destructive,
      onConfirm: () {
        context.read<ContractFormBloc>().add(
          ContractFormApplianceAllImagesDeleted(applianceId),
        );
        StatusDialog.showSuccess(
          context: context,
          title: AppLocalizations.of(context).successTitle,
          message: AppLocalizations.of(context).imagesDeletedMessage,
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
                        label: AppLocalizations.of(
                          context,
                        ).electrical_appliances_photos,
                        fontSize: 16,
                        color: BadgeColor.blue,
                      ),
                      AppBadge(
                        color: BadgeColor.default_,
                        fontSize: 16,
                        label: '${state.step}/7',
                      ),
                    ],
                  ),
                if (!widget.hideHeader) const SizedBox(height: 24),

                if (state.applianceItems.isEmpty)
                  _buildAddItemButton(context)
                else ...[
                  ...state.applianceItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        _ApplianceItemCard(
                          index: index + 1,
                          item: item,
                          onDelete: () {
                            if (item.hasData) {
                              AppConfirmationBottomSheet.show(
                                context: context,
                                title: AppLocalizations.of(
                                  context,
                                ).deleteItemQuestion,
                                description: AppLocalizations.of(
                                  context,
                                ).deleteAllImagesConfirmMessage,
                                confirmLabel: AppLocalizations.of(
                                  context,
                                ).delete,
                                cancelLabel: AppLocalizations.of(
                                  context,
                                ).statusCancelled,
                                style: ConfirmationStyle.destructive,
                                onConfirm: () {
                                  context.read<ContractFormBloc>().add(
                                    ContractFormApplianceRemoved(item.id),
                                  );
                                },
                              );

                              return;
                            }

                            context.read<ContractFormBloc>().add(
                              ContractFormApplianceRemoved(item.id),
                            );
                          },
                          onUpdate: (updatedItem) => context
                              .read<ContractFormBloc>()
                              .add(ContractFormApplianceUpdated(updatedItem)),
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
                            context.read<ContractFormBloc>().add(
                              ContractFormApplianceImageRemoved(item.id, path),
                            );
                          },
                          onDeleteAllImages: () =>
                              _showDeleteAllConfirmation(item.id),
                        ),
                        if (index < state.applianceItems.length - 1)
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
        const ContractFormApplianceAdded(),
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
                AppLocalizations.of(context).add_item,
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

class _ApplianceItemCard extends StatefulWidget {
  final int index;
  final ApplianceItem item;
  final VoidCallback onDelete;
  final Function(ApplianceItem) onUpdate;
  final VoidCallback onPickImage;
  final VoidCallback? onPickPropertyImage;
  final Function(String) onRemoveImage;
  final VoidCallback onDeleteAllImages;

  static const List<String> commonAppliances = [
    'ตู้เย็น',
    'ทีวี',
    'เครื่องปรับอากาศ',
    'เครื่องซักผ้า',
    'ไมโครเวฟ',
    'พัดลม',
    'เครื่องทำน้ำอุ่น',
  ];

  const _ApplianceItemCard({
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
  State<_ApplianceItemCard> createState() => _ApplianceItemCardState();
}

class _ApplianceItemCardState extends State<_ApplianceItemCard> {
  late bool _isOtherSelected;

  @override
  void initState() {
    super.initState();
    _isOtherSelected =
        widget.item.name.isNotEmpty &&
        !_ApplianceItemCard.commonAppliances.contains(widget.item.name);
  }

  @override
  void didUpdateWidget(_ApplianceItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.name != oldWidget.item.name) {
      final isCommon = _ApplianceItemCard.commonAppliances.contains(
        widget.item.name,
      );
      if (isCommon) {
        _isOtherSelected = false;
      } else if (widget.item.name.isNotEmpty) {
        _isOtherSelected = true;
      }
      // If name is empty, keep current _isOtherSelected state
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      ..._ApplianceItemCard.commonAppliances.map(
        (a) => AppChipOption(label: a, value: a),
      ),
      const AppChipOption(label: 'อื่น ๆ', value: '__other__'),
    ];

    String? selectedValue;
    if (_isOtherSelected) {
      selectedValue = '__other__';
    } else if (_ApplianceItemCard.commonAppliances.contains(widget.item.name)) {
      selectedValue = widget.item.name;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'รายการที่ ${widget.index}',
              style: GoogleFonts.anuphan(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            IconButton(
              onPressed: widget.onDelete,
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
        AppChipSelection<String>(
          label: AppLocalizations.of(context).full_name,
          isRequired: true,
          value: selectedValue,
          options: options,
          onChanged: (val) {
            setState(() {
              if (val == '__other__') {
                _isOtherSelected = true;
                // Don't clear name immediately if it was already something custom
                if (_ApplianceItemCard.commonAppliances.contains(
                  widget.item.name,
                )) {
                  widget.onUpdate(widget.item.copyWith(name: ''));
                }
              } else {
                _isOtherSelected = false;
                widget.onUpdate(widget.item.copyWith(name: val));
              }
            });
          },
        ),
        if (_isOtherSelected) ...[
          const SizedBox(height: 12),
          AppTextField(
            label: '',
            hintText: AppLocalizations.of(context).applianceExampleHint,
            controller: TextEditingController(text: widget.item.name)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: widget.item.name.length),
              ),
            onChanged: (val) {
              widget.onUpdate(widget.item.copyWith(name: val));
            },
          ),
        ],
        const SizedBox(height: 20),
        AppTextField(
          label: AppLocalizations.of(context).descriptionLabel,
          hintText: AppLocalizations.of(context).applianceDescExampleHint,
          controller: TextEditingController(text: widget.item.description ?? '')
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: (widget.item.description ?? '').length),
            ),
          onChanged: (val) =>
              widget.onUpdate(widget.item.copyWith(description: val)),
        ),
        const SizedBox(height: 24),

        if (widget.onPickPropertyImage != null) ...[
          InkWell(
            onTap: widget.onPickPropertyImage,
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
                      AppLocalizations.of(context).select,
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
        ],

        // Upload Button
        InkWell(
          onTap: widget.onPickImage,
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
                    AppLocalizations.of(context).uploadImagesButton,
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

        if (widget.item.images.isNotEmpty ||
            widget.item.existingPhotoUrls.isNotEmpty) ...[
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
                onTap: widget.onDeleteAllImages,
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
            itemCount:
                widget.item.existingPhotoUrls.length +
                widget.item.images.length,
            itemBuilder: (context, imgIndex) {
              final networkCount = widget.item.existingPhotoUrls.length;
              final isNetwork = imgIndex < networkCount;
              final path = isNetwork
                  ? widget.item.existingPhotoUrls[imgIndex]
                  : widget.item.images[imgIndex - networkCount];

              final fileName = isNetwork ? 'รูปภาพสัญญา' : path.split('/').last;

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
                        color: Colors.black.withOpacity(0.5),
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
                      onTap: () => widget.onRemoveImage(path),
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
