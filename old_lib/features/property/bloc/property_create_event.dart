import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

/// Events for Property Create BLoC
abstract class PropertyCreateEvent extends Equatable {
  const PropertyCreateEvent();

  @override
  List<Object?> get props => [];
}

/// Submit the property creation form
class PropertyCreateSubmitted extends PropertyCreateEvent {
  final Map<String, dynamic> formData;
  final List<XFile> photos;

  const PropertyCreateSubmitted({required this.formData, required this.photos});

  @override
  List<Object?> get props => [formData, photos];
}

/// Reset the form state
class PropertyCreateReset extends PropertyCreateEvent {}
