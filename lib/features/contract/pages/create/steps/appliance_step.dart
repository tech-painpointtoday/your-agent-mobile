import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/domain/entities/appliance_item.dart';
import 'package:yourhome/domain/entities/contract_item_definition.dart';
import 'package:yourhome/features/contract/bloc/contract_form/contract_form_bloc.dart';
import 'package:yourhome/features/contract/bloc/contract_form/contract_form_event.dart';
import 'package:yourhome/features/contract/bloc/contract_form/contract_form_state.dart';
import 'package:yourhome/widgets/badges/app_badge.dart';
import 'package:yourhome/widgets/dialogs/status_dialog.dart';
import 'package:yourhome/widgets/modals/app_confirmation_bottom_sheet.dart';
import 'package:yourhome/widgets/painters/dashed_border_painter.dart';
import 'package:yourhome/widgets/inputs/app_text_field.dart';
import 'package:yourhome/widgets/inputs/app_chip_selection.dart';
import 'package:yourhome/widgets/modals/app_image_picker_bottom_sheet.dart';
import 'package:yourhome/core/extensions/l10n_extensions.dart';

class ApplianceStep extends StatefulWidget {
  final bool hideHeader;
  final int? step;

  const ApplianceStep({super.key, this.hideHeader = false, this.step});

  @override
  State<ApplianceStep> createState() => _ApplianceStepState();
}

class _ApplianceStepState extends State<ApplianceStep> {
  // Appliance Actions
  Future<void> _pickApplianceImage(String itemId) async {
    final bloc = context.read<ContractFormBloc>();
    AppImagePickerBottomSheet.show(
      context: context,
      isMultiImage: true,
      onImagesPicked: (paths) {
        bloc.add(ContractFormApplianceImagesAdded(itemId, paths));
      },
    );
  }

  void _showAppliancePropertyPhotosSelection(String itemId) {
    final bloc = context.read<ContractFormBloc>();
    final photos = bloc.state.contractCreateData?.propertyImages ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PropertyPhotoSelectionSheet(
        photos: photos,
        onPhotoSelected: (photo, url) {
          bloc.add(
            ContractFormAppliancePropertyImageSelected(
              applianceId: itemId,
              propertyImageId: photo.id!,
              url: url,
            ),
          );
        },
      ),
    );
  }

  void _showApplianceDeleteAllConfirmation(String itemId) {
    AppConfirmationBottomSheet.show(
      context: context,
      title: context.l10n.deleteAllImagesConfirmTitle,
      description: context.l10n.deleteAllImagesConfirmMessage,
      confirmLabel: context.l10n.deleteAllConfirmLabel,
      cancelLabel: context.l10n.statusCancelled,
      style: ConfirmationStyle.destructive,
      onConfirm: () {
        context.read<ContractFormBloc>().add(
          ContractFormApplianceAllImagesDeleted(itemId),
        );
        StatusDialog.showSuccess(
          context: context,
          title: context.l10n.successTitle,
          message: context.l10n.imagesDeletedMessage,
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
                        label: context.l10n.applianceTitle,
                        fontSize: 16,
                        color: BadgeColor.blue,
                      ),
                      if (widget.step != null)
                        Row(
                          children: [
                            AppBadge(
                              style: BadgeStyle.plain,
                              color: BadgeColor.default_,
                              label: context.l10n.skip,
                              onDismiss: () {
                                context.read<ContractFormBloc>().add(
                                  ContractFormStepChanged(widget.step! + 1),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            AppBadge(
                              color: BadgeColor.default_,
                              fontSize: 16,
                              label: '${widget.step}/8',
                            ),
                          ],
                        )
                      else
                        AppBadge(
                          color: BadgeColor.default_,
                          fontSize: 16,
                          label: '${state.step}/8',
                        ),
                    ],
                  ),
                if (!widget.hideHeader) const SizedBox(height: 32),

                // Appliances Section
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
                          itemDefinitions:
                              state.itemDefinitions?.appliances ?? [],
                          onUpdate: (updatedItem) {
                            context.read<ContractFormBloc>().add(
                              ContractFormApplianceUpdated(updatedItem),
                            );
                          },
                          onDelete: () {
                            if (item.hasData) {
                              AppConfirmationBottomSheet.show(
                                context: context,
                                title: context.l10n.deleteItemQuestion,
                                description:
                                    context.l10n.deleteAllImagesConfirmMessage,
                                confirmLabel: context.l10n.delete,
                                cancelLabel: context.l10n.statusCancelled,
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
                          onPickImage: () => _pickApplianceImage(item.id),
                          onPickPropertyImage:
                              (state
                                      .contractCreateData
                                      ?.propertyImages
                                      .isNotEmpty ??
                                  false)
                              ? () => _showAppliancePropertyPhotosSelection(
                                  item.id,
                                )
                              : null,
                          onRemoveImage: (path) {
                            context.read<ContractFormBloc>().add(
                              ContractFormApplianceImageRemoved(item.id, path),
                            );
                          },
                          onDeleteAllImages: () =>
                              _showApplianceDeleteAllConfirmation(item.id),
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
                context.l10n.add_item,
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

class _PropertyPhotoSelectionSheet extends StatelessWidget {
  final List<dynamic> photos;
  final Function(dynamic photo, String url) onPhotoSelected;

  const _PropertyPhotoSelectionSheet({
    required this.photos,
    required this.onPhotoSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            context.l10n.selectImageFromProperty,
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
                    final url = photo.url ?? photo.displayUrl;
                    if (photo.id != null && url.isNotEmpty) {
                      onPhotoSelected(photo, url);
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
                            child: const SpinKitFadingCircle(
                              color: AppColors.primary,
                              size: 24,
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
    );
  }
}

class _ApplianceItemCard extends StatefulWidget {
  final int index;
  final ApplianceItem item;
  final List<ContractItemDefinition> itemDefinitions;
  final VoidCallback onDelete;
  final Function(ApplianceItem) onUpdate;
  final VoidCallback onPickImage;
  final VoidCallback? onPickPropertyImage;
  final Function(String) onRemoveImage;
  final VoidCallback onDeleteAllImages;

  const _ApplianceItemCard({
    required this.index,
    required this.item,
    required this.itemDefinitions,
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
    _isOtherSelected = _checkIsOtherSelected();
  }

  bool _isOther(ContractItemDefinition d) {
    final val = d.value.toLowerCase();
    return val == 'other' ||
        val == 'อื่นๆ' ||
        d.labelEn.toLowerCase() == 'other' ||
        d.labelTh == 'อื่น ๆ' ||
        (widget.itemDefinitions.isNotEmpty &&
            d.value == widget.itemDefinitions.last.value &&
            (d.labelEn.toLowerCase().contains('other') ||
                d.labelTh.contains('อื่น')));
  }

  bool _checkIsOtherSelected() {
    final itemCode = widget.item.itemCode;

    // Check if itemCode matches any definition that is "Other"
    if (itemCode != null) {
      final definition = widget.itemDefinitions
          .cast<ContractItemDefinition?>()
          .firstWhere((d) => d?.value == itemCode, orElse: () => null);
      if (definition != null && _isOther(definition)) {
        return true;
      }
    }

    // If it has a name but no itemCode, check if it's NOT a predefined item
    if (widget.item.name.isNotEmpty && itemCode == null) {
      final matchesAny = widget.itemDefinitions.any(
        (d) =>
            !_isOther(d) &&
            (d.labelEn == widget.item.name ||
                d.labelTh == widget.item.name ||
                d.value == widget.item.name),
      );
      return !matchesAny;
    }

    return false;
  }

  @override
  void didUpdateWidget(_ApplianceItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.name != oldWidget.item.name ||
        widget.item.itemCode != oldWidget.item.itemCode ||
        widget.itemDefinitions != oldWidget.itemDefinitions) {
      _isOtherSelected = _checkIsOtherSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = Localizations.localeOf(context).languageCode;

    final options = widget.itemDefinitions.map((d) {
      final label = currentLanguage == 'en' ? d.labelEn : d.labelTh;
      return AppChipOption(label: label, value: d.value);
    }).toList();

    String? selectedValue;
    if (widget.item.itemCode != null) {
      selectedValue = widget.item.itemCode;
    } else if (widget.item.name.isNotEmpty) {
      final definition = widget.itemDefinitions
          .cast<ContractItemDefinition?>()
          .firstWhere(
            (d) =>
                d?.labelEn == widget.item.name ||
                d?.labelTh == widget.item.name ||
                d?.value == widget.item.name,
            orElse: () => null,
          );
      if (definition != null) {
        selectedValue = definition.value;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.itemNumber(widget.index),
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
          label: context.l10n.applianceTitle,
          isRequired: true,
          value: selectedValue,
          options: options,
          onChanged: (val) {
            setState(() {
              final definition = widget.itemDefinitions.firstWhere(
                (d) => d.value == val,
              );
              final isOtherSelected = _isOther(definition);

              if (isOtherSelected) {
                _isOtherSelected = true;
                // If switching to "Other", clear name but keep itemCode
                widget.onUpdate(
                  widget.item.copyWith(name: '', itemCode: definition.value),
                );
              } else {
                _isOtherSelected = false;
                final label = currentLanguage == 'en'
                    ? definition.labelEn
                    : definition.labelTh;
                widget.onUpdate(
                  widget.item.copyWith(name: label, itemCode: definition.value),
                );
              }
            });
          },
        ),
        if (_isOtherSelected) ...[
          const SizedBox(height: 12),
          AppTextField(
            label: '',
            hintText: context.l10n.applianceExampleHint,
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
          label: context.l10n.descriptionLabel,
          hintText: context.l10n.applianceDescExampleHint,
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
                      context.l10n.selectImageFromProperty,
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
                    context.l10n.uploadImagesButton,
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
                context.l10n.imageSampleLabel,
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
                      context.l10n.deleteAllImagesButton,
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
                          ? CachedNetworkImage(
                              imageUrl: path,
                              fit: BoxFit.cover,
                      progressIndicatorBuilder:
                          (context, url, progress) => const Center(
                            child: SpinKitFadingCircle(
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                              errorWidget: (context, url, error) => Container(
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
