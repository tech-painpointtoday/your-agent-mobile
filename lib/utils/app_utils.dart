class AppUtils {
  static String generatePropertyCode({
    required int propertyId,
    DateTime? createdAt,
  }) {
    // Get year from createdAt or use current year
    final year = createdAt?.year ?? DateTime.now().year;
    // Get last 2 digits of year
    final yearSuffix = (year % 100).toString().padLeft(2, '0');
    // Format property ID to 6 digits with leading zeros
    final propertyIdFormatted = propertyId.toString().padLeft(6, '0');
    return 'YH$yearSuffix$propertyIdFormatted';
  }
}
