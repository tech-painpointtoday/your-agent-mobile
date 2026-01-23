import 'package:equatable/equatable.dart';

/// Events for Property Detail BLoC
abstract class PropertyDetailEvent extends Equatable {
  const PropertyDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Load property data for viewing
class PropertyDetailLoad extends PropertyDetailEvent {
  final int propertyId;

  const PropertyDetailLoad({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}

/// Delete property
class PropertyDetailDelete extends PropertyDetailEvent {
  final int propertyId;

  const PropertyDetailDelete({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}

/// Reset the state
class PropertyDetailReset extends PropertyDetailEvent {}
