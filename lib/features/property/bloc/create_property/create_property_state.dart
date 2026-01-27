import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

enum CreatePropertyStatus {
  initial,
  submissionInProgress,
  submissionSuccess,
  submissionFailure,
}

class CreatePropertyState extends Equatable {
  final int step;
  final CreatePropertyStatus status;
  final String? errorMessage;
  final String? propertyId; // Resulting property ID after success

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

  const CreatePropertyState({
    this.step = 1,
    this.status = CreatePropertyStatus.initial,
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
  });

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
    if (step == 2) return name != null && name!.isNotEmpty && price != null;
    return true; // Simplified for now
  }

  CreatePropertyState copyWith({
    int? step,
    CreatePropertyStatus? status,
    String? errorMessage,
    String? propertyId,
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
  }) {
    return CreatePropertyState(
      step: step ?? this.step,
      status: status ?? this.status,
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
    );
  }

  @override
  List<Object?> get props => [
    step,
    status,
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
  ];
}
