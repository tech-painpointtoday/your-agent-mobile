/// Contract Type enum
/// API uses: 'rent', 'buy'
enum ContractType {
  rent('rent'),
  buy('buy');

  /// API value (lowercase)
  final String apiValue;

  const ContractType(this.apiValue);

  /// Get Thai display label
  String get label {
    switch (this) {
      case ContractType.rent:
        return 'เช่า';
      case ContractType.buy:
        return 'ขาย';
    }
  }

  /// Create ContractType from API value
  static ContractType? fromApiValue(String? value) {
    if (value == null || value.isEmpty) return null;
    return ContractType.values.firstWhere(
      (t) => t.apiValue == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid contract type: $value'),
    );
  }

  /// Create ContractType from API value with default
  static ContractType fromApiValueOrDefault(
    String? value, {
    ContractType defaultValue = ContractType.rent,
  }) {
    if (value == null || value.isEmpty) return defaultValue;
    try {
      return fromApiValue(value)!;
    } catch (e) {
      return defaultValue;
    }
  }
}
