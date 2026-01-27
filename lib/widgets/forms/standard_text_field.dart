import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'form_label.dart';

class StandardTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final bool isRequired;
  final bool isReadOnly;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;
  final Widget? suffixIcon;
  final String? suffix; // Text suffix like "บาท/เดือน"
  final void Function(String)? onChanged;

  const StandardTextField({
    super.key,
    required this.label,
    this.hintText,
    this.initialValue,
    this.controller,
    this.isRequired = true,
    this.isReadOnly = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
    this.suffixIcon,
    this.suffix,
    this.onChanged,
  }) : assert(
         controller == null || initialValue == null,
         'Cannot provide both controller and initialValue',
       );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormLabel(label: label, isRequired: isRequired),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          readOnly: isReadOnly,
          enabled: !isReadOnly,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator:
              validator ??
              (value) {
                if (isRequired && (value == null || value.isEmpty)) {
                  return AppLocalizations.of(context)?.field_required;
                }
                return null;
              },
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isReadOnly ? AppColors.baseDarkGrey : AppColors.baseDarkGrey,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.baseGrey),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: isReadOnly ? AppColors.basePaleGrey : AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.baseGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.baseGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.baseGrey),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.supportRedDeep),
            ),
            suffixIcon: suffixIcon,
            suffix: suffix != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      suffix!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.baseDarkGrey,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
