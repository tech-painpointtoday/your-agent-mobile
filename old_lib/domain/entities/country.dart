import 'package:youragent/l10n/app_localizations.dart';

/// Country enum for property location
/// API may return country names in Thai or English
enum Country {
  thailand('thailand', 'ประเทศไทย', 'Thailand');

  /// API value (lowercase English name)
  final String apiValue;

  /// Thai label for UI display
  final String labelTh;

  /// English label for UI display
  final String labelEn;

  const Country(this.apiValue, this.labelTh, this.labelEn);

  /// Get display label using AppLocalizations
  String getLabel(AppLocalizations l10n) {
    // For now, return Thai label as default
    // Can be extended to use l10n if needed
    return labelTh;
  }

  /// Get display label in English
  String getLabelEn() {
    return labelEn;
  }

  /// Get display label in Thai
  String getLabelTh() {
    return labelTh;
  }

  /// Create Country from API value
  /// Handles both Thai and English country names
  static Country? fromApiValue(String? value) {
    if (value == null || value.isEmpty) return null;

    final normalizedValue = value.toLowerCase().trim();

    // Check against all possible values
    for (final country in Country.values) {
      if (normalizedValue == country.apiValue.toLowerCase() ||
          normalizedValue == country.labelTh.toLowerCase() ||
          normalizedValue == country.labelEn.toLowerCase()) {
        return country;
      }
    }

    // Special handling for common variations
    if (normalizedValue.contains('thai') || normalizedValue.contains('ไทย')) {
      return Country.thailand;
    }

    return null;
  }

  /// Create Country from API value with default
  static Country fromApiValueOrDefault(
    String? value, {
    Country defaultValue = Country.thailand,
  }) {
    if (value == null || value.isEmpty) return defaultValue;
    return fromApiValue(value) ?? defaultValue;
  }
}
