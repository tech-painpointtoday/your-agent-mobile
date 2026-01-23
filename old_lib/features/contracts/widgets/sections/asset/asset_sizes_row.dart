import 'package:flutter/material.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/form_fields/app_form_number_field.dart';

class AssetSizesRow extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController parkingController;
  final TextEditingController landSizeController;
  final TextEditingController usableAreaController;

  const AssetSizesRow({
    super.key,
    required this.l10n,
    required this.parkingController,
    required this.landSizeController,
    required this.usableAreaController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppFormNumberField(
            controller: parkingController,
            label: l10n.parking_spaces,
            enable: false,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppFormNumberField(
            controller: landSizeController,
            label: l10n.land_size,
            enable: false,
            isDecimal: true,
            suffixText: l10n.sq_wa,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppFormNumberField(
            controller: usableAreaController,
            label: l10n.usable_area,
            enable: false,
            isDecimal: true,
            suffixText: l10n.sq_m,
            l10n: l10n,
            isReadOnly: true,
            isRequired: false,
          ),
        ),
        const SizedBox(width: 16),
        const Spacer(),
      ],
    );
  }
}

