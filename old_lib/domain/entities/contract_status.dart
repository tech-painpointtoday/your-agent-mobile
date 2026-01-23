/// Contract Status enum
/// API uses: 'draft', 'pending_signature', 'signed', 'completed', 'cancelled'
enum ContractStatus {
  draft('draft'),
  pendingSignature('pending_signature'),
  signed('signed'),
  completed('completed'),
  cancelled('cancelled');

  /// API value (lowercase with underscore)
  final String apiValue;

  const ContractStatus(this.apiValue);

  /// Get Thai display label
  String getLabel() {
    switch (this) {
      case ContractStatus.draft:
        return 'ยังไม่สมบูรณ์';
      case ContractStatus.pendingSignature:
        return 'รอการลงนาม';
      case ContractStatus.signed:
      case ContractStatus.completed:
        return 'สมบูรณ์';
      case ContractStatus.cancelled:
        return 'ยกเลิก';
    }
  }

  /// Create ContractStatus from API value
  static ContractStatus? fromApiValue(String? value) {
    if (value == null || value.isEmpty) return null;
    final normalized = value.toLowerCase();
    try {
      return ContractStatus.values.firstWhere(
        (s) => s.apiValue == normalized,
      );
    } catch (e) {
      // Legacy support for old status values
      switch (normalized) {
        case 'active':
          return ContractStatus.signed;
        case 'rejected':
        case 'terminated':
          return ContractStatus.cancelled;
        default:
          return null;
      }
    }
  }

  /// Create ContractStatus from API value with default
  static ContractStatus fromApiValueOrDefault(
    String? value, {
    ContractStatus defaultValue = ContractStatus.draft,
  }) {
    if (value == null || value.isEmpty) return defaultValue;
    return fromApiValue(value) ?? defaultValue;
  }
}
