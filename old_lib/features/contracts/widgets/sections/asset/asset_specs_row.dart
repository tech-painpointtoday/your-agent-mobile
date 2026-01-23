import 'package:flutter/material.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/form_fields/app_form_number_field.dart';
import 'package:youragent/widgets/form_fields/app_form_text_field.dart';

class AssetSpecsRow extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController postalCodeController;
  final TextEditingController floorController;
  final TextEditingController bedroomsController;
  final TextEditingController bathroomsController;

  const AssetSpecsRow({
    super.key,
    required this.l10n,
    required this.postalCodeController,
    required this.floorController,
    required this.bedroomsController,
    required this.bathroomsController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppFormTextField(
            controller: postalCodeController,
            label: l10n.postal_code,
            enable: false,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppFormNumberField(
            controller: floorController,
            label: 'จำนวนชั้น',
            enable: false,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppFormNumberField(
            controller: bedroomsController,
            label: l10n.bedrooms,
            enable: false,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppFormNumberField(
            controller: bathroomsController,
            label: l10n.bathrooms,
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

