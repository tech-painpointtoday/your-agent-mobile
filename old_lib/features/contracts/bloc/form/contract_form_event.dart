import 'package:equatable/equatable.dart';
import 'package:youragent/data/models/contract_model.dart';
import 'package:youragent/data/models/property_model.dart';
import 'package:youragent/domain/entities/contract_type.dart';

/// Events for Contract Form BLoC
abstract class ContractFormEvent extends Equatable {
  const ContractFormEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize form for Create mode (from Property or Booking)
class ContractFormInitializeCreate extends ContractFormEvent {
  final int? propertyId;
  final int? bookingId;

  const ContractFormInitializeCreate({this.propertyId, this.bookingId});

  @override
  List<Object?> get props => [propertyId, bookingId];
}

/// Initialize form for Edit mode
class ContractFormInitializeEdit extends ContractFormEvent {
  final int contractId;

  const ContractFormInitializeEdit({required this.contractId});

  @override
  List<Object?> get props => [contractId];
}

/// Initialize screen for Detail/View mode
class ContractFormInitializeDetail extends ContractFormEvent {
  final int contractId;

  const ContractFormInitializeDetail({required this.contractId});

  @override
  List<Object?> get props => [contractId];
}

/// Initialize form with contract/property data
class ContractFormInitialized extends ContractFormEvent {
  final ContractModel? contract;
  final PropertyModel? property;
  final Map<String, dynamic>? contractJson; // Full API response JSON
  final bool isReadOnly;

  const ContractFormInitialized({
    this.contract,
    this.property,
    this.contractJson,
    this.isReadOnly = false,
  });

  @override
  List<Object?> get props => [contract, property, contractJson, isReadOnly];
}

/// Update form field value
class ContractFormFieldUpdated extends ContractFormEvent {
  final String field;
  final dynamic value;

  const ContractFormFieldUpdated({
    required this.field,
    required this.value,
  });

  @override
  List<Object?> get props => [field, value];
}

/// Update contract type
class ContractFormTypeChanged extends ContractFormEvent {
  final ContractType? type;

  const ContractFormTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

/// Update lessor type
class ContractFormLessorTypeChanged extends ContractFormEvent {
  final String? type; // 'person' or 'company'

  const ContractFormLessorTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

/// Update lessee type
class ContractFormLesseeTypeChanged extends ContractFormEvent {
  final String? type; // 'person' or 'company'

  const ContractFormLesseeTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

/// Update property type
class ContractFormPropertyTypeChanged extends ContractFormEvent {
  final String? type;

  const ContractFormPropertyTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

/// Update country
class ContractFormCountryChanged extends ContractFormEvent {
  final String? country;

  const ContractFormCountryChanged(this.country);

  @override
  List<Object?> get props => [country];
}

/// Update province
class ContractFormProvinceChanged extends ContractFormEvent {
  final String? province;

  const ContractFormProvinceChanged(this.province);

  @override
  List<Object?> get props => [province];
}

/// Update district
class ContractFormDistrictChanged extends ContractFormEvent {
  final String? district;

  const ContractFormDistrictChanged(this.district);

  @override
  List<Object?> get props => [district];
}

/// Update subdistrict
class ContractFormSubdistrictChanged extends ContractFormEvent {
  final String? subdistrict;

  const ContractFormSubdistrictChanged(this.subdistrict);

  @override
  List<Object?> get props => [subdistrict];
}

/// Update contract date
class ContractFormContractDateChanged extends ContractFormEvent {
  final DateTime? date;

  const ContractFormContractDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

/// Update start date
class ContractFormStartDateChanged extends ContractFormEvent {
  final DateTime? date;

  const ContractFormStartDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

/// Update end date
class ContractFormEndDateChanged extends ContractFormEvent {
  final DateTime? date;

  const ContractFormEndDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

/// Update renewal format
class ContractFormRenewalFormatChanged extends ContractFormEvent {
  final String? format;

  const ContractFormRenewalFormatChanged(this.format);

  @override
  List<Object?> get props => [format];
}

/// Update payment channel
class ContractFormPaymentChannelChanged extends ContractFormEvent {
  final String? channel;

  const ContractFormPaymentChannelChanged(this.channel);

  @override
  List<Object?> get props => [channel];
}

/// Submit form
class ContractFormSubmitted extends ContractFormEvent {
  final Map<String, dynamic> formData;

  const ContractFormSubmitted({required this.formData});

  @override
  List<Object?> get props => [formData];
}

/// Register a new client (Buyer or Seller)
class ContractFormRegisterClient extends ContractFormEvent {
  final String type; // 'lessor' (Seller) or 'lessee' (Buyer)
  final Map<String, dynamic> data; // Registration data: name, email, password, password_confirmation

  const ContractFormRegisterClient({
    required this.type,
    required this.data,
  });

  @override
  List<Object?> get props => [type, data];
}

/// Clear registration status for a client type
class ContractFormClearRegistration extends ContractFormEvent {
  final String type; // 'lessor' or 'lessee'

  const ContractFormClearRegistration({
    required this.type,
  });

  @override
  List<Object?> get props => [type];
}
