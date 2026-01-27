import 'package:flutter/material.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/form_fields/app_form_text_field.dart';

/// Reusable dropdown field widget for general form usage
class AppFormDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final AppLocalizations l10n;
  final bool isRequired;
  final bool isReadOnly;
  final GlobalKey<FormFieldState<dynamic>>? fieldKey;
  final bool enable;

  const AppFormDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.l10n,
    this.isRequired = true,
    required this.isReadOnly,
    this.fieldKey,
    this.enable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 8),
        MouseRegion(
          // Disable hover cursor change in read-only mode
          cursor: isReadOnly
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          child: IgnorePointer(
            // Completely ignore hover/tap in view mode
            ignoring: isReadOnly,
            child: Builder(
              builder: (fieldContext) {
                return DropdownButtonFormField<T>(
                  key: fieldKey,
                  initialValue: value,
                  items: items,
                  // Keep enabled text color even in view mode; actual interaction is blocked by IgnorePointer
                  onChanged: (enable == true) ? onChanged : null,
                  style: (enable == true)
                      ? theme.textTheme.bodyMedium
                      : theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.baseGrey,
                        ),
                  decoration: InputDecoration(
                    hintText: 'เลือก$label',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.baseGrey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.baseGrey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.baseGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: (isReadOnly == true || enable == false)
                            ? AppColors.baseGrey
                            : AppColors.primary,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.baseGrey),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    filled: (isReadOnly == true) || (enable == false),
                    fillColor: (enable == false)
                        ? AppColors.basePaleGrey
                        : (isReadOnly == true ? AppColors.white : null),
                  ),
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: (isReadOnly == true || enable == false)
                        ? AppColors.baseGrey
                        : AppColors.baseDarkGrey,
                  ),
                  menuMaxHeight: 300,
                  dropdownColor: (isReadOnly == true) ? Colors.white : null,
                  validator: (isReadOnly == true || enable == false)
                      ? null
                      : (value) {
                          if (isRequired == true && value == null) {
                            return l10n.this_field_required;
                          }
                          return null;
                        },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
