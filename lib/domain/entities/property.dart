import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'property_details.dart';
import 'property_image.dart';

/// Represents the status/approval state of a property listing
enum PropertyApprovalStatus {
  pending, // รอการอนุมัติ
  approved, // อนุมัติแล้ว
  rejected, // ไม่อนุมัติ
}

enum PropertyColor {
  white,
  cream,
  grey,
  black,
  brown,
  red,
  yellow,
  green,
  blue,
  pink,
  purple,
  orange;

  String get label => switch (this) {
    white => 'ขาว',
    cream => 'ครีม',
    grey => 'เทา',
    black => 'ดำ',
    brown => 'น้ำตาล',
    red => 'แดง',
    yellow => 'เหลือง',
    green => 'เขียว',
    blue => 'ฟ้า',
    pink => 'ชมพู',
    purple => 'ม่วง',
    orange => 'ส้ม',
  };

  String get value => switch (this) {
    white => 'white',
    cream => 'cream',
    grey => 'grey',
    black => 'black',
    brown => 'brown',
    red => 'red',
    yellow => 'yellow',
    green => 'green',
    blue => 'blue',
    pink => 'pink',
    purple => 'purple',
    orange => 'orange',
  };

  static PropertyColor? fromLabel(String? label) {
    if (label == null) return null;
    try {
      return PropertyColor.values.firstWhere((e) => e.label == label);
    } catch (_) {
      return null;
    }
  }
}

enum PropertyDirection {
  north,
  south,
  east,
  west,
  northEast,
  southEast,
  northWest,
  southWest;

  String get label => switch (this) {
    north => 'ทิศเหนือ',
    south => 'ทิศใต้',
    east => 'ทิศตะวันออก',
    west => 'ทิศตะวันตก',
    northEast => 'ทิศตะวันออกเฉียงเหนือ',
    southEast => 'ทิศตะวันออกเฉียงใต้',
    northWest => 'ทิศตะวันตกเฉียงเหนือ',
    southWest => 'ทิศตะวันตกเฉียงใต้',
  };

  String get value => switch (this) {
    north => 'N',
    south => 'S',
    east => 'E',
    west => 'W',
    northEast => 'NE',
    southEast => 'SE',
    northWest => 'NW',
    southWest => 'SW',
  };

  static PropertyDirection? fromLabel(String? val) {
    if (val == null) return null;
    try {
      return PropertyDirection.values.firstWhere((e) => e.value == val);
    } catch (_) {
      return null;
    }
  }
}

enum PropertyType {
  house,
  condo,
  townhome,
  apartment,
  homeOffice,
  poolVilla;

  String get label => switch (this) {
    house => 'บ้าน',
    condo => 'คอนโดมิเนียม',
    townhome => 'ทาวน์เฮาส์/ทาวน์โฮม',
    apartment => 'อพาร์ตเมนต์',
    homeOffice => 'โฮมออฟฟิศ',
    poolVilla => 'พูลวิลล่า',
  };

  String get value => switch (this) {
    house => 'house',
    condo => 'condo',
    townhome => 'townhome',
    apartment => 'apartment',
    homeOffice => 'home_office',
    poolVilla => 'pool_villa',
  };

  static PropertyType? fromValue(String? value) {
    if (value == null) return null;
    try {
      return PropertyType.values.firstWhere((e) => e.value == value);
    } catch (_) {
      return null;
    }
  }
}

enum PropertyListingType {
  sale,
  rent,
  saleAndRent;

  String get value => switch (this) {
    sale => 'sale',
    rent => 'rent',
    saleAndRent => 'sale_rent',
  };

  static PropertyListingType? fromValue(String? value) {
    if (value == null) return null;
    return PropertyListingType.values.firstWhere(
      (e) => e.value == value || e.name == value,
      orElse: () => sale,
    );
  }
}

enum PropertyAvailabilityStatus {
  available,
  unavailable;

  String get value => switch (this) {
    available => 'available',
    unavailable => 'unavailable',
  };

  static PropertyAvailabilityStatus? fromValue(String? value) {
    if (value == null) return null;
    return PropertyAvailabilityStatus.values.firstWhere(
      (e) => e.value == value || e.name == value,
      orElse: () => available,
    );
  }
}

class Property extends Equatable {
  final int? id;
  final String? code;
  final String title;
  final String? name; // Internal name / Project name
  final String description;

  // Location
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool locationSet;
  final String? number;
  final String? city;
  final String? state;
  final String? province;
  final String? country;
  final String? postalCode;
  final String? subdistrict;
  final String? district;
  final String? road;
  final String? soi;
  final String? formattedAddressEn;
  final String? formattedAddressTh;

  // Pricing & Status
  final double price;
  final PropertyApprovalStatus approvalStatus;
  final PropertyListingType? listingType;
  final PropertyAvailabilityStatus? status;
  final DateTime? availableFrom;

  // Specifications
  final int bedrooms;
  final int bathrooms;
  final int? garage;
  final double? landSize; // Land area (sq wah)
  final double? buildingSize;
  final PropertyType? propertyType;
  final int? totalFloors; // Total floors of the property
  final PropertyColor? houseColor;
  final DateTime? built; // Year/Date built
  final PropertyDirection? direction;
  final String? condoProjectNameTh;
  final String? condoProjectNameEn;
  final String? developerNameTh;
  final String? developerNameEn;
  final String? villageName;
  final String? tower;
  final String? floor;
  final String? unitNo;
  final String? moo;

  // Dynamic / Collections
  final Map<String, dynamic>
  specifications; // raw dynamic specs (e.g. "floors": "2")
  final Map<String, dynamic> specificationValues; // raw dynamic values
  final CondoDetails? condoDetails;
  final HouseDetails? houseDetails;

  // Images
  final String? imageUrl; // Cover image URL
  final List<PropertyImage> images; // All remote image objects
  final List<XFile> imageFiles; // Local image files (for Preview)

  // Metadata
  final DateTime createdAt;
  final int viewCount;
  final bool isDraft; // Draft status from API

  const Property({
    this.id,
    this.code,
    required this.title,
    this.name,
    this.description = '',
    this.address,
    this.latitude,
    this.longitude,
    this.locationSet = false,
    this.number,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.subdistrict,
    this.district,
    this.province,
    this.road,
    this.soi,
    this.formattedAddressEn,
    this.formattedAddressTh,
    this.price = 0,
    this.approvalStatus = PropertyApprovalStatus.pending,
    this.listingType,
    this.status,
    this.availableFrom,
    this.bedrooms = 0,
    this.bathrooms = 0,
    this.garage,
    this.landSize,
    this.buildingSize,
    this.propertyType,
    this.totalFloors,
    this.houseColor,
    this.built,
    this.direction,
    this.condoProjectNameTh,
    this.condoProjectNameEn,
    this.developerNameTh,
    this.developerNameEn,
    this.villageName,
    this.tower,
    this.floor,
    this.unitNo,
    this.moo,
    this.specifications = const {},
    this.specificationValues = const {},
    this.condoDetails,
    this.houseDetails,
    this.imageUrl,
    this.images = const [],
    this.imageFiles = const [],
    required this.createdAt,
    this.viewCount = 0,
    this.isDraft = false,
  });

  /// Get image URLs as a list of strings (for compatibility)
  List<String> get imageUrls =>
      images.map((e) => e.url).whereType<String>().toList();

  /// Factory: Parses Nested API Response (Smart Parser)
  factory Property.fromJson(Map<String, dynamic> json) {
    // 1. Extract Core Data Wrapper
    final Map<String, dynamic> data =
        json.containsKey('data') && json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    // 2. Extract Nested Objects (Safely)
    final Map<String, dynamic> specs = data['specs'] is Map
        ? Map<String, dynamic>.from(data['specs'] as Map)
        : <String, dynamic>{};
    final Map<String, dynamic> location = data['location'] is Map
        ? Map<String, dynamic>.from(data['location'] as Map)
        : <String, dynamic>{};
    final Map<String, dynamic> specificationValues =
        specs['specification_values'] is Map
        ? Map<String, dynamic>.from(specs['specification_values'] as Map)
        : <String, dynamic>{};
    Map<String, dynamic> specifications = specs['specifications'] is Map
        ? Map<String, dynamic>.from(specs['specifications'] as Map)
        : <String, dynamic>{};

    // 2b. Merge condo_details / house details from GET response for edit/draft
    // API: condo_details = { id, property_id, condo_project_id, tower, unit_no, floor, layout_code, condo_project: { id, developer_id, ... } }
    String? condoProjectNameTh;
    String? condoProjectNameEn;
    String? developerNameTh;
    String? developerNameEn;

    final condoDetails = data['condo_details'];
    if (condoDetails is Map<String, dynamic>) {
      final projectId = condoDetails['condo_project_id'];
      if (projectId != null) {
        specifications['condo_project_id'] = projectId is int
            ? projectId
            : int.tryParse(projectId.toString());
      }
      final nestedProject = condoDetails['condo_project'];
      if (nestedProject is Map<String, dynamic>) {
        condoProjectNameTh = nestedProject['name_th']?.toString();
        condoProjectNameEn = nestedProject['name_en']?.toString();
        final developer = nestedProject['developer'];
        if (developer is Map<String, dynamic>) {
          developerNameTh = developer['name_th']?.toString();
          developerNameEn = developer['name_en']?.toString();
        }
        final devId = nestedProject['developer_id'];
        if (devId != null) {
          specifications['developer_id'] = devId is int
              ? devId
              : int.tryParse(devId.toString());
        }
      }
      if (condoDetails['tower'] != null) {
        specifications['tower'] = condoDetails['tower'].toString();
      }
      if (condoDetails['floor'] != null) {
        specifications['floor'] = condoDetails['floor'].toString();
      }
      if (condoDetails['unit_no'] != null) {
        specifications['unit_no'] = condoDetails['unit_no'].toString();
      }
    }

    // API: house_details = { id, property_id, village_name, moo, house_subtype, parking_type, is_corner_plot, notes, ... }
    // API: house_details = { id, developer, house_project_id, village_name, ... }
    final houseDetails = data['house_details'];
    if (houseDetails is Map<String, dynamic>) {
      // 1. House Project ID
      final projectId = houseDetails['house_project_id'];
      if (projectId != null) {
        specifications['house_project_id'] = projectId is int
            ? projectId
            : int.tryParse(projectId.toString());
      }

      // 2. Developer (directly in house_details or nested house_project)
      var developer = houseDetails['developer'];
      final nestedProject = houseDetails['house_project'];

      if (developer == null && nestedProject is Map<String, dynamic>) {
        developer = nestedProject['developer'];
      }

      if (developer is Map<String, dynamic>) {
        developerNameTh ??= developer['name_th']?.toString();
        developerNameEn ??= developer['name_en']?.toString();

        final devId = developer['id'];
        if (devId != null) {
          specifications['developer_id'] = devId is int
              ? devId
              : int.tryParse(devId.toString());
        }
      }

      // 3. House Project Name
      // Use house_project name if available, otherwise village_name
      if (nestedProject is Map<String, dynamic>) {
        // If needed, we could map this to a specific field.
        // For now, village_name usually holds the project name for display.
        // If village_name is null but we have a project, maybe use project name?
        if (houseDetails['village_name'] == null) {
          final hpName = nestedProject['name_th'] ?? nestedProject['name'];
          if (hpName != null) {
            specifications['village_name'] = hpName.toString();
          }
        }
      }

      if (houseDetails['village_name'] != null) {
        specifications['village_name'] = houseDetails['village_name']
            .toString();
      }
      if (houseDetails['moo'] != null) {
        specifications['moo'] = houseDetails['moo'].toString();
      }
      if (houseDetails['house_subtype'] != null) {
        specifications['house_subtype'] = houseDetails['house_subtype']
            .toString();
      }
      if (houseDetails['parking_type'] != null) {
        specifications['parking_type'] = houseDetails['parking_type']
            .toString();
      }
      if (houseDetails['is_corner_plot'] != null) {
        specifications['is_corner_plot'] =
            houseDetails['is_corner_plot'] == true ||
            houseDetails['is_corner_plot'] == 'true';
      }
      if (houseDetails['notes'] != null) {
        specifications['house_notes'] = houseDetails['notes'].toString();
      }
    }

    // 3. Helper Parsers
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    String? parseString(dynamic val) {
      if (val == null) return null;
      if (val is String) return val;
      // Intentionally do NOT call toString() on Maps/Lists to reference them as strings
      if (val is num) return val.toString();
      return null;
    }

    PropertyApprovalStatus parseStatus(String? s) {
      if (s == 'approved') return PropertyApprovalStatus.approved;
      if (s == 'rejected') return PropertyApprovalStatus.rejected;
      return PropertyApprovalStatus.pending;
    }

    // 4. Parse Images
    final imagesList = (data['images'] is List) ? data['images'] as List : [];
    final parsedImages = imagesList
        .map((img) {
          if (img is Map<String, dynamic>) {
            return PropertyImage.fromJson(img);
          }
          return null;
        })
        .whereType<PropertyImage>()
        .toList();
    final firstImage = parsedImages.isNotEmpty ? parsedImages.first.url : null;

    // 5. Construct Entity
    return Property(
      id: parseInt(data['id']),
      code: parseString(data['code']),
      // Title logic: Prefer title -> name -> generated name
      title:
          parseString(data['title']) ??
          parseString(specs['name']) ??
          'New Property',
      name: parseString(specs['name']),
      description:
          parseString(data['description']) ??
          parseString(specs['description']) ??
          '',

      // Status & Price
      approvalStatus: parseStatus(data['approval_status']?.toString()),
      price: parseDouble(specs['price'] ?? data['price']),
      listingType: PropertyListingType.fromValue(
        parseString(data['listing_type']),
      ),
      // Ensure we don't pick up the complex 'status' object as the string status
      status: PropertyAvailabilityStatus.fromValue(
        parseString(specs['status']),
      ),
      availableFrom: DateTime.tryParse(
        specs['available_from']?.toString() ?? '',
      ),

      // Location (Priority: Specs -> Location Object)
      address:
          parseString(specs['address']) ??
          parseString(location['formatted_address_th']),
      latitude: location['latitude'] == null
          ? null
          : parseDouble(location['latitude']),
      longitude: location['longitude'] == null
          ? null
          : parseDouble(location['longitude']),
      locationSet: location.isNotEmpty,
      number: location['number'] is Map
          ? location['number']['original']?.toString()
          : location['number']?.toString(),
      city: parseString(location['city']),
      state:
          parseString(location['province']) ?? parseString(location['state']),
      province: parseString(location['province']),
      country: parseString(location['country']),
      postalCode: parseString(location['postal_code']),
      district: parseString(location['district']),
      subdistrict: parseString(location['subdistrict']),
      road: parseString(location['road']),
      soi: parseString(location['soi']),
      formattedAddressTh: parseString(location['formatted_address_th']),
      formattedAddressEn: parseString(location['formatted_address_en']),

      // Details
      propertyType: PropertyType.fromValue(
        parseString(specs['type']) ?? parseString(data['property_type']),
      ),
      bedrooms: parseInt(specs['bedrooms']),
      bathrooms: parseInt(specs['bathrooms']),
      garage: parseInt(specs['garage']),
      landSize: parseDouble(specs['land_size']),
      buildingSize: parseDouble(specs['building_size']),
      houseColor: PropertyColor.fromLabel(parseString(specs['house_color'])),
      built: DateTime.tryParse(data['built']?.toString() ?? ''),
      direction: PropertyDirection.fromLabel(location['direction']),
      condoProjectNameTh: condoProjectNameTh,
      condoProjectNameEn: condoProjectNameEn,
      developerNameTh: developerNameTh,
      developerNameEn: developerNameEn,
      villageName: specifications['village_name']?.toString(),
      tower: specifications['tower']?.toString(),
      floor: specifications['floor']?.toString(),
      unitNo: specifications['unit_no']?.toString(),
      moo: specifications['moo']?.toString(),
      totalFloors: parseInt(
        specs['total_floors'] ?? specifications['floors'],
      ), // Try spec object then raw map
      // Dynamic Values
      specifications: Map<String, dynamic>.from(specifications),
      specificationValues: Map<String, dynamic>.from(specificationValues),
      condoDetails: condoDetails is Map<String, dynamic>
          ? CondoDetails.fromJson(condoDetails)
          : null,
      houseDetails: houseDetails is Map<String, dynamic>
          ? HouseDetails.fromJson(houseDetails)
          : null,

      // Images
      imageUrl: firstImage,
      images: parsedImages,

      // Metadata
      createdAt:
          DateTime.tryParse(data['created_at']?.toString() ?? '') ??
          DateTime.now(),
      viewCount: parseInt(data['view_count']),
      isDraft: data['is_draft'] == true,
    );
  }

  /// Converts Entity to API Create Payload (Flat Structure)
  Map<String, dynamic> toCreatePayload() {
    return {
      'name': title, // API expects 'name'
      'type': propertyType?.value,
      'price': price,
      'description': description,
      'listing_type': listingType?.value,
      'status': status?.value,
      'built': built?.toUtc().toIso8601String(),
      'available_from': availableFrom,
      'house_color': houseColor?.value,
      'direction': direction?.value,

      // Main Stats
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'garage': garage,
      'land_size': landSize,
      'building_size': buildingSize,

      // Location
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'number': number,
      'city': city,
      'state': state, // Province
      'province': state, // Redundant but safe
      'postal_code': postalCode,
      'district': district,
      'subdistrict': subdistrict,
      'road': road,
      'soi': soi,
      'country': country,
      'formatted_address_en': formattedAddressEn,
      'formatted_address_th': formattedAddressTh,

      // Dynamic Specifications Map
      'specifications': {
        ...specifications,
        'floors': totalFloors?.toString(),
        'bedrooms': bedrooms.toString(),
        'bathrooms': bathrooms.toString(),
        'garage': garage?.toString(),
      },

      // Dynamic Values Map (Multi-selects)
      'specification_values': specificationValues,
    };
  }

  Property copyWith({
    int? id,
    String? code,
    String? title,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    bool? locationSet,
    String? number,
    String? city,
    String? state,
    String? province,
    String? country,
    String? postalCode,
    String? subdistrict,
    String? district,
    String? road,
    String? soi,
    String? formattedAddressEn,
    String? formattedAddressTh,
    double? price,
    PropertyApprovalStatus? approvalStatus,
    PropertyListingType? listingType,
    PropertyAvailabilityStatus? status,
    DateTime? availableFrom,
    int? bedrooms,
    int? bathrooms,
    int? garage,
    double? landSize,
    double? buildingSize,
    PropertyType? propertyType,
    int? totalFloors,
    PropertyColor? houseColor,
    DateTime? built,
    PropertyDirection? direction,
    Map<String, dynamic>? specifications,
    Map<String, dynamic>? specificationValues,
    CondoDetails? condoDetails,
    HouseDetails? houseDetails,
    String? imageUrl,
    List<PropertyImage>? images,
    List<XFile>? imageFiles,
    DateTime? createdAt,
    int? viewCount,
    bool? isDraft,
  }) {
    return Property(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationSet: locationSet ?? this.locationSet,
      number: number ?? this.number,
      city: city ?? this.city,
      state: state ?? this.state,
      province: province ?? this.province,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      subdistrict: subdistrict ?? this.subdistrict,
      district: district ?? this.district,
      road: road ?? this.road,
      soi: soi ?? this.soi,
      formattedAddressEn: formattedAddressEn ?? this.formattedAddressEn,
      formattedAddressTh: formattedAddressTh ?? this.formattedAddressTh,
      price: price ?? this.price,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      listingType: listingType ?? this.listingType,
      status: status ?? this.status,
      availableFrom: availableFrom ?? this.availableFrom,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      garage: garage ?? this.garage,
      landSize: landSize ?? this.landSize,
      buildingSize: buildingSize ?? this.buildingSize,
      propertyType: propertyType ?? this.propertyType,
      totalFloors: totalFloors ?? this.totalFloors,
      houseColor: houseColor ?? this.houseColor,
      built: built ?? this.built,
      direction: direction ?? this.direction,
      specifications: specifications ?? this.specifications,
      specificationValues: specificationValues ?? this.specificationValues,
      condoDetails: condoDetails ?? this.condoDetails,
      houseDetails: houseDetails ?? this.houseDetails,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      imageFiles: imageFiles ?? this.imageFiles,
      createdAt: createdAt ?? this.createdAt,
      viewCount: viewCount ?? this.viewCount,
      isDraft: isDraft ?? this.isDraft,
    );
  }

  Property get cleaned {
    dynamic clean(dynamic val) {
      if (val == null) return null;
      if (val is List) {
        final cleanedList = val
            .map((e) => clean(e))
            .where((e) => e != null)
            .toList();
        return cleanedList.isEmpty ? null : cleanedList;
      }
      if (val is Map) {
        final cleanedMap = <String, dynamic>{};
        val.forEach((key, value) {
          final cleanedValue = clean(value);
          if (cleanedValue != null) cleanedMap[key.toString()] = cleanedValue;
        });
        return cleanedMap.isEmpty ? null : cleanedMap;
      }
      final str = val.toString().trim();
      if (str.toUpperCase() == 'N/A' || str.isEmpty) return null;
      return val;
    }

    // Special clean for non-nullable title/description
    String cleanStr(String val) => clean(val) ?? '';
    String cleanTitle(String val) => clean(val) ?? 'New Property';

    return Property(
      id: id,
      code: clean(code),
      title: cleanTitle(title),
      name: clean(name),
      description: cleanStr(description),
      address: clean(address),
      latitude: latitude,
      longitude: longitude,
      locationSet: locationSet,
      number: clean(number),
      city: clean(city),
      state: clean(state),
      province: clean(province),
      country: clean(country),
      postalCode: clean(postalCode),
      subdistrict: clean(subdistrict),
      district: clean(district),
      road: clean(road),
      soi: clean(soi),
      formattedAddressEn: clean(formattedAddressEn),
      formattedAddressTh: clean(formattedAddressTh),
      price: price,
      approvalStatus: approvalStatus,
      listingType: listingType,
      status: status,
      availableFrom: availableFrom,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      garage: garage,
      landSize: landSize,
      buildingSize: buildingSize,
      propertyType: propertyType,
      totalFloors: totalFloors,
      houseColor: houseColor,
      built: built,
      direction: direction,
      specifications:
          (clean(specifications) as Map?)?.cast<String, dynamic>() ?? {},
      specificationValues:
          (clean(specificationValues) as Map?)?.cast<String, dynamic>() ?? {},
      condoDetails: condoDetails,
      houseDetails: houseDetails,
      imageUrl: imageUrl,
      images: images,
      imageFiles: imageFiles,
      createdAt: createdAt,
      viewCount: viewCount,
      isDraft: isDraft,
    );
  }

  @override
  List<Object?> get props => [
    id,
    code,
    title,
    price,
    address,
    approvalStatus,
    imageUrls,
    images,
    imageFiles,
    bedrooms,
    bathrooms,
    specifications,
    condoDetails,
    houseDetails,
    createdAt,
  ];
}
