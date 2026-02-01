import 'package:equatable/equatable.dart';

class PropertyLocation extends Equatable {
  final int? id;
  final int? propertyId;
  final String? address;
  final String? villageName;
  final String? subDistrict; // for manual parsing
  final String? subdistrict; // matches JSON 'subdistrict'
  final String? district; // amphoe
  final String? province; // province
  final String? zipcode;
  final String? postalCode; // matches JSON 'postal_code'
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? formattedAddressTh;
  final String? formattedAddressEn;

  const PropertyLocation({
    this.id,
    this.propertyId,
    this.address,
    this.villageName,
    this.subDistrict,
    this.subdistrict,
    this.district,
    this.province,
    this.zipcode,
    this.postalCode,
    this.country,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.formattedAddressTh,
    this.formattedAddressEn,
  });

  factory PropertyLocation.fromJson(Map<String, dynamic> json) {
    return PropertyLocation(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      propertyId: json['property_id'] is int
          ? json['property_id']
          : int.tryParse(json['property_id']?.toString() ?? ''),
      address: json['address']?.toString(),
      villageName: json['village_name']?.toString(),
      subDistrict: json['sub_district']?.toString(),
      subdistrict: json['subdistrict']?.toString(),
      district: json['district']?.toString(),
      province: json['province']?.toString(),
      zipcode: json['zipcode']?.toString(),
      postalCode: json['postal_code']?.toString(),
      country: json['country']?.toString(),
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      city: json['city']?.toString() ?? json['district']?.toString(),
      state: json['state']?.toString() ?? json['province']?.toString(),
      formattedAddressTh: json['formatted_address_th']?.toString(),
      formattedAddressEn: json['formatted_address_en']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'address': address,
      'village_name': villageName,
      'sub_district': subDistrict,
      'subdistrict': subdistrict,
      'district': district,
      'province': province,
      'zipcode': zipcode,
      'postal_code': postalCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'state': state,
      'formatted_address_th': formattedAddressTh,
      'formatted_address_en': formattedAddressEn,
    };
  }

  @override
  List<Object?> get props => [
    id,
    propertyId,
    address,
    villageName,
    subDistrict,
    subdistrict,
    district,
    province,
    zipcode,
    postalCode,
    country,
    latitude,
    longitude,
    city,
    state,
    formattedAddressTh,
    formattedAddressEn,
  ];
}
