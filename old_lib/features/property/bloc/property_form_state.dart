import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:youragent/domain/entities/property_image.dart';
import 'package:youragent/domain/entities/property_enums.dart';
import 'package:youragent/data/models/developer_model.dart';
import 'package:youragent/data/models/condo_project_model.dart';

/// States for Property Form BLoC
abstract class PropertyFormState extends Equatable {
  const PropertyFormState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PropertyFormInitial extends PropertyFormState {}

/// Form data state - contains all form values
class PropertyFormData extends PropertyFormState {
  // Enums
  final PropertyType? selectedType;
  final PropertyStatus? selectedStatus;
  final SaleType? selectedSaleType;
  final PropertyStyle? selectedPropertyStyle;
  final PropertyColor? selectedPropertyColor;
  final Direction? selectedDirection;
  final Country? selectedCountry;

  // Dates
  final DateTime? builtDate;
  final DateTime? availableFromDate;

  // Multi-select lists
  final List<String> selectedHighlights;
  final List<String> selectedCommonAreas;
  final List<String> selectedFurniture;
  final List<String> selectedAirConditioning;

  // Location
  final LatLng? selectedLocation;
  final String? address;
  final String? district;
  final String? subdistrict;
  final String? state;
  final String? country;
  final String? postalCode;

  // Photos
  final List<XFile> newPhotos;
  final List<PropertyImage> existingPhotos;

  // Filter options
  final Map<String, List<String>> filterOptions;
  final bool isLoadingFilterOptions;

  // Thai addresses
  final List<Map<String, dynamic>> thaiAddresses;
  final bool isLoadingAddress;

  // Text field values (for syncing to controllers)
  final String? propertyName;
  final String? propertyCode;
  final String? floors;
  final String? bedrooms;
  final String? bathrooms;
  final String? garage;
  final String? price;
  final String? landSize;
  final String? buildingSize;
  final String? description;
  final String? additionalDetails;
  final String? houseNumber;
  final String? soi;
  final String? road;
  final String? availableFrom;

  // Master data
  final List<Developer> developers;
  final List<CondoProject> condoProjects;
  final bool isLoadingMasterData;

  // Condo-specific fields
  final Developer? selectedDeveloper;
  final CondoProject? selectedCondoProject; // Source of truth for project_id
  final int? pendingCondoProjectId; // Temporary: ID to match after master data loads
  final String? tower;
  final String? condoFloor;
  final String? unitNo;

  // House-specific fields
  final String? villageName;
  final String? moo;
  final String? houseSubtype; // 'detached', 'semi', 'townhouse', etc.
  final String? parkingType;
  final bool? isCornerPlot;
  final String? houseNotes;

  const PropertyFormData({
    this.selectedType,
    this.selectedStatus,
    this.selectedSaleType,
    this.selectedPropertyStyle,
    this.selectedPropertyColor,
    this.selectedDirection,
    this.selectedCountry,
    this.builtDate,
    this.availableFromDate,
    this.selectedHighlights = const [],
    this.selectedCommonAreas = const [],
    this.selectedFurniture = const [],
    this.selectedAirConditioning = const [],
    this.selectedLocation,
    this.address,
    this.district,
    this.subdistrict,
    this.state,
    this.country,
    this.postalCode,
    this.newPhotos = const [],
    this.existingPhotos = const [],
    this.filterOptions = const {},
    this.isLoadingFilterOptions = false,
    this.thaiAddresses = const [],
    this.isLoadingAddress = true,
    this.propertyName,
    this.propertyCode,
    this.floors,
    this.bedrooms,
    this.bathrooms,
    this.garage,
    this.price,
    this.landSize,
    this.buildingSize,
    this.description,
    this.additionalDetails,
    this.houseNumber,
    this.soi,
    this.road,
    this.availableFrom,
    this.developers = const [],
    this.condoProjects = const [],
    this.isLoadingMasterData = false,
    this.selectedDeveloper,
    this.selectedCondoProject,
    this.pendingCondoProjectId,
    this.tower,
    this.condoFloor,
    this.unitNo,
    this.villageName,
    this.moo,
    this.houseSubtype,
    this.parkingType,
    this.isCornerPlot,
    this.houseNotes,
  });

  PropertyFormData copyWith({
    PropertyType? selectedType,
    PropertyStatus? selectedStatus,
    SaleType? selectedSaleType,
    PropertyStyle? selectedPropertyStyle,
    PropertyColor? selectedPropertyColor,
    Direction? selectedDirection,
    Country? selectedCountry,
    DateTime? builtDate,
    DateTime? availableFromDate,
    List<String>? selectedHighlights,
    List<String>? selectedCommonAreas,
    List<String>? selectedFurniture,
    List<String>? selectedAirConditioning,
    LatLng? selectedLocation,
    String? address,
    String? district,
    String? subdistrict,
    String? state,
    String? country,
    String? postalCode,
    List<XFile>? newPhotos,
    List<PropertyImage>? existingPhotos,
    Map<String, List<String>>? filterOptions,
    bool? isLoadingFilterOptions,
    List<Map<String, dynamic>>? thaiAddresses,
    bool? isLoadingAddress,
    String? propertyName,
    String? propertyCode,
    String? floors,
    String? bedrooms,
    String? bathrooms,
    String? garage,
    String? price,
    String? landSize,
    String? buildingSize,
    String? description,
    String? additionalDetails,
    String? houseNumber,
    String? soi,
    String? road,
    String? availableFrom,
    List<Developer>? developers,
    List<CondoProject>? condoProjects,
    bool? isLoadingMasterData,
    Developer? selectedDeveloper,
    CondoProject? selectedCondoProject,
    int? pendingCondoProjectId,
    String? tower,
    String? condoFloor,
    String? unitNo,
    String? villageName,
    String? moo,
    String? houseSubtype,
    String? parkingType,
    bool? isCornerPlot,
    String? houseNotes,
    bool clearSelectedCondoProject = false,
  }) {
    return PropertyFormData(
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedSaleType: selectedSaleType ?? this.selectedSaleType,
      selectedPropertyStyle: selectedPropertyStyle ?? this.selectedPropertyStyle,
      selectedPropertyColor: selectedPropertyColor ?? this.selectedPropertyColor,
      selectedDirection: selectedDirection ?? this.selectedDirection,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      builtDate: builtDate ?? this.builtDate,
      availableFromDate: availableFromDate ?? this.availableFromDate,
      selectedHighlights: selectedHighlights ?? this.selectedHighlights,
      selectedCommonAreas: selectedCommonAreas ?? this.selectedCommonAreas,
      selectedFurniture: selectedFurniture ?? this.selectedFurniture,
      selectedAirConditioning: selectedAirConditioning ?? this.selectedAirConditioning,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      address: address ?? this.address,
      district: district ?? this.district,
      subdistrict: subdistrict ?? this.subdistrict,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      newPhotos: newPhotos ?? this.newPhotos,
      existingPhotos: existingPhotos ?? this.existingPhotos,
      filterOptions: filterOptions ?? this.filterOptions,
      isLoadingFilterOptions: isLoadingFilterOptions ?? this.isLoadingFilterOptions,
      thaiAddresses: thaiAddresses ?? this.thaiAddresses,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      propertyName: propertyName ?? this.propertyName,
      propertyCode: propertyCode ?? this.propertyCode,
      floors: floors ?? this.floors,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      garage: garage ?? this.garage,
      price: price ?? this.price,
      landSize: landSize ?? this.landSize,
      buildingSize: buildingSize ?? this.buildingSize,
      description: description ?? this.description,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      houseNumber: houseNumber ?? this.houseNumber,
      soi: soi ?? this.soi,
      road: road ?? this.road,
      availableFrom: availableFrom ?? this.availableFrom,
      developers: developers ?? this.developers,
      condoProjects: condoProjects ?? this.condoProjects,
      isLoadingMasterData: isLoadingMasterData ?? this.isLoadingMasterData,
      selectedDeveloper: selectedDeveloper ?? this.selectedDeveloper,
      selectedCondoProject: clearSelectedCondoProject
          ? null
          : (selectedCondoProject ?? this.selectedCondoProject),
      pendingCondoProjectId: pendingCondoProjectId ?? this.pendingCondoProjectId,
      tower: tower ?? this.tower,
      condoFloor: condoFloor ?? this.condoFloor,
      unitNo: unitNo ?? this.unitNo,
      villageName: villageName ?? this.villageName,
      moo: moo ?? this.moo,
      houseSubtype: houseSubtype ?? this.houseSubtype,
      parkingType: parkingType ?? this.parkingType,
      isCornerPlot: isCornerPlot ?? this.isCornerPlot,
      houseNotes: houseNotes ?? this.houseNotes,
    );
  }

  @override
  List<Object?> get props => [
        selectedType,
        selectedStatus,
        selectedSaleType,
        selectedPropertyStyle,
        selectedPropertyColor,
        selectedDirection,
        selectedCountry,
        builtDate,
        availableFromDate,
        selectedHighlights,
        selectedCommonAreas,
        selectedFurniture,
        selectedAirConditioning,
        selectedLocation,
        address,
        district,
        subdistrict,
        state,
        country,
        postalCode,
        newPhotos,
        existingPhotos,
        filterOptions,
        isLoadingFilterOptions,
        thaiAddresses,
        isLoadingAddress,
        propertyName,
        propertyCode,
        floors,
        bedrooms,
        bathrooms,
        garage,
        price,
        landSize,
        buildingSize,
        description,
        additionalDetails,
        houseNumber,
        soi,
        road,
        availableFrom,
        developers,
        condoProjects,
        isLoadingMasterData,
        selectedDeveloper,
        selectedCondoProject,
        pendingCondoProjectId,
        tower,
        condoFloor,
        unitNo,
        villageName,
        moo,
        houseSubtype,
        parkingType,
        isCornerPlot,
        houseNotes,
      ];
}
