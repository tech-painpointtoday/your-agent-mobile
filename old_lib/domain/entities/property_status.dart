import 'package:youragent/l10n/app_localizations.dart';

/// Property Status enum
/// API uses lowercase keys
enum PropertyStatus {
  available('available'),
  pending('pending'),
  sold('sold'),
  rented('rented');

  /// API value (lowercase)
  final String apiValue;

  const PropertyStatus(this.apiValue);

  /// Get display label using AppLocalizations
  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case PropertyStatus.available:
        return l10n.status_available;
      case PropertyStatus.pending:
        return l10n.status_pending;
      case PropertyStatus.sold:
        return l10n.status_sold;
      case PropertyStatus.rented:
        // 'rented' might not be in l10n, using fallback or closest match if available.
        // Assuming 'sold' or distinct key. If not present, I'll return a hardcoded string or reuse logic.
        // Checking arb file... 'status_sold' is 'ขายแล้ว'. 'status_available' is 'พร้อมขาย'.
        // 'rented' is NOT in the arb file I saw (only available, pending, sold).
        // I will return a hardcoded string for rented for now to avoid errors, or update arb if I could.
        return 'ปล่อยเช่าแล้ว';
    }
  }

  /// Create PropertyStatus from API value
  static PropertyStatus? fromApiValue(String? value) {
    if (value == null || value.isEmpty) return null;
    return PropertyStatus.values.firstWhere(
      (s) => s.apiValue == value.toLowerCase(),
      orElse: () => PropertyStatus.available,
    );
  }

  /// Create PropertyStatus from API value with default
  static PropertyStatus fromApiValueOrDefault(String? value, {PropertyStatus defaultValue = PropertyStatus.available}) {
    if (value == null || value.isEmpty) return defaultValue;
    return PropertyStatus.values.firstWhere((s) => s.apiValue == value.toLowerCase(), orElse: () => defaultValue);
  }
}
