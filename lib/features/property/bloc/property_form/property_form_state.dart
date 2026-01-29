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
}

class PropertyFormState extends Equatable {
  final int step;
  final PropertyFormStatus propertyFormStatus;
  final String? errorMessage;
  final int? propertyId; // Resulting property ID after success

  // Data fields
  final String? selectedPropertyType;
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
  final String? houseColor;
  final String? built;
  final String? direction;
  final String? availableFrom;
  final List<XFile> images;
  final List<String> imageUrls;

  // New Step 3 Fields
  final String? listingType; // 'ขาย', 'เช่า', 'ขายและเช่า'
  final String? status; // 'ว่าง', 'ไม่ว่าง'
  final int? totalFloors; // For houses or generic floor count

  // New Step 4 Fields
  final String? propertyStyle;
  final List<String> highlights;
  final List<String> facilities;

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
  final Map<String, dynamic>
  dynamicValues; // key -> value (String or List<String>)

  const PropertyFormState({
    this.step = 1,
    this.propertyFormStatus = PropertyFormStatus.initial,
    this.errorMessage,
    this.propertyId,
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
    this.imageUrls = const [],
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
    this.highlights = const [],
    this.facilities = const [],
    this.specificationFilters = const PropertySpecificationFilters(),
    this.dynamicValues = const {},
  });

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

    // Map specs
    final specs = property.specifications;
    final specValues = property.specificationValues;

    // Extract dynamic values (flattening specValues)
    final dynamicMap = <String, dynamic>{};
    specValues.forEach((key, value) {
      dynamicMap[key] = value;
    });
    specs.forEach((key, value) {
      if (!dynamicMap.containsKey(key)) {
        dynamicMap[key] = value;
      }
    });

    return PropertyFormState(
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
      // Images logic needs handling XFiles vs URLs.
      // For editing, we might need a separate field for existingImageUrls in State
      // But for now, let's leave images empty as we might not convert URLs to XFiles easily here
      // The PropertyImagesStep will need to handle existing URLs display.
      images: [],

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

      // Lists
      highlights:
          (specValues['good_points'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      facilities:
          (specValues['common_facilities'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      specificationFilters: filters ?? const PropertySpecificationFilters(),
      dynamicValues: dynamicMap,

      // Attempt to map specific fields from specs if available
      condoProjectId: safeInt(specs['condo_project_id']),
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
    'selectedPropertyType': selectedPropertyType,
    'title': name,
    'price': price,
    'description': description,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'garage': garage,
    'landSize': landSize,
    'buildingSize': buildingSize,
    'houseColor': houseColor,
    'built': built,
    'direction': direction,
    'availableFrom': availableFrom,
    'listingType': listingType,
    'status': status,
    'totalFloors': totalFloors,
    'propertyStyle': propertyStyle,
    'highlights': highlights,
    'facilities': facilities,
    'location_set': latitude != null && longitude != null,
    'number': number,
    'city': city,
    'state': state,
    'country': country,
    'postalCode': postalCode,
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
    'villageName': villageName,
    'moo': moo,
    'houseSubtype': houseSubtype,
    'parkingType': parkingType,
    'isCornerPlot': isCornerPlot,
    'houseNotes': houseNotes,
  };

  bool get isValid {
    if (step == 1) return selectedPropertyType != null;
    if (step == 2) {
      final baseValid =
          (name?.isNotEmpty == true) &&
          (address?.isNotEmpty == true) &&
          (formattedAddressTh?.isNotEmpty == true);

      if (!baseValid) return false;

      final isCondoOrApt =
          selectedPropertyType == 'คอนโดมิเนียม' ||
          selectedPropertyType == 'อพาร์ตเมนต์';

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
      return propertyStyle != null;
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
    String? selectedPropertyType,
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
    String? houseColor,
    String? built,
    String? direction,
    String? availableFrom,
    List<XFile>? images,
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
    String? listingType,
    String? status,
    int? totalFloors,
    String? propertyStyle,
    List<String>? highlights,
    List<String>? facilities,
    PropertySpecificationFilters? specificationFilters,
    Map<String, dynamic>? dynamicValues,
  }) {
    return PropertyFormState(
      step: step ?? this.step,
      propertyFormStatus: propertyFormStatus ?? this.propertyFormStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      propertyId: propertyId ?? this.propertyId,
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
      highlights: highlights ?? this.highlights,
      facilities: facilities ?? this.facilities,
      specificationFilters: specificationFilters ?? this.specificationFilters,
      dynamicValues: dynamicValues ?? this.dynamicValues,
    );
  }

  Property get toProperty {
    // 1. Separate Dynamic Values into Specs (Scalar) and Values (Lists)
    final specsMap = <String, dynamic>{};
    final specValuesMap = <String, dynamic>{
      'good_points': highlights,
      'common_facilities': facilities,
    };

    dynamicValues.forEach((key, value) {
      if (value is List) {
        specValuesMap[key] = value;
      } else {
        specsMap[key] = value;
      }
    });

    // Explicitly set key fields into specs map if API expects them there
    specsMap['floors'] = totalFloors?.toString();
    specsMap['bedrooms'] = bedrooms?.toString();

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
      propertyType: selectedPropertyType ?? '',
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
      imageFiles: images,
      imageUrls: const [], // No URLs yet

      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    step,
    propertyFormStatus,
    errorMessage,
    propertyId,
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
    highlights,
    facilities,
    specificationFilters,
    dynamicValues,
  ];
}
