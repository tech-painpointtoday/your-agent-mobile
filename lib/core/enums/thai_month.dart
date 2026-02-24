import 'package:flutter/material.dart';

enum ThaiMonth {
  january(1, 'มกราคม', 'January'),
  february(2, 'กุมภาพันธ์', 'February'),
  march(3, 'มีนาคม', 'March'),
  april(4, 'เมษายน', 'April'),
  may(5, 'พฤษภาคม', 'May'),
  june(6, 'มิถุนายน', 'June'),
  july(7, 'กรกฎาคม', 'July'),
  august(8, 'สิงหาคม', 'August'),
  september(9, 'กันยายน', 'September'),
  october(10, 'ตุลาคม', 'October'),
  november(11, 'พฤศจิกายน', 'November'),
  december(12, 'ธันวาคม', 'December');

  final int number;
  final String thName;
  final String enName;

  const ThaiMonth(this.number, this.thName, this.enName);

  static ThaiMonth fromNumber(int number) {
    return ThaiMonth.values.firstWhere(
      (m) => m.number == number,
      orElse: () => ThaiMonth.january,
    );
  }

  static ThaiMonth fromDateTime(DateTime date) {
    return fromNumber(date.month);
  }

  String localizedName(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'th' ? thName : enName;
  }

  String localizedNameWithYear(BuildContext context, int year) {
    final languageCode = Localizations.localeOf(context).languageCode;
    if (languageCode == 'th') {
      return '$thName ${year + 543}';
    } else {
      return '$enName $year';
    }
  }

  static List<String> getAllLocalizedNames(BuildContext context) =>
      ThaiMonth.values.map((m) => m.localizedName(context)).toList();
}
