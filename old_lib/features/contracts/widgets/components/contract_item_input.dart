import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/widgets/form_fields/app_form_text_field.dart';

import 'contract_item_photo_section.dart';

/// Widget for inputting contract items (appliances/furniture) with name, description, and photos
class ContractItemInput extends StatefulWidget {
  final int itemIndex;
  final String initialName;
  final String initialDescription;
  final List<XFile> photos;
  final bool isReadOnly;
  final AppLocalizations l10n;
  final ValueChanged<String>? onNameChanged;
  final ValueChanged<String>? onDescriptionChanged;
  final ValueChanged<List<XFile>>? onPhotosChanged;
  final VoidCallback? onRemove;

  const ContractItemInput({
    super.key,
    required this.itemIndex,
    required this.initialName,
    required this.initialDescription,
    this.photos = const [],
    required this.isReadOnly,
    required this.l10n,
    this.onNameChanged,
    this.onDescriptionChanged,
    this.onPhotosChanged,
    this.onRemove,
  });

  @override
  State<ContractItemInput> createState() => _ContractItemInputState();
}

class _ContractItemInputState extends State<ContractItemInput> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(text: widget.initialDescription);
  }

  @override
  void didUpdateWidget(covariant ContractItemInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialName != oldWidget.initialName) {
      _nameController.text = widget.initialName;
    }
    if (widget.initialDescription != oldWidget.initialDescription) {
      _descriptionController.text = widget.initialDescription;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    if (widget.isReadOnly) return;

    try {
      await StatusDialog.showLoadingWhile<void>(
        context: context,
        message: 'กำลังโหลดรูปภาพ...',
        operation: () async {
          final List<XFile> images = await _imagePicker.pickMultiImage(
            imageQuality: 85,
          );
          if (images.isEmpty || widget.onPhotosChanged == null) return;

          // Preload bytes so thumbnails are ready immediately after close
          await Future.wait(images.map((img) => img.readAsBytes()));

          final updatedPhotos = List<XFile>.from(widget.photos)..addAll(images);
          widget.onPhotosChanged!(updatedPhotos);
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  void _removePhotoAt(int index) {
    if (widget.isReadOnly || widget.onPhotosChanged == null) return;
    final updatedPhotos = List<XFile>.from(widget.photos)..removeAt(index);
    widget.onPhotosChanged!(updatedPhotos);
  }

  void _removeAllPhotos() {
    if (widget.isReadOnly || widget.onPhotosChanged == null) return;
    widget.onPhotosChanged!([]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grayBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'รายการที่ ${widget.itemIndex}',
                  style: GoogleFonts.anuphan(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.eerieBlack,
                  ),
                ),
              ),
              if (widget.onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.gray400),
                  onPressed: widget.onRemove,
                  tooltip: 'ลบรายการ',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppFormTextField(
                  controller: _nameController,
                  label: 'ชื่อ',
                  l10n: widget.l10n,
                  isReadOnly: widget.isReadOnly,
                  onChanged: widget.onNameChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormTextField(
                  controller: _descriptionController,
                  label: 'รายละเอียด',
                  l10n: widget.l10n,
                  isReadOnly: widget.isReadOnly,
                  maxLines: 1,
                  isRequired: false,
                  onChanged: widget.onDescriptionChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ContractItemPhotoSection(
            l10n: widget.l10n,
            isReadOnly: widget.isReadOnly,
            photos: widget.photos,
            onPickPhotos: _pickPhotos,
            onRemoveAllPhotos: _removeAllPhotos,
            onRemovePhotoAt: _removePhotoAt,
          ),
        ],
      ),
    );
  }
}

