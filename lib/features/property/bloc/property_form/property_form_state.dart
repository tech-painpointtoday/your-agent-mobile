import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/domain/entities/property_details.dart';
import 'package:youragent/domain/entities/property_image.dart';
import '../../../../data/models/developer_model.dart';
import '../../../../data/models/condo_project_model.dart';
import '../../../../data/models/house_project_model.dart';
import '../../../../data/models/property_specification_filters.dart';

enum PropertyFormStatus {
  initial,
  submissionInProgress,
  submissionSuccess,
  submissionFailure,
  draftSaveInProgress,
  draftSaveSuccess,
  draftSaveFailure,
}

class PropertyFormImage extends Equatable {
  final int? id;
  final XFile? file;
  final String? url;

  const PropertyFormImage({this.id, this.file, this.url});

  factory PropertyFormImage.fromXFile(XFile file) =>
      PropertyFormImage(file: file);
  factory PropertyFormImage.fromUrl(String url, {int? id}) =>
      PropertyFormImage(url: url, id: id);

  bool get isNetwork => url != null;
  bool get isFile => file != null;

  String get name => isFile ? file!.name : (url?.split('/').last ?? 'image');
  String get path => isFile ? file!.path : (url ?? '');

  @override
  List<Object?> get props => [id, file, url];
}

class PropertyFormState extends Equatable {
  final int step;
  final PropertyFormStatus propertyFormStatus;
  final String? errorMessage;
  final int? propertyId; // Resulting property ID after success
  final bool isDraft; // Indicates if editing a draft property
  final bool showErrors; // Whether to show validation errors on fields

  // Data fields
  final PropertyType? selectedPropertyType;
  final String? name;
  final double? price;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int? bedrooms;
  final int? bathrooms;
  final int? garage;
  final double? landSize;
  final double? buildingSize;
  final PropertyColor? houseColor;
  final DateTime? built;
  final PropertyDirection? direction;
  final DateTime? availableFrom;
  final List<PropertyFormImage> images;

  // New Step 3 Fields
  final PropertyListingType? listingType;
  final PropertyAvailabilityStatus? status;
  final int? totalFloors; // For houses or generic floor count

  // New Step 4 Fields
  final StyleProperty? propertyStyle;

  // Location Details
  final String? number;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? subdistrict;
  final String? district;
  final String? road;
  final String? soi;
  final String? formattedAddressEn;
  final String? formattedAddressTh;
  final String? province;
  final CondoDetails? condoDetails;
  final HouseDetails? houseDetails;

  // Condo Details
  final int? condoProjectId;
  final String? tower;
  final String? condoFloor;
  final String? unitNo;

  // House Details
  final String? villageName;
  final String? moo;
  final String? houseSubtype;
  final String? parkingType;
  final bool? isCornerPlot;
  final String? houseNotes;

  // Selection Data
  final List<Developer> developers;
  final List<CondoProject> condoProjects;
  final List<HouseProject> houseProjects;
  final int? selectedDeveloperId;
  final int? selectedCondoProjectId;
  final int? selectedHouseProjectId;

  // Dynamic Filters
  final PropertySpecificationFilters specificationFilters;

  /// Single-select spec values (floors, bedrooms, bathrooms, parking_spaces; style added only for API).
  final Map<String, String> specifications;

  /// Multi-select spec values (common_facilities, furniture, air_conditioning, etc.).
  final Map<String, List<String>> specificationValues;

  const PropertyFormState({
    this.step = 1,
    this.propertyFormStatus = PropertyFormStatus.initial,
    this.errorMessage,
    this.propertyId,
    this.isDraft = false,
    this.showErrors = false,
    this.selectedPropertyType,
    this.name,
    this.price,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.bedrooms,
    this.bathrooms,
    this.garage,
    this.landSize,
    this.buildingSize,
    this.houseColor,
    this.built,
    this.direction,
    this.availableFrom,
    this.images = const [],
    this.number,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.subdistrict,
    this.district,
    this.road,
    this.soi,
    this.formattedAddressEn,
    this.formattedAddressTh,
    this.province,
    this.condoDetails,
    this.houseDetails,
    this.condoProjectId,
    this.tower,
    this.condoFloor,
    this.unitNo,
    this.villageName,
    this.moo,
    this.houseSubtype,
    this.parkingType,
    this.isCornerPlot,
    this.houseNotes,
    this.developers = const [],
    this.condoProjects = const [],
    this.houseProjects = const [],
    this.selectedDeveloperId,
    this.selectedCondoProjectId,
    this.selectedHouseProjectId,
    this.listingType,
    this.status,
    this.totalFloors,
    this.propertyStyle,
    this.specificationFilters = const PropertySpecificationFilters(),
    this.specifications = const {},
    this.specificationValues = const {},
  });

  /// Smart step calculation based on data completeness
  static int _calculateResumeStep(Property property) {
    // Step 1: Property Type
    if (property.propertyType == null) return 1;

    // Helper to safe parse int/num
    num? safeNum(dynamic val) {
      if (val == null) return null;
      if (val is num) return val;
      if (val is String) return num.tryParse(val);
      return null;
    }

    final specs = property.specifications;

    // Step 2: General Info (name, location, developer/project for condos)
    final bool isCondoOrApt =
        property.propertyType == PropertyType.condo ||
        property.propertyType == PropertyType.apartment;

    final baseValid =
        property.name != null &&
        property.number != null &&
        property.address != null;

    if (!baseValid) return 2;

    if (isCondoOrApt) {
      final developerId = safeNum(property.condoDetails?.developerId);
      final condoProjectId = safeNum(property.condoDetails?.condoProjectId);
      final floor = specs['floor']?.toString();
      final unitNo = specs['unit_no']?.toString();

      if (developerId == null ||
          condoProjectId == null ||
          floor == null ||
          unitNo == null) {
        return 2;
      }
    } else {
      if (property.number == null) return 2;
    }

    // Step 3: Property Details (price, bedrooms, bathrooms, etc.)
    if (property.price == 0 ||
        property.listingType == null ||
        property.status == null ||
        property.totalFloors == null ||
        property.bedrooms == 0 ||
        property.bathrooms == 0 ||
        property.garage == null ||
        property.built == null ||
        property.houseColor == null ||
        (isCondoOrApt == false &&
            (property.landSize == null || property.landSize == 0)) ||
        property.buildingSize == null ||
        property.buildingSize == 0 ||
        property.direction == null) {
      return 3;
    }

    // Step 4: Additional Info (description)
    if (property.description.isEmpty) {
      return 4;
    }

    // Step 5: Images
    if (property.imageUrls.isEmpty) return 5;

    // Step 6: Confirmation (all data present)
    return 6;
  }

  factory PropertyFormState.fromProperty(
    Property property, {
    PropertySpecificationFilters? filters,
  }) {
    // 1. Clean if draft
    final p = property.isDraft ? property.cleaned : property;
    // Helper to safe parse int
    int? safeInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is String) return int.tryParse(val);
      return null;
    }

    // Map specs: single-select -> specifications, multi-select (lists) -> specificationValues
    final specs = p.specifications;
    final specValues = p.specificationValues;

    final specsMap = <String, String>{};
    final specValuesMap = <String, List<String>>{};

    specs.forEach((key, value) {
      if (value is List) {
        specValuesMap[key] = value.cast<String>();
      } else {
        specsMap[key] = value?.toString() ?? '';
      }
    });
    specValues.forEach((key, value) {
      if (value is List) {
        specValuesMap[key] = value.cast<String>();
      } else {
        specValuesMap[key] = [value?.toString() ?? ''];
      }
    });

    // Detect if this is a draft
    final isDraft = p.isDraft;

    // Calculate initial step for draft resume
    final initialStep = isDraft ? _calculateResumeStep(p) : 1;

    return PropertyFormState(
      step: initialStep,
      isDraft: isDraft,
      showErrors: false,
      propertyId: p.id,
      selectedPropertyType: p.propertyType,
      name: p.name,
      price: p.price,
      description: p.description,
      address: p.address,
      latitude: p.latitude,
      longitude: p.longitude,
      bedrooms: p.bedrooms,
      bathrooms: p.bathrooms,
      garage: p.garage,
      landSize: p.landSize,
      buildingSize: p.buildingSize,
      houseColor: p.houseColor,
      built: p.built,
      direction: p.direction,
      availableFrom: p.availableFrom,
      images: p.images
          .map(
            (img) => img.url != null
                ? PropertyFormImage.fromUrl(img.url!, id: img.id)
                : null,
          )
          .whereType<PropertyFormImage>()
          .toList(),

      // Location
      number: p.number,
      city: p.city,
      state: p.state,
      country: p.country,
      postalCode: p.postalCode,
      subdistrict: p.subdistrict,
      district: p.district,
      province: p.province ?? p.state, // Map state to province
      condoDetails: p.condoDetails,
      houseDetails: p.houseDetails,
      road: p.road,
      soi: p.soi,
      formattedAddressEn: p.formattedAddressEn,
      formattedAddressTh: p.formattedAddressTh,

      // Enum/Strings
      listingType: p.listingType,
      status: p.status,
      totalFloors: p.totalFloors,
      propertyStyle: () {
        if (filters == null) return null;
        try {
          final styleSpec = filters.singleSelect.firstWhere(
            (s) => s.key == 'style',
          );
          // Check both 'style' (standard) and 'property_style' (legacy/API variance)
          final styleValue = (specs['style'] ?? specs['property_style'])
              ?.toString();

          if (styleValue == null || styleValue.isEmpty) return null;

          // Try to fuzzy match by value, labelEn, or labelTh
          final option = styleSpec.optionsWithImages.firstWhere(
            (opt) =>
                opt.value == styleValue ||
                opt.label == styleValue || // EN label
                opt.labelTh == styleValue, // TH label
          );
          return StyleProperty(
            id: option.value,
            value: option.value,
            nameEn: option.label,
            nameTh: option.labelTh,
            imageUrl: option.imageUrl,
          );
        } catch (_) {
          return null;
        }
      }(),
      specificationFilters: filters ?? const PropertySpecificationFilters(),
      specifications: specsMap,
      specificationValues: specValuesMap,

      // Attempt to map specific fields from specs if available
      condoProjectId: safeInt(specs['condo_project_id']),
      selectedCondoProjectId: safeInt(
        specs['condo_project_id'],
      ), // For dropdown selection
      selectedDeveloperId: safeInt(
        specs['developer_id'],
      ), // For dropdown selection
      tower: specs['tower'] as String?,
      condoFloor: specs['floor'] as String?,
      unitNo: specs['unit_no'] as String?,
      villageName: specs['village_name'] as String?,
      moo: specs['moo'] as String?,
      houseSubtype: specs['house_subtype'] as String?,
      parkingType: specs['parking_type'] as String?,
      isCornerPlot:
          specs['is_corner_plot'] == true || specs['is_corner_plot'] == 'true',
      houseNotes: specs['house_notes'] as String?,
    );
  }

  Map<String, dynamic> get data {
    final rawData = {
      'selectedPropertyType': selectedPropertyType?.label,
      'name': name,
      'type': selectedPropertyType?.value,
      'price': price,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'garage': garage,
      'land_size': landSize,
      'building_size': buildingSize,
      'house_color': houseColor?.label,
      'built': built != null
          ? "${built!.year.toString().padLeft(4, '0')}-${built!.month.toString().padLeft(2, '0')}-${built!.day.toString().padLeft(2, '0')}"
          : null,
      'direction': direction?.value,
      'available_from': availableFrom,
      'listing_type': listingType?.value,
      'status': status?.value,
      'floors': totalFloors,
      'style': propertyStyle?.nameEn,
      'location_set': latitude != null && longitude != null,
      'number': number,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'subdistrict': subdistrict,
      'district': district,
      'province': province,
      'road': road,
      'soi': soi,
      'formatted_address_en': formattedAddressEn,
      'formatted_address_th': formattedAddressTh,
      'building': tower,
      'floor': condoFloor,
      'unit_no': unitNo,
      'village_name': villageName,
      'moo': moo,
      'house_subtype': houseSubtype,
      'parking_type': parkingType,
      'is_corner_plot': isCornerPlot,
      'house_notes': houseNotes,
      if (selectedDeveloperId != null) 'developer_id': selectedDeveloperId,
      if (selectedCondoProjectId != null)
        'condo_project_id': selectedCondoProjectId,
      'specifications': {...specifications, 'style': propertyStyle?.value},
      'specification_values': specificationValues,
    };

    return _filterNulls(rawData);
  }

  /// Recursively removes null, empty strings, zero values, and empty collections from a Map
  Map<String, dynamic> _filterNulls(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (value == null) return;

      // Skip empty strings
      if (value is String && value.trim().isEmpty) return;

      // Skip zero values (int/double) - REMOVED to allow saving 0 (e.g. 0 bedrooms, ground floor)
      // if (value is num && value == 0) return;

      if (value is Map<String, dynamic>) {
        final filteredMap = _filterNulls(value);
        if (filteredMap.isNotEmpty) {
          result[key] = filteredMap;
        }
      } else if (value is Map) {
        final filteredMap = _filterNulls(Map<String, dynamic>.from(value));
        if (filteredMap.isNotEmpty) {
          result[key] = filteredMap;
        }
      } else if (value is List) {
        // Skip empty lists or lists containing only nulls/empty values could be complex,
        // but for now let's just skip empty lists.
        if (value.isNotEmpty) {
          result[key] = value;
        }
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  bool get isValid {
    if (step == 1) return selectedPropertyType != null;
    if (step == 2) {
      final isCondoOrApt = this.isCondoOrApt;
      final baseValid =
          (number?.isNotEmpty == true) &&
          (name?.isNotEmpty == true) &&
          (latitude != null && longitude != null);

      if (isCondoOrApt) {
        return baseValid &&
            selectedDeveloperId != null &&
            selectedCondoProjectId != null &&
            (condoFloor?.isNotEmpty == true);
      } else {
        return baseValid;
      }
    }
    if (step == 3) {
      final isCondoOrApt = this.isCondoOrApt;

      final baseValid =
          listingType != null &&
          status != null &&
          totalFloors != null &&
          bedrooms != null &&
          bathrooms != null &&
          garage != null &&
          built != null &&
          houseColor != null &&
          (price != null && price! > 0);

      if (isCondoOrApt) {
        return baseValid && (buildingSize != null && buildingSize! > 0);
      } else {
        return baseValid &&
            (landSize != null && landSize! > 0) &&
            (buildingSize != null && buildingSize! > 0);
      }
    }
    if (step == 4) {
      return description?.isNotEmpty == true;
    }
    if (step == 5) {
      return images.isNotEmpty;
    }
    return true;
  }

  PropertyFormState copyWith({
    int? step,
    PropertyFormStatus? propertyFormStatus,
    String? errorMessage,
    int? propertyId,
    bool? isDraft,
    bool? showErrors,
    PropertyType? selectedPropertyType,
    String? name,
    double? price,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    int? bedrooms,
    int? bathrooms,
    int? garage,
    double? landSize,
    double? buildingSize,
    PropertyColor? houseColor,
    DateTime? built,
    PropertyDirection? direction,
    DateTime? availableFrom,
    List<PropertyFormImage>? images,
    String? number,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? subdistrict,
    String? district,
    String? road,
    String? soi,
    String? formattedAddressEn,
    String? formattedAddressTh,
    String? province,
    int? condoProjectId,
    String? tower,
    String? condoFloor,
    String? unitNo,
    String? villageName,
    String? moo,
    String? houseSubtype,
    String? parkingType,
    bool? isCornerPlot,
    String? houseNotes,
    List<Developer>? developers,
    List<CondoProject>? condoProjects,
    List<HouseProject>? houseProjects,
    int? selectedDeveloperId,
    int? selectedCondoProjectId,
    int? selectedHouseProjectId,
    PropertyListingType? listingType,
    PropertyAvailabilityStatus? status,
    int? totalFloors,
    StyleProperty? propertyStyle,
    PropertySpecificationFilters? specificationFilters,
    Map<String, String>? specifications,
    Map<String, List<String>>? specificationValues,
  }) {
    return PropertyFormState(
      step: step ?? this.step,
      propertyFormStatus: propertyFormStatus ?? this.propertyFormStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      propertyId: propertyId ?? this.propertyId,
      isDraft: isDraft ?? this.isDraft,
      showErrors: showErrors ?? this.showErrors,
      selectedPropertyType: selectedPropertyType ?? this.selectedPropertyType,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      garage: garage ?? this.garage,
      landSize: landSize ?? this.landSize,
      buildingSize: buildingSize ?? this.buildingSize,
      houseColor: houseColor ?? this.houseColor,
      built: built ?? this.built,
      direction: direction ?? this.direction,
      availableFrom: availableFrom ?? this.availableFrom,
      images: images ?? this.images,
      number: number ?? this.number,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      subdistrict: subdistrict ?? this.subdistrict,
      district: district ?? this.district,
      province: province ?? this.province,
      condoDetails: condoDetails ?? this.condoDetails,
      houseDetails: houseDetails ?? this.houseDetails,
      road: road ?? this.road,
      soi: soi ?? this.soi,
      formattedAddressEn: formattedAddressEn ?? this.formattedAddressEn,
      formattedAddressTh: formattedAddressTh ?? this.formattedAddressTh,
      condoProjectId: condoProjectId ?? this.condoProjectId,
      tower: tower ?? this.tower,
      condoFloor: condoFloor ?? this.condoFloor,
      unitNo: unitNo ?? this.unitNo,
      villageName: villageName ?? this.villageName,
      moo: moo ?? this.moo,
      houseSubtype: houseSubtype ?? this.houseSubtype,
      parkingType: parkingType ?? this.parkingType,
      isCornerPlot: isCornerPlot ?? this.isCornerPlot,
      houseNotes: houseNotes ?? this.houseNotes,
      developers: developers ?? this.developers,
      condoProjects: condoProjects ?? this.condoProjects,
      houseProjects: houseProjects ?? this.houseProjects,
      selectedDeveloperId: selectedDeveloperId ?? this.selectedDeveloperId,
      selectedCondoProjectId:
          selectedCondoProjectId ?? this.selectedCondoProjectId,
      selectedHouseProjectId:
          selectedHouseProjectId ?? this.selectedHouseProjectId,
      listingType: listingType ?? this.listingType,
      status: status ?? this.status,
      totalFloors: totalFloors ?? this.totalFloors,
      propertyStyle: propertyStyle ?? this.propertyStyle,
      specificationFilters: specificationFilters ?? this.specificationFilters,
      specifications: specifications ?? this.specifications,
      specificationValues: specificationValues ?? this.specificationValues,
    );
  }

  Property get toProperty {
    // specifications (single-select) + style for API
    final specsMap = <String, dynamic>{
      ...specifications,
      'style': propertyStyle?.value,
    };
    specsMap['floors'] = totalFloors?.toString();
    specsMap['bedrooms'] = bedrooms?.toString();
    specsMap['bathrooms'] = bathrooms?.toString();
    specsMap['parking_spaces'] = garage?.toString();
    specsMap['garage'] = garage?.toString();
    final specValuesMap = Map<String, dynamic>.from(specificationValues);

    // 3. Create Entity
    return Property(
      // ID is null -> Indicates Draft
      id: propertyId,

      title: name ?? 'รายละเอียดทรัพย์สิน', // Fallback title
      name: name,
      description: description ?? '',
      price: price ?? 0,

      // Status
      approvalStatus: PropertyApprovalStatus.pending, // Mark as draft for UI
      listingType: listingType,
      status: status, // mapped from state.status field
      availableFrom: availableFrom,

      // Location
      address: address,
      latitude: latitude ?? 0,
      longitude: longitude ?? 0,
      locationSet: latitude != null && longitude != null,
      number: number,
      city: city,
      state: province ?? state,
      district: district,
      subdistrict: subdistrict,
      road: road,
      soi: soi,
      postalCode: postalCode,
      country: country,
      formattedAddressEn: formattedAddressEn,
      formattedAddressTh: formattedAddressTh,

      // Physical Details
      propertyType: selectedPropertyType,
      bedrooms: bedrooms ?? 0,
      bathrooms: bathrooms ?? 0,
      garage: garage,
      landSize: landSize,
      buildingSize: buildingSize,
      totalFloors: totalFloors,
      houseColor: houseColor,
      built: built,
      direction: direction,

      // Collections
      specifications: specsMap,
      specificationValues: specValuesMap,

      // Images (Pass local XFiles)
      imageFiles: images
          .where((img) => img.isFile)
          .map((img) => img.file!)
          .toList(),
      condoDetails: selectedPropertyType == PropertyType.condo
          ? (condoDetails?.copyWith(
                  condoProjectId: selectedCondoProjectId,
                  tower: tower,
                  unitNo: unitNo,
                  floor: condoFloor,
                  // Ensure developerId getter works by providing basic project info if missing
                  condoProject:
                      condoDetails?.condoProject ??
                      (selectedCondoProjectId != null
                          ? CondoProject(
                              id: selectedCondoProjectId!,
                              name: '',
                              nameTh: '',
                              nameEn: '',
                              developerId: selectedDeveloperId,
                            )
                          : null),
                ) ??
                CondoDetails(
                  id: 0,
                  propertyId: propertyId ?? 0,
                  condoProjectId: selectedCondoProjectId,
                  tower: tower,
                  unitNo: unitNo,
                  floor: condoFloor,
                  condoProject: selectedCondoProjectId != null
                      ? CondoProject(
                          id: selectedCondoProjectId!,
                          name: '',
                          nameTh: '',
                          nameEn: '',
                          developerId: selectedDeveloperId,
                        )
                      : null,
                ))
          : null,
      houseDetails:
          selectedPropertyType == PropertyType.house ||
              selectedPropertyType == PropertyType.townhome ||
              selectedPropertyType == PropertyType.homeOffice
          ? (houseDetails?.copyWith(
                  houseProjectId: selectedHouseProjectId,
                  villageName: villageName,
                  moo: moo,
                  houseSubtype: houseSubtype,
                  parkingType: parkingType,
                  isCornerPlot: isCornerPlot,
                  notes: houseNotes,
                  // Ensure developerId getter works
                  developer:
                      houseDetails?.developer ??
                      (selectedDeveloperId != null
                          ? Developer(
                              id: selectedDeveloperId!,
                              nameTh: '',
                              nameEn: '',
                              slug: '',
                            )
                          : null),
                ) ??
                HouseDetails(
                  id: 0,
                  propertyId: propertyId ?? 0,
                  houseProjectId: selectedHouseProjectId,
                  villageName: villageName,
                  moo: moo,
                  houseSubtype: houseSubtype,
                  parkingType: parkingType,
                  isCornerPlot: isCornerPlot,
                  notes: houseNotes,
                  developer: selectedDeveloperId != null
                      ? Developer(
                          id: selectedDeveloperId!,
                          nameTh: '',
                          nameEn: '',
                          slug: '',
                        )
                      : null,
                ))
          : null,
      imageUrl: images.any((img) => img.isNetwork)
          ? images.firstWhere((img) => img.isNetwork).url
          : null,
      images: images
          .where((img) => img.isNetwork)
          .map((img) => PropertyImage(id: img.id ?? 0, url: img.url!))
          .toList(),

      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    step,
    propertyFormStatus,
    errorMessage,
    propertyId,
    isDraft,
    showErrors,
    selectedPropertyType,
    name,
    price,
    description,
    address,
    latitude,
    longitude,
    bedrooms,
    bathrooms,
    garage,
    landSize,
    buildingSize,
    houseColor,
    built,
    direction,
    availableFrom,
    images,
    number,
    city,
    state,
    country,
    postalCode,
    subdistrict,
    district,
    province,
    condoDetails,
    houseDetails,
    road,
    soi,
    formattedAddressEn,
    formattedAddressTh,
    condoProjectId,
    tower,
    condoFloor,
    unitNo,
    villageName,
    moo,
    houseSubtype,
    parkingType,
    isCornerPlot,
    houseNotes,
    developers,
    condoProjects,
    houseProjects,
    selectedDeveloperId,
    selectedCondoProjectId,
    selectedHouseProjectId,
    listingType,
    status,
    totalFloors,
    propertyStyle,
    specificationFilters,
    specifications,
    specificationValues,
  ];

  bool get isCondoOrApt =>
      selectedPropertyType == PropertyType.condo ||
      selectedPropertyType == PropertyType.apartment;
}

class StyleProperty extends Equatable {
  final String id;
  final String value;
  final String nameEn;
  final String nameTh;
  final String? imagePath;
  final String? imageUrl;

  const StyleProperty({
    required this.id,
    required this.value,
    required this.nameEn,
    required this.nameTh,
    this.imagePath,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, value, nameEn, nameTh, imagePath, imageUrl];
}

extension PropertySpecificationOptionX on PropertySpecificationOption {
  // Helper if needed, but we used direct mapping above
  String get labelEn => label; // label corresponds to label_en/name_en
}
