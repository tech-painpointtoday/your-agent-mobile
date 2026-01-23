import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

/// Events for Property Edit BLoC
abstract class PropertyEditEvent extends Equatable {
  const PropertyEditEvent();

  @override
  List<Object?> get props => [];
}

/// Load property data for editing
class PropertyEditLoad extends PropertyEditEvent {
  final int propertyId;

  const PropertyEditLoad({required this.propertyId});

  @override
  List<Object?> get props => [propertyId];
}

/// Submit the property edit form
class PropertyEditSubmitted extends PropertyEditEvent {
  final int propertyId;
  final Map<String, dynamic> formData;
  final List<XFile> photos;

  const PropertyEditSubmitted({
    required this.propertyId,
    required this.formData,
    required this.photos,
  });

  @override
  List<Object?> get props => [propertyId, formData, photos];
}

/// Reset the form state
class PropertyEditReset extends PropertyEditEvent {}
