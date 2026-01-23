import 'package:flutter/material.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/form_fields/app_form_section.dart';

import 'asset/asset_location_row.dart';
import 'asset/asset_sizes_row.dart';
import 'asset/asset_specs_row.dart';
import 'asset/asset_type_and_name_row.dart';
import 'asset/asset_unit_row.dart';

/// Extracted from `_buildAssetInfoSection` (keep flex ratios exactly).
class AssetInfoSection extends StatelessWidget {
  final AppLocalizations l10n;

  final String? selectedPropertyType;
  final String? selectedCountry;
  final String? selectedProvince;
  final String? selectedDistrict;
  final String? selectedSubdistrict;

  final TextEditingController projectNameController;
  final TextEditingController houseNumberController;
  final TextEditingController floorController;
  final TextEditingController soiController;
  final TextEditingController roadController;
  final TextEditingController postalCodeController;
  final TextEditingController bedroomsController;
  final TextEditingController bathroomsController;
  final TextEditingController parkingController;
  final TextEditingController landSizeController;
  final TextEditingController usableAreaController;

  const AssetInfoSection({
    super.key,
    required this.l10n,
    required this.selectedPropertyType,
    required this.selectedCountry,
    required this.selectedProvince,
    required this.selectedDistrict,
    required this.selectedSubdistrict,
    required this.projectNameController,
    required this.houseNumberController,
    required this.floorController,
    required this.soiController,
    required this.roadController,
    required this.postalCodeController,
    required this.bedroomsController,
    required this.bathroomsController,
    required this.parkingController,
    required this.landSizeController,
    required this.usableAreaController,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormSection(
      title: l10n.rental_property_information,
      icon: 'assets/icons/form/menu-2.svg',
      iconColor: const Color(0xFF1743C7),
      l10n: l10n,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetTypeAndNameRow(
            l10n: l10n,
            selectedPropertyType: selectedPropertyType,
            projectNameController: projectNameController,
          ),
          const SizedBox(height: 16),
          AssetUnitRow(
            l10n: l10n,
            houseNumberController: houseNumberController,
            floorController: floorController,
            soiController: soiController,
            roadController: roadController,
          ),
          const SizedBox(height: 16),
          AssetLocationRow(
            l10n: l10n,
            selectedCountry: selectedCountry,
            selectedProvince: selectedProvince,
            selectedDistrict: selectedDistrict,
            selectedSubdistrict: selectedSubdistrict,
          ),
          const SizedBox(height: 16),
          AssetSpecsRow(
            l10n: l10n,
            postalCodeController: postalCodeController,
            floorController: floorController,
            bedroomsController: bedroomsController,
            bathroomsController: bathroomsController,
          ),
          const SizedBox(height: 16),
          AssetSizesRow(
            l10n: l10n,
            parkingController: parkingController,
            landSizeController: landSizeController,
            usableAreaController: usableAreaController,
          ),
        ],
      ),
    );
  }
}

