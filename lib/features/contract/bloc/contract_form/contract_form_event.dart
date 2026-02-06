import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/contract.dart';
import 'package:youragent/domain/entities/contract_type.dart';
import 'package:youragent/domain/entities/person_type.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/domain/entities/owner.dart';
import 'package:youragent/domain/entities/buyer.dart';
import 'package:youragent/domain/entities/appliance_item.dart';
import 'package:youragent/domain/entities/furniture_item.dart';

abstract class ContractFormEvent extends Equatable {
  const ContractFormEvent();

  @override
  List<Object?> get props => [];
}

class ContractFormInitialized extends ContractFormEvent {
  final Contract contract;
  const ContractFormInitialized(this.contract);

  @override
  List<Object?> get props => [contract];
}

class ContractFormEditStarted extends ContractFormEvent {
  final int contractId;
  const ContractFormEditStarted(this.contractId);

  @override
  List<Object?> get props => [contractId];
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

class ContractFormDraftSubmitted extends ContractFormEvent {
  const ContractFormDraftSubmitted();
}

// Step 1 Refinement Events
class ContractFormLeaseFormatUpdated extends ContractFormEvent {
  final String format;
  const ContractFormLeaseFormatUpdated(this.format);
  @override
  List<Object?> get props => [format];
}

class ContractFormLeaseStartDateUpdated extends ContractFormEvent {
  final DateTime? date;
  const ContractFormLeaseStartDateUpdated(this.date);
  @override
  List<Object?> get props => [date];
}

class ContractFormLeaseEndDateUpdated extends ContractFormEvent {
  final DateTime? date;
  const ContractFormLeaseEndDateUpdated(this.date);
  @override
  List<Object?> get props => [date];
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
  final Owner owner;
  const ContractFormOwnerSelected(this.owner);
  @override
  List<Object?> get props => [owner];
}

// Step 3 Events
class ContractFormBuyerTypeUpdated extends ContractFormEvent {
  final PersonType type;
  const ContractFormBuyerTypeUpdated(this.type);
  @override
  List<Object?> get props => [type];
}

class ContractFormBuyerNameUpdated extends ContractFormEvent {
  final String name;
  const ContractFormBuyerNameUpdated(this.name);
  @override
  List<Object?> get props => [name];
}

class ContractFormBuyerIdCardUpdated extends ContractFormEvent {
  final String idCard;
  const ContractFormBuyerIdCardUpdated(this.idCard);
  @override
  List<Object?> get props => [idCard];
}

class ContractFormBuyerAddressUpdated extends ContractFormEvent {
  final String address;
  const ContractFormBuyerAddressUpdated(this.address);
  @override
  List<Object?> get props => [address];
}

class ContractFormBuyerPhoneUpdated extends ContractFormEvent {
  final String phone;
  const ContractFormBuyerPhoneUpdated(this.phone);
  @override
  List<Object?> get props => [phone];
}

class ContractFormBuyerEmailUpdated extends ContractFormEvent {
  final String email;
  const ContractFormBuyerEmailUpdated(this.email);
  @override
  List<Object?> get props => [email];
}

class ContractFormBuyersFetched extends ContractFormEvent {
  final String query;
  const ContractFormBuyersFetched(this.query);
  @override
  List<Object?> get props => [query];
}

class ContractFormBuyerSelected extends ContractFormEvent {
  final Buyer buyer;
  const ContractFormBuyerSelected(this.buyer);
  @override
  List<Object?> get props => [buyer];
}

// Step 4 Events
class ContractFormApplianceAdded extends ContractFormEvent {
  const ContractFormApplianceAdded();
  @override
  List<Object?> get props => [];
}

class ContractFormApplianceRemoved extends ContractFormEvent {
  final String id;
  const ContractFormApplianceRemoved(this.id);
  @override
  List<Object?> get props => [id];
}

class ContractFormApplianceUpdated extends ContractFormEvent {
  final ApplianceItem item;
  const ContractFormApplianceUpdated(this.item);
  @override
  List<Object?> get props => [item];
}

class ContractFormApplianceImagesAdded extends ContractFormEvent {
  final String id;
  final List<String> images;
  const ContractFormApplianceImagesAdded(this.id, this.images);
  @override
  List<Object?> get props => [id, images];
}

class ContractFormApplianceImageRemoved extends ContractFormEvent {
  final String id;
  final String imagePath;
  const ContractFormApplianceImageRemoved(this.id, this.imagePath);
  @override
  List<Object?> get props => [id, imagePath];
}

class ContractFormPropertyDataFetched extends ContractFormEvent {
  final int propertyId;
  const ContractFormPropertyDataFetched(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class ContractFormAppliancePropertyImageSelected extends ContractFormEvent {
  final String applianceId;
  final int propertyImageId;
  final String url;

  const ContractFormAppliancePropertyImageSelected({
    required this.applianceId,
    required this.propertyImageId,
    required this.url,
  });

  @override
  List<Object?> get props => [applianceId, propertyImageId, url];
}

// Step 5 Events
class ContractFormFurnitureAdded extends ContractFormEvent {
  const ContractFormFurnitureAdded();
  @override
  List<Object?> get props => [];
}

class ContractFormFurnitureRemoved extends ContractFormEvent {
  final String id;
  const ContractFormFurnitureRemoved(this.id);
  @override
  List<Object?> get props => [id];
}

class ContractFormFurnitureUpdated extends ContractFormEvent {
  final FurnitureItem item;
  const ContractFormFurnitureUpdated(this.item);
  @override
  List<Object?> get props => [item];
}

class ContractFormFurnitureImagesAdded extends ContractFormEvent {
  final String id;
  final List<String> images;
  const ContractFormFurnitureImagesAdded(this.id, this.images);
  @override
  List<Object?> get props => [id, images];
}

class ContractFormFurnitureImageRemoved extends ContractFormEvent {
  final String id;
  final String imagePath;
  const ContractFormFurnitureImageRemoved(this.id, this.imagePath);
  @override
  List<Object?> get props => [id, imagePath];
}

class ContractFormFurniturePropertyImageSelected extends ContractFormEvent {
  final String furnitureId;
  final int propertyImageId;
  final String url;

  const ContractFormFurniturePropertyImageSelected({
    required this.furnitureId,
    required this.propertyImageId,
    required this.url,
  });

  @override
  List<Object?> get props => [furnitureId, propertyImageId, url];
}

// Step 6 Events
class ContractFormPriceUpdated extends ContractFormEvent {
  final double price;
  const ContractFormPriceUpdated(this.price);
  @override
  List<Object?> get props => [price];
}

class ContractFormCommonFeeUpdated extends ContractFormEvent {
  final double fee;
  const ContractFormCommonFeeUpdated(this.fee);
  @override
  List<Object?> get props => [fee];
}

class ContractFormOtherServiceFeeUpdated extends ContractFormEvent {
  final double fee;
  const ContractFormOtherServiceFeeUpdated(this.fee);
  @override
  List<Object?> get props => [fee];
}

class ContractFormAdvanceRentUpdated extends ContractFormEvent {
  final double rent;
  const ContractFormAdvanceRentUpdated(this.rent);
  @override
  List<Object?> get props => [rent];
}

class ContractFormSecurityDepositUpdated extends ContractFormEvent {
  final double deposit;
  const ContractFormSecurityDepositUpdated(this.deposit);
  @override
  List<Object?> get props => [deposit];
}

class ContractFormDueDateUpdated extends ContractFormEvent {
  final int? dueDate;
  const ContractFormDueDateUpdated(this.dueDate);
  @override
  List<Object?> get props => [dueDate];
}

class ContractFormLateFeeUpdated extends ContractFormEvent {
  final double fee;
  const ContractFormLateFeeUpdated(this.fee);
  @override
  List<Object?> get props => [fee];
}

class ContractFormPaymentMethodUpdated extends ContractFormEvent {
  final String method;
  const ContractFormPaymentMethodUpdated(this.method);
  @override
  List<Object?> get props => [method];
}

class ContractFormBankCodeUpdated extends ContractFormEvent {
  final String? code;
  const ContractFormBankCodeUpdated(this.code);
  @override
  List<Object?> get props => [code];
}

class ContractFormBankBranchUpdated extends ContractFormEvent {
  final String? branch;
  final String? bankCode;
  const ContractFormBankBranchUpdated(this.branch, this.bankCode);
  @override
  List<Object?> get props => [branch, bankCode];
}

class ContractFormAccountNameUpdated extends ContractFormEvent {
  final String name;
  const ContractFormAccountNameUpdated(this.name);
  @override
  List<Object?> get props => [name];
}

class ContractFormAccountNumberUpdated extends ContractFormEvent {
  final String number;
  const ContractFormAccountNumberUpdated(this.number);
  @override
  List<Object?> get props => [number];
}

class ContractFormAdditionalConditionsUpdated extends ContractFormEvent {
  final String conditions;
  const ContractFormAdditionalConditionsUpdated(this.conditions);
  @override
  List<Object?> get props => [conditions];
}

// Step 8: Attachment Events
class ContractFormAttachmentAdded extends ContractFormEvent {
  const ContractFormAttachmentAdded();
}

class ContractFormAttachmentRemoved extends ContractFormEvent {
  final String id;
  const ContractFormAttachmentRemoved(this.id);
  @override
  List<Object?> get props => [id];
}

class ContractFormAttachmentNameUpdated extends ContractFormEvent {
  final String id;
  final String name;
  const ContractFormAttachmentNameUpdated(this.id, this.name);
  @override
  List<Object?> get props => [id, name];
}

class ContractFormAttachmentFileUpdated extends ContractFormEvent {
  final String id;
  final String? filePath;
  final int? fileSize;
  const ContractFormAttachmentFileUpdated({
    required this.id,
    this.filePath,
    this.fileSize,
  });
  @override
  List<Object?> get props => [id, filePath, fileSize];
}

class ContractFormRemoteAttachmentDeleted extends ContractFormEvent {
  final int contractId;
  final int documentId;
  final String attachmentId;

  const ContractFormRemoteAttachmentDeleted({
    required this.contractId,
    required this.documentId,
    required this.attachmentId,
  });

  @override
  List<Object?> get props => [contractId, documentId, attachmentId];
}
