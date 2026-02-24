enum BookingStatus {
  pending,
  confirm,
  reject,
  met,
  traveling,
  arrived,
  expired,
  cancelled,
  offer,
  contract,
  closeDeal;

  static BookingStatus fromInt(int value) {
    switch (value) {
      case 0:
        return BookingStatus.pending;
      case 1:
        return BookingStatus.confirm;
      case 2:
        return BookingStatus.reject;
      case 3:
        return BookingStatus.met;
      case 4:
        return BookingStatus.traveling;
      case 5:
        return BookingStatus.arrived;
      case 6:
        return BookingStatus.expired;
      case 7:
        return BookingStatus.cancelled;
      case 8:
        return BookingStatus.offer;
      case 9:
        return BookingStatus.contract;
      case 10:
        return BookingStatus.closeDeal;
      default:
        return BookingStatus.pending;
    }
  }

  int get value {
    switch (this) {
      case BookingStatus.pending:
        return 0;
      case BookingStatus.confirm:
        return 1;
      case BookingStatus.reject:
        return 2;
      case BookingStatus.met:
        return 3;
      case BookingStatus.traveling:
        return 4;
      case BookingStatus.arrived:
        return 5;
      case BookingStatus.expired:
        return 6;
      case BookingStatus.cancelled:
        return 7;
      case BookingStatus.offer:
        return 8;
      case BookingStatus.contract:
        return 9;
      case BookingStatus.closeDeal:
        return 10;
    }
  }
}
