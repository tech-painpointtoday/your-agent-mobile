import 'package:youragent/l10n/app_localizations.dart';

/// Direction enum for property facing direction
/// API uses short codes
enum Direction {
  north('N'),
  northeast('NE'),
  east('E'),
  southeast('SE'),
  south('S'),
  southwest('SW'),
  west('W'),
  northwest('NW');

  /// API value (N, NE, E, SE, S, SW, W, NW)
  final String apiValue;

  const Direction(this.apiValue);

  /// Get display label using AppLocalizations
  String getLabel(AppLocalizations l10n) {
    switch (this) {
      case Direction.north:
        return l10n.north;
      case Direction.northeast:
        return l10n.northeast;
      case Direction.east:
        return l10n.east;
      case Direction.southeast:
        return l10n.southeast;
      case Direction.south:
        return l10n.south;
      case Direction.southwest:
        return l10n.southwest;
      case Direction.west:
        return l10n.west;
      case Direction.northwest:
        return l10n.northwest;
    }
  }

  /// Create Direction from API value
  static Direction? fromApiValue(String? value) {
    if (value == null) return null;
    return Direction.values.firstWhere((d) => d.apiValue == value, orElse: () => Direction.north);
  }

  /// Create Direction from API value with default
  static Direction fromApiValueOrDefault(String? value, {Direction defaultValue = Direction.north}) {
    if (value == null || value.isEmpty) return defaultValue;
    return Direction.values.firstWhere((d) => d.apiValue == value, orElse: () => defaultValue);
  }
}
