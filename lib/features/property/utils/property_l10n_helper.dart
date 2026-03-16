import 'package:flutter/material.dart';
import 'package:yourhome/domain/entities/property.dart';
import 'package:yourhome/l10n/app_localizations.dart';

class PropertyL10n {
  static String getPropertyTypeLabel(BuildContext context, PropertyType type) {
    final l10n = AppLocalizations.of(context);
    return switch (type) {
      PropertyType.house => l10n.houseType,
      PropertyType.condo => l10n.condoType,
      PropertyType.townhome => l10n.townhomeType,
      PropertyType.apartment => l10n.apartmentType,
      PropertyType.homeOffice => l10n.homeOfficeType,
      PropertyType.poolVilla => l10n.poolVillaType,
    };
  }

  static String getPropertyColorLabel(
    BuildContext context,
    PropertyColor color,
  ) {
    final l10n = AppLocalizations.of(context);
    return switch (color) {
      PropertyColor.white => l10n.colorWhite,
      PropertyColor.cream => l10n.colorCream,
      PropertyColor.grey => l10n.colorGrey,
      PropertyColor.black => l10n.colorBlack,
      PropertyColor.brown => l10n.colorBrown,
      PropertyColor.red => l10n.colorRed,
      PropertyColor.yellow => l10n.colorYellow,
      PropertyColor.green => l10n.colorGreen,
      PropertyColor.blue => l10n.colorBlue,
      PropertyColor.pink => l10n.colorPink,
      PropertyColor.purple => l10n.colorPurple,
      PropertyColor.orange => l10n.colorOrange,
    };
  }

  static String getPropertyDirectionLabel(
    BuildContext context,
    PropertyDirection direction,
  ) {
    final l10n = AppLocalizations.of(context);
    return switch (direction) {
      PropertyDirection.north => l10n.dirNorth,
      PropertyDirection.south => l10n.dirSouth,
      PropertyDirection.east => l10n.dirEast,
      PropertyDirection.west => l10n.dirWest,
      PropertyDirection.northEast => l10n.dirNorthEast,
      PropertyDirection.southEast => l10n.dirSouthEast,
      PropertyDirection.northWest => l10n.dirNorthWest,
      PropertyDirection.southWest => l10n.dirSouthWest,
    };
  }
}
