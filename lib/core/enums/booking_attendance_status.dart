enum BookingAttendanceStatus {
  confirmedOnDate,
  traveling,
  arrived,
}

extension BookingAttendanceStatusApiValue on BookingAttendanceStatus {
  String get apiValue {
    switch (this) {
      case BookingAttendanceStatus.confirmedOnDate:
        return 'confirmed_on_date';
      case BookingAttendanceStatus.traveling:
        return 'traveling';
      case BookingAttendanceStatus.arrived:
        return 'arrived';
    }
  }
}

