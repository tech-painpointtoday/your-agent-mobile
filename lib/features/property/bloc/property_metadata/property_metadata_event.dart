import 'package:equatable/equatable.dart';

abstract class PropertyMetadataEvent extends Equatable {
  const PropertyMetadataEvent();

  @override
  List<Object?> get props => [];
}

class LoadPropertyMetadata extends PropertyMetadataEvent {
  const LoadPropertyMetadata();
}
