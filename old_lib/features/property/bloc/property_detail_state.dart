import 'package:equatable/equatable.dart';
import 'package:youragent/data/models/property_model.dart';

/// States for Property Detail BLoC
abstract class PropertyDetailState extends Equatable {
  const PropertyDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no property loaded
class PropertyDetailInitial extends PropertyDetailState {}

/// Loading state - fetching property data
class PropertyDetailLoading extends PropertyDetailState {}

/// Loaded state - property data ready for viewing
class PropertyDetailLoaded extends PropertyDetailState {
  final PropertyModel property;

  const PropertyDetailLoaded({required this.property});

  @override
  List<Object?> get props => [property];
}

/// Deleting state - delete operation in progress
class PropertyDetailDeleting extends PropertyDetailState {
  final PropertyModel property;

  const PropertyDetailDeleting({required this.property});

  @override
  List<Object?> get props => [property];
}

/// Deleted state - property deleted successfully
class PropertyDetailDeleted extends PropertyDetailState {}

/// Error state - operation failed
class PropertyDetailFailure extends PropertyDetailState {
  final String error;

  const PropertyDetailFailure(this.error);

  @override
  List<Object?> get props => [error];
}
