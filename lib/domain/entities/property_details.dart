import 'package:equatable/equatable.dart';
import '../../data/models/condo_project_model.dart';
import '../../data/models/house_project_model.dart';
import '../../data/models/developer_model.dart';

class CondoDetails extends Equatable {
  final int id;
  final int propertyId;
  final int? condoProjectId;
  final String? tower;
  final String? unitNo;
  final String? floor;
  final String? layoutCode;
  final CondoProject? condoProject;
  final Developer? developer;

  const CondoDetails({
    required this.id,
    required this.propertyId,
    this.condoProjectId,
    this.tower,
    this.unitNo,
    this.floor,
    this.layoutCode,
    this.condoProject,
    this.developer,
  });

  factory CondoDetails.fromJson(Map<String, dynamic> json) {
    // Parse nested project
    CondoProject? parsedProject;
    Developer? parsedDeveloper;

    if (json['condo_project'] is Map<String, dynamic>) {
      final projectJson = json['condo_project'] as Map<String, dynamic>;
      parsedProject = CondoProject.fromJson(projectJson);

      // Developer might be nested in project
      if (projectJson['developer'] is Map<String, dynamic>) {
        parsedDeveloper = Developer.fromJson(
          projectJson['developer'] as Map<String, dynamic>,
        );
      }
    }

    return CondoDetails(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      propertyId: json['property_id'] is int
          ? json['property_id']
          : int.tryParse(json['property_id'].toString()) ?? 0,
      condoProjectId: json['condo_project_id'] is int
          ? json['condo_project_id']
          : int.tryParse(json['condo_project_id']?.toString() ?? ''),
      tower: json['tower']?.toString(),
      unitNo: json['unit_no']?.toString(),
      floor: json['floor']?.toString(),
      layoutCode: json['layout_code']?.toString(),
      condoProject: parsedProject,
      developer: parsedDeveloper,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'condo_project_id': condoProjectId,
      'tower': tower,
      'unit_no': unitNo,
      'floor': floor,
      'layout_code': layoutCode,
      if (condoProject != null) 'condo_project': condoProject!.toJson(),
      // Note: developer is usually part of condo_project in this structure,
      // but if we want to include it explicitly if needed:
      // 'developer': developer?.toJson(),
    };
  }

  // Helper to get developer Id
  int? get developerId => developer?.id ?? condoProject?.developerId;

  CondoDetails copyWith({
    int? id,
    int? propertyId,
    int? condoProjectId,
    String? tower,
    String? unitNo,
    String? floor,
    String? layoutCode,
    CondoProject? condoProject,
    Developer? developer,
  }) {
    return CondoDetails(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      condoProjectId: condoProjectId ?? this.condoProjectId,
      tower: tower ?? this.tower,
      unitNo: unitNo ?? this.unitNo,
      floor: floor ?? this.floor,
      layoutCode: layoutCode ?? this.layoutCode,
      condoProject: condoProject ?? this.condoProject,
      developer: developer ?? this.developer,
    );
  }

  @override
  List<Object?> get props => [
    id,
    propertyId,
    condoProjectId,
    tower,
    unitNo,
    floor,
    layoutCode,
    condoProject,
    developer,
  ];
}

class HouseDetails extends Equatable {
  final int id;
  final int propertyId;
  final int? houseProjectId;
  final String? villageName;
  final String? moo;
  final String? houseSubtype;
  final String? parkingType;
  final bool? isCornerPlot;
  final String? notes;
  final HouseProject? houseProject;
  final Developer? developer;

  const HouseDetails({
    required this.id,
    required this.propertyId,
    this.houseProjectId,
    this.villageName,
    this.moo,
    this.houseSubtype,
    this.parkingType,
    this.isCornerPlot,
    this.notes,
    this.houseProject,
    this.developer,
  });

  factory HouseDetails.fromJson(Map<String, dynamic> json) {
    HouseProject? parsedProject;
    Developer? parsedDeveloper;

    // Parse House Project
    if (json['house_project'] is Map<String, dynamic>) {
      final projectJson = json['house_project'] as Map<String, dynamic>;
      parsedProject = HouseProject.fromJson(projectJson);

      // Developer inside project?
      if (projectJson['developer'] is Map<String, dynamic>) {
        parsedDeveloper = Developer.fromJson(
          projectJson['developer'] as Map<String, dynamic>,
        );
      }
    }

    // Developer directly in house_details (as seen in some JSON structures)
    // Override if found directly
    if (json['developer'] is Map<String, dynamic>) {
      parsedDeveloper = Developer.fromJson(
        json['developer'] as Map<String, dynamic>,
      );
    }

    return HouseDetails(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      propertyId: json['property_id'] is int
          ? json['property_id']
          : int.tryParse(json['property_id'].toString()) ?? 0,
      houseProjectId: json['house_project_id'] is int
          ? json['house_project_id']
          : int.tryParse(json['house_project_id']?.toString() ?? ''),
      villageName: json['village_name']?.toString(),
      moo: json['moo']?.toString(),
      houseSubtype: json['house_subtype']?.toString(),
      parkingType: json['parking_type']?.toString(),
      isCornerPlot:
          json['is_corner_plot'] == true || json['is_corner_plot'] == 'true',
      notes: json['notes']?.toString(),
      houseProject: parsedProject,
      developer: parsedDeveloper,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'house_project_id': houseProjectId,
      'village_name': villageName,
      'moo': moo,
      'house_subtype': houseSubtype,
      'parking_type': parkingType,
      'is_corner_plot': isCornerPlot,
      'notes': notes,
      if (houseProject != null) 'house_project': houseProject!.toJson(),
      if (developer != null) 'developer': developer!.toJson(),
    };
  }

  int? get developerId => developer?.id ?? houseProject?.developerId;

  HouseDetails copyWith({
    int? id,
    int? propertyId,
    int? houseProjectId,
    String? villageName,
    String? moo,
    String? houseSubtype,
    String? parkingType,
    bool? isCornerPlot,
    String? notes,
    HouseProject? houseProject,
    Developer? developer,
  }) {
    return HouseDetails(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      houseProjectId: houseProjectId ?? this.houseProjectId,
      villageName: villageName ?? this.villageName,
      moo: moo ?? this.moo,
      houseSubtype: houseSubtype ?? this.houseSubtype,
      parkingType: parkingType ?? this.parkingType,
      isCornerPlot: isCornerPlot ?? this.isCornerPlot,
      notes: notes ?? this.notes,
      houseProject: houseProject ?? this.houseProject,
      developer: developer ?? this.developer,
    );
  }

  @override
  List<Object?> get props => [
    id,
    propertyId,
    houseProjectId,
    villageName,
    moo,
    houseSubtype,
    parkingType,
    isCornerPlot,
    notes,
    houseProject,
    developer,
  ];
}
