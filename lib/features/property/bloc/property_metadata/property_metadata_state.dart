import 'package:equatable/equatable.dart';
import 'package:youragent/data/models/property_specification_filters.dart';
import 'package:youragent/data/models/developer_model.dart';
import 'package:youragent/data/models/condo_project_model.dart';

enum PropertyMetadataStatus { initial, loading, success, failure }

class PropertyMetadataState extends Equatable {
  final PropertyMetadataStatus status;
  final PropertySpecificationFilters? specificationFilters;
  final List<Developer> developers;
  final List<CondoProject> condoProjects;
  final String? error;

  const PropertyMetadataState({
    this.status = PropertyMetadataStatus.initial,
    this.specificationFilters,
    this.developers = const [],
    this.condoProjects = const [],
    this.error,
  });

  PropertyMetadataState copyWith({
    PropertyMetadataStatus? status,
    PropertySpecificationFilters? specificationFilters,
    List<Developer>? developers,
    List<CondoProject>? condoProjects,
    String? error,
  }) {
    return PropertyMetadataState(
      status: status ?? this.status,
      specificationFilters: specificationFilters ?? this.specificationFilters,
      developers: developers ?? this.developers,
      condoProjects: condoProjects ?? this.condoProjects,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    specificationFilters,
    developers,
    condoProjects,
    error,
  ];
}
