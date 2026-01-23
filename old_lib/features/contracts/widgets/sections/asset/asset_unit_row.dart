import 'package:flutter/material.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/form_fields/app_form_text_field.dart';

class AssetUnitRow extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController houseNumberController;
  final TextEditingController floorController;
  final TextEditingController soiController;
  final TextEditingController roadController;

  const AssetUnitRow({
    super.key,
    required this.l10n,
    required this.houseNumberController,
    required this.floorController,
    required this.soiController,
    required this.roadController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppFormTextField(
            controller: houseNumberController,
            label: l10n.house_or_room_number,
            enable: false,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppFormTextField(
            controller: floorController,
            label: l10n.floor_label,
            enable: false,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppFormTextField(
            controller: soiController,
            label: l10n.soi_alley_village,
            enable: false,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppFormTextField(
            controller: roadController,
            label: l10n.road_if_any,
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

