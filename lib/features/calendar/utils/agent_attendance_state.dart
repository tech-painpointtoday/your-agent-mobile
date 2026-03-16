import 'package:youragent/domain/entities/booking.dart';
import 'package:youragent/core/enums/booking_status.dart';

enum AgentAttendanceState { pending, confirmedOnDate, traveling, arrived }

AgentAttendanceState computeAgentAttendance(Booking booking) {
  if (booking.status != BookingStatus.confirm) {
    return AgentAttendanceState.pending;
  }

  final sellerAttendance = booking.attendance?.seller;

  final confirmedOnDateAt = sellerAttendance?.confirmedOnDateAt;
  final travelingAt = sellerAttendance?.travelingAt;
  final arrivedAt = sellerAttendance?.arrivedAt;

  if (confirmedOnDateAt == null &&
      travelingAt == null &&
      arrivedAt == null) {
    return AgentAttendanceState.pending;
  }

  if (confirmedOnDateAt != null &&
      travelingAt == null &&
      arrivedAt == null) {
    return AgentAttendanceState.confirmedOnDate;
  }

  if (travelingAt != null && arrivedAt == null) {
    return AgentAttendanceState.traveling;
  }

  return AgentAttendanceState.arrived;
}

