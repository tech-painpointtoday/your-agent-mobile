import 'package:equatable/equatable.dart';

/// States for Property Create BLoC
abstract class PropertyCreateState extends Equatable {
  const PropertyCreateState();

  @override
  List<Object?> get props => [];
}

/// Initial state - form ready to fill
class PropertyCreateInitial extends PropertyCreateState {}

/// Submitting state - API calls in progress
class PropertyCreateSubmitting extends PropertyCreateState {}

/// Success state - property created successfully
class PropertyCreateSuccess extends PropertyCreateState {
  final int propertyId;
  final String message;

  const PropertyCreateSuccess({required this.propertyId, this.message = 'Property created successfully'});

  @override
  List<Object?> get props => [propertyId, message];
}

/// Error state - creation failed
class PropertyCreateFailure extends PropertyCreateState {
  final String error;

  const PropertyCreateFailure(this.error);

  @override
  List<Object?> get props => [error];
}
