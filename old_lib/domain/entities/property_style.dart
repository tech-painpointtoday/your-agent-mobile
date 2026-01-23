import 'package:youragent/l10n/app_localizations.dart';

/// Property Style enum
/// API uses lowercase keys
enum PropertyStyle {
  modern('modern', 'โมเดิร์น', 'Modern'),
  minimalist('minimalist', 'มินิมอล', 'Minimalist'),
  loft('loft', 'ลอฟท์', 'Loft'),
  contemporary('contemporary', 'ร่วมสมัย', 'Contemporary'),
  luxury('luxury', 'หรูหรา', 'Luxury'),
  classic('classic', 'คลาสสิค', 'Classic'),
  tropical('tropical', 'ทรอปิคอล', 'Tropical'),
  industrial('industrial', 'อินดัสเทรียล', 'Industrial'),
  scandinavian('scandinavian', 'สแกนดิเนเวียน', 'Scandinavian'),
  thai('thai', 'ไทยประยุกต์', 'Thai Style');

  /// API value (lowercase)
  final String apiValue;

  /// Thai label for UI display
  final String labelTh;

  /// English label for UI display
  final String labelEn;

  const PropertyStyle(this.apiValue, this.labelTh, this.labelEn);

  /// Get display label using AppLocalizations (Keys not available yet, using hardcoded)
  String getLabel(AppLocalizations l10n) {
    // Ideally use l10n keys here. For now, returning hardcoded strings.
    // We maintain this signature for consistency with other Enums.
    return labelTh;
  }

  /// Create PropertyStyle from API value
  static PropertyStyle? fromApiValue(String? value) {
    if (value == null || value.isEmpty) return null;
    return PropertyStyle.values.firstWhere(
      (s) => s.apiValue == value.toLowerCase(),
      orElse: () => PropertyStyle.modern,
    );
  }

  /// Create PropertyStyle from API value with default
  static PropertyStyle fromApiValueOrDefault(String? value, {PropertyStyle defaultValue = PropertyStyle.modern}) {
    if (value == null || value.isEmpty) return defaultValue;
    return PropertyStyle.values.firstWhere((s) => s.apiValue == value.toLowerCase(), orElse: () => defaultValue);
  }
}
