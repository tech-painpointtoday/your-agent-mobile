import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/contract_type.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/domain/entities/person_type.dart';
import 'package:youragent/domain/entities/property_owner.dart';

abstract class ContractFormEvent extends Equatable {
  const ContractFormEvent();

  @override
  List<Object?> get props => [];
}

class ContractFormStepChanged extends ContractFormEvent {
  final int step;
  const ContractFormStepChanged(this.step);

  @override
  List<Object?> get props => [step];
}

class ContractFormPropertyNameUpdated extends ContractFormEvent {
  final String propertyName;
  const ContractFormPropertyNameUpdated(this.propertyName);

  @override
  List<Object?> get props => [propertyName];
}

class ContractFormPropertiesFetched extends ContractFormEvent {
  final String query;
  const ContractFormPropertiesFetched(this.query);

  @override
  List<Object?> get props => [query];
}

class ContractFormPropertySelected extends ContractFormEvent {
  final Property property;
  const ContractFormPropertySelected(this.property);

  @override
  List<Object?> get props => [property];
}

class ContractFormDateUpdated extends ContractFormEvent {
  final DateTime date;
  const ContractFormDateUpdated(this.date);

  @override
  List<Object?> get props => [date];
}

class ContractFormTypeUpdated extends ContractFormEvent {
  final ContractType type;
  const ContractFormTypeUpdated(this.type);

  @override
  List<Object?> get props => [type];
}

class ContractFormSubmitted extends ContractFormEvent {
  const ContractFormSubmitted();
}

// Step 2 Events
class ContractFormOwnerTypeUpdated extends ContractFormEvent {
  final PersonType type;
  const ContractFormOwnerTypeUpdated(this.type);
  @override
  List<Object?> get props => [type];
}

class ContractFormOwnerNameUpdated extends ContractFormEvent {
  final String name;
  const ContractFormOwnerNameUpdated(this.name);
  @override
  List<Object?> get props => [name];
}

class ContractFormOwnerIdCardUpdated extends ContractFormEvent {
  final String idCard;
  const ContractFormOwnerIdCardUpdated(this.idCard);
  @override
  List<Object?> get props => [idCard];
}

class ContractFormOwnerAddressUpdated extends ContractFormEvent {
  final String address;
  const ContractFormOwnerAddressUpdated(this.address);
  @override
  List<Object?> get props => [address];
}

class ContractFormOwnerPhoneUpdated extends ContractFormEvent {
  final String phone;
  const ContractFormOwnerPhoneUpdated(this.phone);
  @override
  List<Object?> get props => [phone];
}

class ContractFormOwnerEmailUpdated extends ContractFormEvent {
  final String email;
  const ContractFormOwnerEmailUpdated(this.email);
  @override
  List<Object?> get props => [email];
}

class ContractFormOwnerSignatoryUpdated extends ContractFormEvent {
  final String signatory;
  const ContractFormOwnerSignatoryUpdated(this.signatory);
  @override
  List<Object?> get props => [signatory];
}

class ContractFormOwnersFetched extends ContractFormEvent {
  final String query;
  const ContractFormOwnersFetched(this.query);
  @override
  List<Object?> get props => [query];
}

class ContractFormOwnerSelected extends ContractFormEvent {
  final PropertyOwner owner;
  const ContractFormOwnerSelected(this.owner);
  @override
  List<Object?> get props => [owner];
}
