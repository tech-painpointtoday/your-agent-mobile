import 'package:equatable/equatable.dart';
import 'package:youragent/data/models/property_model.dart';

/// States for Property Edit BLoC
abstract class PropertyEditState extends Equatable {
  const PropertyEditState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no property loaded
class PropertyEditInitial extends PropertyEditState {}

/// Loading state - fetching property data
class PropertyEditLoading extends PropertyEditState {}

/// Loaded state - property data ready for editing
class PropertyEditLoaded extends PropertyEditState {
  final PropertyModel property;

  const PropertyEditLoaded({required this.property});

  @override
  List<Object?> get props => [property];
}

/// Submitting state - API calls in progress
class PropertyEditSubmitting extends PropertyEditState {
  final PropertyModel property;

  const PropertyEditSubmitting({required this.property});

  @override
  List<Object?> get props => [property];
}

/// Success state - property updated successfully
class PropertyEditSuccess extends PropertyEditState {
  final int propertyId;
  final String message;

  const PropertyEditSuccess({
    required this.propertyId,
    this.message = 'Property updated successfully',
  });

  @override
  List<Object?> get props => [propertyId, message];
}

/// Error state - operation failed
class PropertyEditFailure extends PropertyEditState {
  final String error;

  const PropertyEditFailure(this.error);

  @override
  List<Object?> get props => [error];
}
