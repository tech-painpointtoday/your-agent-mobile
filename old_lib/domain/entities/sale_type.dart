import 'package:youragent/l10n/app_localizations.dart';

/// Sale Type enum
/// API uses lowercase keys
enum SaleType {
  sale('sale', 'ขาย', 'Sale'),
  rent('rent', 'เช่า', 'Rent'),
  saleOrRent('sale_or_rent', 'ขาย/เช่า', 'Sale or Rent');

  /// API value (lowercase)
  final String apiValue;

  /// Thai label for UI display
  final String labelTh;

  /// English label for UI display
  final String labelEn;

  const SaleType(this.apiValue, this.labelTh, this.labelEn);

  /// Get display label using AppLocalizations (Keys not available yet, using hardcoded)
  String getLabel(AppLocalizations l10n) {
    // Ideally use l10n keys here. For now, returning hardcoded strings.
    return labelTh;
  }

  /// Create SaleType from API value
  static SaleType? fromApiValue(String? value) {
    if (value == null || value.isEmpty) return null;
    return SaleType.values.firstWhere((s) => s.apiValue == value.toLowerCase(), orElse: () => SaleType.sale);
  }

  /// Create SaleType from API value with default
  static SaleType fromApiValueOrDefault(String? value, {SaleType defaultValue = SaleType.sale}) {
    if (value == null || value.isEmpty) return defaultValue;
    return SaleType.values.firstWhere((s) => s.apiValue == value.toLowerCase(), orElse: () => defaultValue);
  }
}
