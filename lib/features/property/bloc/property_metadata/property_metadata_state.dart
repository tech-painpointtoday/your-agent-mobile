import 'package:equatable/equatable.dart';
import 'package:youragent/data/models/property_specification_filters.dart';

enum PropertyMetadataStatus { initial, loading, success, failure }

class PropertyMetadataState extends Equatable {
  final PropertyMetadataStatus status;
  final PropertySpecificationFilters? specificationFilters;
  final String? error;

  const PropertyMetadataState({
    this.status = PropertyMetadataStatus.initial,
    this.specificationFilters,
    this.error,
  });

  PropertyMetadataState copyWith({
    PropertyMetadataStatus? status,
    PropertySpecificationFilters? specificationFilters,
    String? error,
  }) {
    return PropertyMetadataState(
      status: status ?? this.status,
      specificationFilters: specificationFilters ?? this.specificationFilters,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, specificationFilters, error];
}
