import 'package:youragent/l10n/app_localizations.dart';

/// Property Color enum
/// API uses lowercase keys
enum PropertyColor {
  white('white'),
  cream('cream'),
  yellow('yellow'),
  orange('orange'),
  red('red'),
  purple('purple'),
  blue('blue'),
  green('green'),
  brown('brown'),
  gray('gray'),
  black('black');

  /// API value (lowercase)
  final String apiValue;

  const PropertyColor(this.apiValue);

  /// Get display label using AppLocalizations
  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case PropertyColor.white:
        return l10n.color_white;
      case PropertyColor.cream:
        return 'ครีม'; // Missing from l10n
      case PropertyColor.yellow:
        return l10n.color_yellow;
      case PropertyColor.orange:
        return l10n.color_orange;
      case PropertyColor.red:
        return l10n.color_red;
      case PropertyColor.purple:
        return l10n.color_purple;
      case PropertyColor.blue:
        return l10n.color_blue;
      case PropertyColor.green:
        return l10n.color_green;
      case PropertyColor.brown:
        return l10n.color_brown;
      case PropertyColor.gray:
        return l10n.color_gray;
      case PropertyColor.black:
        return l10n.color_black;
    }
  }

  /// Create PropertyColor from API value
  static PropertyColor? fromApiValue(String? value) {
    if (value == null || value.isEmpty) return null;
    return PropertyColor.values.firstWhere((c) => c.apiValue == value.toLowerCase(), orElse: () => PropertyColor.white);
  }

  /// Create PropertyColor from API value with default
  static PropertyColor fromApiValueOrDefault(String? value, {PropertyColor defaultValue = PropertyColor.white}) {
    if (value == null || value.isEmpty) return defaultValue;
    return PropertyColor.values.firstWhere((c) => c.apiValue == value.toLowerCase(), orElse: () => defaultValue);
  }
}
