import 'package:youragent/l10n/app_localizations.dart';

/// Property Type enum
/// API uses lowercase keys
enum PropertyType {
  house('house'),
  condominium('condominium'),
  townhouse('townhouse'),
  villa('villa'),
  duplex('duplex'),
  penthouse('penthouse'),
  studio('studio'),
  commercial('commercial'),
  land('land'),
  other('other');

  /// API value (lowercase)
  final String apiValue;

  const PropertyType(this.apiValue);

  /// Get display label using AppLocalizations
  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case PropertyType.house:
        return l10n.property_type_house;
      case PropertyType.condominium:
        return l10n.property_type_condominium;
      case PropertyType.townhouse:
        return l10n.property_type_townhouse;
      case PropertyType.villa:
        return l10n.property_type_villa;
      case PropertyType.duplex:
        return l10n.property_type_duplex;
      case PropertyType.penthouse:
        return l10n.property_type_penthouse;
      case PropertyType.studio:
        return l10n.property_type_studio;
      case PropertyType.commercial:
        return l10n.property_type_commercial;
      case PropertyType.land:
        return l10n.property_type_land;
      case PropertyType.other:
        return l10n.property_type_other;
    }
  }

  /// Create PropertyType from API value
  static PropertyType? fromApiValue(String? value) {
    if (value == null || value.isEmpty) return null;
    return PropertyType.values.firstWhere((t) => t.apiValue == value.toLowerCase(), orElse: () => PropertyType.other);
  }

  /// Create PropertyType from API value with default
  static PropertyType fromApiValueOrDefault(String? value, {PropertyType defaultValue = PropertyType.house}) {
    if (value == null || value.isEmpty) return defaultValue;
    return PropertyType.values.firstWhere((t) => t.apiValue == value.toLowerCase(), orElse: () => defaultValue);
  }
}
