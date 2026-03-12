import 'package:equatable/equatable.dart';

abstract class AvailabilityEvent extends Equatable {
  const AvailabilityEvent();

  @override
  List<Object?> get props => [];
}

class FetchAvailability extends AvailabilityEvent {
  final DateTime? date;
  final bool forceRefresh;

  const FetchAvailability({this.date, this.forceRefresh = false});

  @override
  List<Object?> get props => [date, forceRefresh];
}

class LoadMoreAvailability extends AvailabilityEvent {
  const LoadMoreAvailability();
}

class CreateAvailability extends AvailabilityEvent {
  final DateTime date;
  final String startTime;
  final String endTime;

  const CreateAvailability({
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [date, startTime, endTime];
}

class AvailabilitySlotRange extends Equatable {
  final String startTime;
  final String endTime;

  const AvailabilitySlotRange({required this.startTime, required this.endTime});

  @override
  List<Object?> get props => [startTime, endTime];
}

class CreateAvailabilitySlots extends AvailabilityEvent {
  final DateTime date;
  final List<AvailabilitySlotRange> slots;

  const CreateAvailabilitySlots({required this.date, required this.slots});

  @override
  List<Object?> get props => [date, slots];
}

class UpdateAvailability extends AvailabilityEvent {
  final int id;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  const UpdateAvailability({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [id, startTime, endTime, isAvailable];
}

class DeleteAvailability extends AvailabilityEvent {
  final int id;

  const DeleteAvailability({required this.id});

  @override
  List<Object?> get props => [id];
}
