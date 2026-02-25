enum BookingStatus {
  pending,
  confirm,
  reject,
  expired,
  cancelled,
  met,
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
        return BookingStatus.expired;
      case 4:
        return BookingStatus.cancelled;
      case 5:
        return BookingStatus.met;
      case 6:
        return BookingStatus.offer;
      case 7:
        return BookingStatus.contract;
      case 8:
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
      case BookingStatus.expired:
        return 3;
      case BookingStatus.cancelled:
        return 4;
      case BookingStatus.met:
        return 5;
      case BookingStatus.offer:
        return 6;
      case BookingStatus.contract:
        return 7;
      case BookingStatus.closeDeal:
        return 8;
    }
  }
}
