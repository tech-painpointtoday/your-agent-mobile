import 'package:equatable/equatable.dart';
import 'package:yourhome/data/models/property_specification_filters.dart';
import 'package:yourhome/data/models/developer_model.dart';
import 'package:yourhome/data/models/condo_project_model.dart';
import 'package:yourhome/data/models/house_project_model.dart';

enum PropertyMetadataStatus { initial, loading, success, failure }

class PropertyMetadataState extends Equatable {
  final PropertyMetadataStatus status;
  final PropertySpecificationFilters? specificationFilters;
  final List<Developer> developers;
  final List<CondoProject> condoProjects;
  final List<HouseProject> houseProjects;
  final String? error;

  const PropertyMetadataState({
    this.status = PropertyMetadataStatus.initial,
    this.specificationFilters,
    this.developers = const [],
    this.condoProjects = const [],
    this.houseProjects = const [],
    this.error,
  });

  PropertyMetadataState copyWith({
    PropertyMetadataStatus? status,
    PropertySpecificationFilters? specificationFilters,
    List<Developer>? developers,
    List<CondoProject>? condoProjects,
    List<HouseProject>? houseProjects,
    String? error,
  }) {
    return PropertyMetadataState(
      status: status ?? this.status,
      specificationFilters: specificationFilters ?? this.specificationFilters,
      developers: developers ?? this.developers,
      condoProjects: condoProjects ?? this.condoProjects,
      houseProjects: houseProjects ?? this.houseProjects,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    status,
    specificationFilters,
    developers,
    condoProjects,
    houseProjects,
    error,
  ];
}
