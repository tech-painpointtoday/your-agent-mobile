import 'package:equatable/equatable.dart';
import 'property.dart';
import 'owner.dart';
import 'property_image.dart';

class ContractCreateData extends Equatable {
  final Property? property;
  final Owner? owner;
  final String? ownerType;
  final String? contractType;
  final List<PropertyImage> propertyImages;
  final List<Bank> banks;
  final Map<String, String> accountTypes;
  final List<Map<String, dynamic>> appliances;
  final List<Map<String, dynamic>> furniture;

  const ContractCreateData({
    this.property,
    this.owner,
    this.ownerType,
    this.contractType,
    this.propertyImages = const [],
    this.banks = const [],
    this.accountTypes = const {},
    this.appliances = const [],
    this.furniture = const [],
  });

  factory ContractCreateData.fromJson(Map<String, dynamic> json) {
    return ContractCreateData(
      property: json['property'] != null
          ? Property.fromJson(json['property'] as Map<String, dynamic>)
          : null,
      owner: json['owner'] != null
          ? Owner.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
      ownerType: json['owner_type']?.toString(),
      contractType: json['contract_type']?.toString(),
      propertyImages:
          (json['property_images'] as List<dynamic>?)
              ?.map((e) => PropertyImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      banks:
          (json['banks'] as List<dynamic>?)
              ?.map((e) => Bank.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      accountTypes:
          (json['account_types'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
      appliances:
          (json['appliances'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      furniture:
          (json['furniture'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
    property,
    owner,
    ownerType,
    contractType,
    propertyImages,
    banks,
    accountTypes,
    appliances,
    furniture,
  ];
}

class Bank extends Equatable {
  final String code;
  final String name;

  const Bank({required this.code, required this.name});

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [code, name];

  @override
  String toString() => name;
}
