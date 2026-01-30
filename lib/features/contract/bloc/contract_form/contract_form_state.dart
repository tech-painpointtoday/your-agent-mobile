import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/contract_type.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/domain/entities/person_type.dart';
import 'package:youragent/domain/entities/property_owner.dart';

enum ContractFormStatus { initial, loading, success, failure, submmitting }

class ContractFormState extends Equatable {
  final int step;
  final ContractFormStatus status;
  final String? errorMessage;
  final bool isValid;

  // Step 1 Data
  final String propertyName;
  final DateTime? contractDate;
  final ContractType? contractType;
  final List<Property> properties;
  final Property? selectedProperty;

  // Step 2 Data
  final PersonType ownerType;
  final String ownerName;
  final String ownerIdCard;
  final String ownerAddress;
  final String ownerPhone;
  final String ownerEmail;
  final String ownerSignatory;
  final List<PropertyOwner> owners;
  final PropertyOwner? selectedOwner;

  const ContractFormState({
    this.step = 1,
    this.status = ContractFormStatus.initial,
    this.errorMessage,
    this.isValid = false,
    this.propertyName = '',
    this.contractDate,
    this.contractType,
    this.properties = const [],
    this.selectedProperty,
    this.ownerType = PersonType.individual,
    this.ownerName = '',
    this.ownerIdCard = '',
    this.ownerAddress = '',
    this.ownerPhone = '',
    this.ownerEmail = '',
    this.ownerSignatory = '',
    this.owners = const [],
    this.selectedOwner,
  });

  ContractFormState copyWith({
    int? step,
    ContractFormStatus? status,
    String? errorMessage,
    bool? isValid,
    String? propertyName,
    DateTime? contractDate,
    ContractType? contractType,
    List<Property>? properties,
    Property? selectedProperty,
    PersonType? ownerType,
    String? ownerName,
    String? ownerIdCard,
    String? ownerAddress,
    String? ownerPhone,
    String? ownerEmail,
    String? ownerSignatory,
    List<PropertyOwner>? owners,
    PropertyOwner? selectedOwner,
  }) {
    return ContractFormState(
      step: step ?? this.step,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isValid: isValid ?? this.isValid,
      propertyName: propertyName ?? this.propertyName,
      contractDate: contractDate ?? this.contractDate,
      contractType: contractType ?? this.contractType,
      properties: properties ?? this.properties,
      selectedProperty: selectedProperty ?? this.selectedProperty,
      ownerType: ownerType ?? this.ownerType,
      ownerName: ownerName ?? this.ownerName,
      ownerIdCard: ownerIdCard ?? this.ownerIdCard,
      ownerAddress: ownerAddress ?? this.ownerAddress,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      ownerSignatory: ownerSignatory ?? this.ownerSignatory,
      owners: owners ?? this.owners,
      selectedOwner: selectedOwner ?? this.selectedOwner,
    );
  }

  @override
  List<Object?> get props => [
    step,
    status,
    errorMessage,
    isValid,
    propertyName,
    contractDate,
    contractType,
    properties,
    selectedProperty,
    ownerType,
    ownerName,
    ownerIdCard,
    ownerAddress,
    ownerPhone,
    ownerEmail,
    ownerSignatory,
    owners,
    selectedOwner,
  ];
}
