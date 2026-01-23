import 'package:flutter/material.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/form_fields/app_form_dropdown_field.dart';

class AssetLocationRow extends StatelessWidget {
  final AppLocalizations l10n;
  final String? selectedCountry;
  final String? selectedProvince;
  final String? selectedDistrict;
  final String? selectedSubdistrict;

  const AssetLocationRow({
    super.key,
    required this.l10n,
    required this.selectedCountry,
    required this.selectedProvince,
    required this.selectedDistrict,
    required this.selectedSubdistrict,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppFormDropdownField<String>(
            label: l10n.country,
            value: selectedCountry,
            enable: false,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
            items: const [
              DropdownMenuItem<String>(value: 'ไทย', child: Text('ไทย')),
            ],
            onChanged: (_) {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppFormDropdownField<String>(
            label: l10n.state,
            value: selectedProvince,
            enable: false,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
            items: const [],
            onChanged: (_) {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppFormDropdownField<String>(
            label: l10n.district,
            value: selectedDistrict,
            enable: false,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
            items: const [],
            onChanged: (_) {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppFormDropdownField<String>(
            label: l10n.subdistrict,
            value: selectedSubdistrict,
            enable: false,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
            items: const [],
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }
}

