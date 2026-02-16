import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/domain/entities/contract.dart';

class AppUtils {
  /// Generate a human‑readable unique code for a property.
  ///
  /// Format: YH + YY + typeDigit + 6‑digit ID
  /// - typeDigit: 1 = buy (sale), 2 = rent, 3 = all/unknown.
  static String generatePropertyCode(Property property) {
    // Brand prefix
    const prefix = 'YH';

    // Get year from createdAt or use current year
    final year = property.createdAt.year;
    // Get last 2 digits of year
    final yearSuffix = (year % 100).toString().padLeft(2, '0');

    // Map listing type to numeric code:
    // 1 = buy (sale), 2 = rent, 3 = all (sale_and_rent or unknown)
    final typeDigit = switch (property.listingType) {
      PropertyListingType.sale => '1',
      PropertyListingType.rent => '2',
      PropertyListingType.saleAndRent => '3',
      null => '3', // default to "all" when type is missing
    };

    // Format property ID to 6 digits with leading zeros to keep uniqueness
    final propertyIdFormatted = (property.id ?? 0).toString().padLeft(6, '0');

    // Final format: YH + YY + typeDigit + propertyId
    return '$prefix$yearSuffix$typeDigit$propertyIdFormatted';
  }

  /// Generate a human‑readable code for a contract.
  ///
  /// Format: YH + YY + typeDigit + 6‑digit ID
  /// - typeDigit: 1 = buy, 2 = rent, 3 = unknown/other.
  static String generateContractCode(Contract contract) {
    // 5‑digit zero‑padded ID
    final idFormatted = (contract.id ?? 0).toString().padLeft(5, '0');

    // Use createdAt first, then contractDate, then current date
    final baseDate =
        contract.createdAt ?? contract.contractDate ?? DateTime.now();
    final yearSuffix = (baseDate.year % 100).toString().padLeft(2, '0');
    final month = baseDate.month.toString().padLeft(2, '0');
    final day = baseDate.day.toString().padLeft(2, '0');

    return '$idFormatted$yearSuffix$month$day';
  }

  /// Format lease duration in months and days accurately based on calendar.
  /// Treats the end date as inclusive.
  static String formatLeaseDuration(DateTime? start, DateTime? end) {
    if (start == null || end == null) return '';

    // Add 1 day to make the range inclusive for calculation
    final inclusiveEnd = end.add(const Duration(days: 1));

    int years = inclusiveEnd.year - start.year;
    int months = inclusiveEnd.month - start.month;
    //int days = inclusiveEnd.day - start.day;

    // if (days < 0) {
    //   months -= 1;
    //   // Get the number of days in the month before inclusiveEnd
    //   final prevMonthEnd = DateTime(inclusiveEnd.year, inclusiveEnd.month, 0);
    //   days += prevMonthEnd.day;
    // }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final totalMonths = (years * 12) + months;

    final List<String> parts = [];
    if (totalMonths > 0) {
      parts.add('$totalMonths เดือน');
    }
    // if (days > 0) {
    //   parts.add('$days วัน');
    // }

    return parts.join(' ');
  }
}
