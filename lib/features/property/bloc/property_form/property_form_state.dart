import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:youragent/domain/entities/property.dart';
import '../../../../data/models/developer_model.dart';
import '../../../../data/models/condo_project_model.dart';
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
  final XFile? file;
  final String? url;

  const PropertyFormImage({this.file, this.url});

  factory PropertyFormImage.fromXFile(XFile file) =>
      PropertyFormImage(file: file);
  factory PropertyFormImage.fromUrl(String url) => PropertyFormImage(url: url);

  bool get isNetwork => url != null;
  bool get isFile => file != null;

  String get name => isFile ? file!.name : (url?.split('/').last ?? 'image');
  String get path => isFile ? file!.path : (url ?? '');

  @override
  List<Object?> get props => [file, url];
}

class PropertyFormState extends Equatable {
  final int step;
  final PropertyFormStatus propertyFormStatus;
  final String? errorMessage;
  final int? propertyId; // Resulting property ID after success
  final bool isDraft; // Indicates if editing a draft property

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
  final PropertyStyle? propertyStyle;

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
  final int? selectedDeveloperId;
  final int? selectedCondoProjectId;

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
    this.selectedDeveloperId,
    this.selectedCondoProjectId,
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

    // Step 2: General Info (name, location, developer/project for condos)
    if (property.name == null ||
        property.name!.isEmpty ||
        property.formattedAddressTh == null ||
        property.formattedAddressTh!.isEmpty) {
      return 2;
    }

    // Step 3: Property Details (price, bedrooms, bathrooms, etc.)
    if (property.price == 0 ||
        property.listingType == null ||
        property.status == null ||
        property.totalFloors == null ||
        property.bedrooms == 0 ||
        property.bathrooms == 0) {
      return 3;
    }

    // Step 4: Additional Info (style, description)
    if (property.propertyStyle == null || property.description.isEmpty) {
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
    // Helper to safe parse int
    int? safeInt(dynamic val) {
      if (val == null) return null;
      if (val is int) return val;
      if (val is String) return int.tryParse(val);
      return null;
    }

    // Map specs: single-select -> specifications, multi-select (lists) -> specificationValues
    final specs = property.specifications;
    final specValues = property.specificationValues;

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
    final isDraft = property.isDraft;

    // Calculate initial step for draft resume
    final initialStep = isDraft ? _calculateResumeStep(property) : 1;

    return PropertyFormState(
      step: initialStep,
      isDraft: isDraft,
      propertyId: property.id,
      selectedPropertyType: property.propertyType,
      name: property.name,
      price: property.price,
      description: property.description,
      address: property.address,
      latitude: property.latitude,
      longitude: property.longitude,
      bedrooms: property.bedrooms,
      bathrooms: property.bathrooms,
      garage: property.garage,
      landSize: property.landSize,
      buildingSize: property.buildingSize,
      houseColor: property.houseColor,
      built: property.built,
      direction: property.direction,
      availableFrom: property.availableFrom,
      images: property.imageUrls
          .map((url) => PropertyFormImage.fromUrl(url))
          .toList(),

      // Location
      number: property.number,
      city: property.city,
      state: property.state,
      country: property.country,
      postalCode: property.postalCode,
      subdistrict: property.subdistrict,
      district: property.district,
      province: property.state, // Map state to province
      road: property.road,
      soi: property.soi,
      formattedAddressEn: property.formattedAddressEn,
      formattedAddressTh: property.formattedAddressTh,

      // Enum/Strings
      listingType: property.listingType,
      status: property.status,
      totalFloors: property.totalFloors,
      propertyStyle: property.propertyStyle,

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
      isCornerPlot: specs['is_corner_plot'] == 'true',
      houseNotes: specs['house_notes'] as String?,
    );
  }

  Map<String, dynamic> get data => {
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
    'built': built?.toUtc().toIso8601String(),
    'direction': direction?.value,
    'available_from': availableFrom,
    'listing_type': listingType?.value,
    'status': status?.value,
    'total_floors': totalFloors,
    'style': propertyStyle?.value,
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
    'condoProjectId': condoProjectId,
    'tower': tower,
    'condoFloor': condoFloor,
    'unitNo': unitNo,
    'village_name': villageName,
    'moo': moo,
    'house_subtype': houseSubtype,
    'parking_type': parkingType,
    'is_corner_plot': isCornerPlot,
    'house_notes': houseNotes,
    'specifications': {
      ...specifications,
      if (propertyStyle != null) 'style': propertyStyle!.value,
      if (selectedDeveloperId != null)
        'developer_id': selectedDeveloperId.toString(),
      if (selectedCondoProjectId != null)
        'condo_project_id': selectedCondoProjectId.toString(),
    },
    'specification_values': specificationValues,
  };

  bool get isValid {
    if (step == 1) return selectedPropertyType != null;
    if (step == 2) {
      final baseValid =
          (name?.isNotEmpty == true) &&
          (address?.isNotEmpty == true) &&
          (formattedAddressTh?.isNotEmpty == true);

      if (!baseValid) return false;

      final isCondoOrApt = this.isCondoOrApt;

      if (isCondoOrApt) {
        return selectedDeveloperId != null &&
            selectedCondoProjectId != null &&
            (condoFloor?.isNotEmpty == true) &&
            (unitNo?.isNotEmpty == true);
      }
      return true;
    }
    if (step == 3) {
      return listingType != null &&
          status != null &&
          totalFloors != null &&
          bedrooms != null &&
          bathrooms != null &&
          garage != null &&
          built != null &&
          houseColor != null &&
          price != null &&
          landSize != null &&
          buildingSize != null &&
          direction != null;
    }
    if (step == 4) {
      return propertyStyle != null && description?.isNotEmpty == true;
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
    int? selectedDeveloperId,
    int? selectedCondoProjectId,
    PropertyListingType? listingType,
    PropertyAvailabilityStatus? status,
    int? totalFloors,
    PropertyStyle? propertyStyle,
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
      selectedDeveloperId: selectedDeveloperId ?? this.selectedDeveloperId,
      selectedCondoProjectId:
          selectedCondoProjectId ?? this.selectedCondoProjectId,
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
      if (propertyStyle != null) 'style': propertyStyle!.value,
    };
    specsMap['floors'] = totalFloors?.toString();
    specsMap['bedrooms'] = bedrooms?.toString();
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
      approvalStatus: PropertyApprovalStatus.draft, // Mark as draft for UI
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
      propertyStyle: propertyStyle,
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
      imageUrls: images
          .where((img) => img.isNetwork)
          .map((img) => img.url!)
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
    selectedDeveloperId,
    selectedCondoProjectId,
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
