import 'package:flutter/material.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/form_fields/app_form_dropdown_field.dart';
import 'package:youragent/widgets/form_fields/app_form_text_field.dart';

class AssetTypeAndNameRow extends StatelessWidget {
  final AppLocalizations l10n;
  final String? selectedPropertyType;
  final TextEditingController projectNameController;

  const AssetTypeAndNameRow({
    super.key,
    required this.l10n,
    required this.selectedPropertyType,
    required this.projectNameController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: AppFormDropdownField<String>(
            label: l10n.property_type_label,
            value: selectedPropertyType,
            enable: false,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
            items: [
              DropdownMenuItem(
                value: 'condo',
                child: Text(l10n.condominium),
              ),
              DropdownMenuItem(
                value: 'house',
                child: Text(l10n.single_house),
              ),
            ],
            onChanged: (_) {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 19,
          child: AppFormTextField(
            controller: projectNameController,
            label: 'ชื่ออสังหาฯ',
            enable: false,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
          ),
        ),
      ],
    );
  }
}

