import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/domain/entities/property_enums.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:youragent/features/property/widgets/property_form_inputs.dart';
import 'package:youragent/widgets/form_fields/app_form_text_field.dart';

/// Property Additional Details Section Widget
/// Displays PropertyStyle dropdown, multi-select tag groups, and description field
class PropertyAdditionalDetailsSection extends StatelessWidget {
  final TextEditingController descriptionController;
  final PropertyStyle? selectedPropertyStyle;
  final List<String> selectedHighlights;
  final List<String> selectedCommonAreas;
  final List<String> selectedFurniture;
  final List<String> selectedAirConditioning;
  final List<String> highlightOptions;
  final List<String> commonAreaOptions;
  final List<String> furnitureOptions;
  final List<String> airConditioningOptions;
  final bool isReadOnly;
  final AppLocalizations l10n;
  final ValueChanged<PropertyStyle?> onPropertyStyleChanged;
  final ValueChanged<List<String>> onHighlightsChanged;
  final ValueChanged<List<String>> onCommonAreasChanged;
  final ValueChanged<List<String>> onFurnitureChanged;
  final ValueChanged<List<String>> onAirConditioningChanged;
  final GlobalKey<FormFieldState<dynamic>>? descriptionFieldKey;
  final ValueChanged<String>? onDescriptionChanged;

  const PropertyAdditionalDetailsSection({
    super.key,
    required this.descriptionController,
    this.selectedPropertyStyle,
    required this.selectedHighlights,
    required this.selectedCommonAreas,
    required this.selectedFurniture,
    required this.selectedAirConditioning,
    required this.highlightOptions,
    required this.commonAreaOptions,
    required this.furnitureOptions,
    required this.airConditioningOptions,
    required this.isReadOnly,
    required this.l10n,
    required this.onPropertyStyleChanged,
    required this.onHighlightsChanged,
    required this.onCommonAreasChanged,
    required this.onFurnitureChanged,
    required this.onAirConditioningChanged,
    this.descriptionFieldKey,
    this.onDescriptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PropertyFormSection(
      title: l10n.additional_details_section,
      icon: 'assets/icons/form/menu-2.svg',
      iconColor: const Color(0xFF1743C7),
      l10n: l10n,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: สไตล์ทรัพย์ dropdown alone
          SizedBox(
            width: 248,
            child: PropertyDropdownField<PropertyStyle>(
              label: 'สไตล์ทรัพย์',
              value: selectedPropertyStyle,
              l10n: l10n,
              isRequired: false,
              isReadOnly: isReadOnly,
              items: [
                DropdownMenuItem<PropertyStyle>(
                  value: null,
                  child: Text(
                    'เลือกสไตล์',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFA4A7AE),
                    ),
                  ),
                ),
                ...PropertyStyle.values.map(
                  (style) => DropdownMenuItem(
                    value: style,
                    child: Text(
                      style.getLabel(l10n),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
              onChanged: onPropertyStyleChanged,
            ),
          ),
          const SizedBox(height: 16),
          // Row 2: จุดเด่นทรัพย์ - พื้นที่ส่วนกลาง (Side by Side)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildMultiSelectTagGroup(
                  context: context,
                  label: 'จุดเด่นทรัพย์ (เลือกได้หลายรายการ)',
                  hint: 'เลือกจุดเด่น',
                  options: highlightOptions,
                  selectedValues: selectedHighlights,
                  onChanged: onHighlightsChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMultiSelectTagGroup(
                  context: context,
                  label: 'พื้นที่ส่วนกลาง (เลือกได้หลายรายการ)',
                  hint: 'เลือกพื้นที่ส่วนกลาง',
                  options: commonAreaOptions,
                  selectedValues: selectedCommonAreas,
                  onChanged: onCommonAreasChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Row 3: เฟอร์นิเจอร์ - เครื่องปรับอากาศ (Side by Side)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildMultiSelectTagGroup(
                  context: context,
                  label: 'เฟอร์นิเจอร์ (เลือกได้หลายรายการ)',
                  hint: 'เลือกเฟอร์นิเจอร์',
                  options: furnitureOptions,
                  selectedValues: selectedFurniture,
                  onChanged: onFurnitureChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMultiSelectTagGroup(
                  context: context,
                  label: 'เครื่องปรับอากาศ (เลือกได้หลายรายการ)',
                  hint: 'เลือกเครื่องปรับอากาศ',
                  options: airConditioningOptions,
                  selectedValues: selectedAirConditioning,
                  onChanged: onAirConditioningChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // รายละเอียดเพิ่มเติม (textarea)
          AppFormTextField(
            controller: descriptionController,
            label: 'รายละเอียดเพิ่มเติม',
            maxLines: 6,
            l10n: l10n,
            isRequired: true,
            isReadOnly: isReadOnly,
            fieldKey: descriptionFieldKey,
            onChanged: isReadOnly ? null : onDescriptionChanged,
          ),
        ],
      ),
    );
  }

  /// Build multi-select tag group widget
  Widget _buildMultiSelectTagGroup({
    required BuildContext context,
    required String label,
    required String hint,
    required List<String> options,
    required List<String> selectedValues,
    required ValueChanged<List<String>> onChanged,
    bool isRequired = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 8),
        InkWell(
          onTap: isReadOnly
              ? null
              : () => _showMultiSelectDialog(
                  context,
                  label,
                  options,
                  selectedValues,
                  onChanged,
                ),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.labelLarge?.copyWith(
                color: const Color(0xFFA4A7AE),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.baseGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.baseGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isReadOnly ? AppColors.baseGrey : AppColors.primary,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.baseGrey),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              filled: isReadOnly,
              fillColor: isReadOnly ? const Color(0xFFFFFFFF) : null,
              suffixIcon: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: isReadOnly ? AppColors.baseGrey : null,
              ),
            ),
            child: selectedValues.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      hint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFA4A7AE),
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: selectedValues.map((value) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              value,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColors.buttonTextDark,
                                fontSize: 13,
                              ),
                            ),
                            if (!isReadOnly) ...[
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  final newValues = List<String>.from(
                                    selectedValues,
                                  )..remove(value);
                                  onChanged(newValues);
                                },
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.baseGrey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }

  /// Dialog to show available options for multi-select
  void _showMultiSelectDialog(
    BuildContext context,
    String title,
    List<String> options,
    List<String> currentValues,
    ValueChanged<List<String>> onChanged,
  ) {
    // Create a local mutable list for the dialog state
    final selectedOptions = List<String>.from(currentValues);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BaseStatusDialog(
              title: title,
              confirmText: 'Done',
              confirmColor: const Color(0xFF1743C7),
              isSingleAction: true,
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: options.map((option) {
                        final isSelected = selectedOptions.contains(option);
                        return FilterChip(
                          label: Text(option),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedOptions.add(option);
                              } else {
                                selectedOptions.remove(option);
                              }
                            });
                            // Update parent immediately
                            onChanged(List.from(selectedOptions));
                          },
                          backgroundColor: Colors.white,
                          selectedColor: const Color(
                            0xFF1743C7,
                          ).withValues(alpha: 0.1),
                          checkmarkColor: const Color(0xFF1743C7),
                          labelStyle: GoogleFonts.anuphan(
                            fontSize: 14,
                            color: isSelected
                                ? const Color(0xFF1743C7)
                                : AppColors.baseDarkGrey,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF1743C7)
                                  : AppColors.bonJour,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
