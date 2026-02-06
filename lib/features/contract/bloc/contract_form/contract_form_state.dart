import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/contract_type.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/domain/entities/person_type.dart';
import 'package:youragent/domain/entities/owner.dart';
import 'package:youragent/domain/entities/buyer.dart';
import 'package:youragent/domain/entities/appliance_item.dart';
import 'package:youragent/domain/entities/furniture_item.dart';
import 'package:youragent/domain/entities/contract_create_data.dart';
import 'package:youragent/domain/entities/contract_attachment.dart';

enum ContractFormStatus { initial, loading, success, failure, submmitting }

class ContractFormState extends Equatable {
  final int step;
  final ContractFormStatus status;
  final String? errorMessage;
  final bool isValid;

  // Step 1 Data
  final int? contractId;
  final String propertyName;
  final DateTime? contractDate;
  final ContractType? contractType;
  final List<Property> properties;
  final Property? selectedProperty;
  final String leaseFormat;
  final DateTime? leaseStartDate;
  final DateTime? leaseEndDate;
  final int leaseDuration;
  final String additionalConditions;

  // Step 2 Data
  final PersonType ownerType;
  final String ownerName;
  final String ownerIdCard;
  final String ownerAddress;
  final String ownerPhone;
  final String ownerEmail;
  final String ownerSignatory;
  final List<Owner> owners;
  final Owner? selectedOwner;

  // Step 3 Data
  final PersonType buyerType;
  final String buyerName;
  final String buyerIdCard;
  final String buyerAddress;
  final String buyerPhone;
  final String buyerEmail;
  final List<Buyer> buyers;
  final Buyer? selectedBuyer;

  // Step 4
  final List<ApplianceItem> applianceItems;

  // Step 5
  final List<FurnitureItem> furnitureItems;

  final ContractCreateData? contractCreateData;

  // Step 6: Payment Details
  final double price;
  final double commonFee;
  final double otherServiceFee;
  final double totalMonthlyPayment;
  final double advanceRent;
  final double securityDeposit;
  final double totalUpfrontPayment;
  final int? dueDate;
  final double lateFee;
  final String paymentMethod;
  final String? bankCode;
  final String bankBranch;
  final String accountName;
  final String accountNumber;

  // Step 8: Attachments
  final List<ContractAttachment> attachments;

  const ContractFormState({
    this.step = 1,
    this.contractId,
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
    this.buyerType = PersonType.individual,
    this.buyerName = '',
    this.buyerIdCard = '',
    this.buyerAddress = '',
    this.buyerPhone = '',
    this.buyerEmail = '',
    this.buyers = const [],
    this.selectedBuyer,
    this.applianceItems = const [],
    this.furnitureItems = const [],
    this.contractCreateData,
    this.leaseFormat = '',
    this.leaseStartDate,
    this.leaseEndDate,
    this.leaseDuration = 0,
    this.additionalConditions = '',
    this.price = 0,
    this.commonFee = 0,
    this.otherServiceFee = 0,
    this.totalMonthlyPayment = 0,
    this.advanceRent = 0,
    this.securityDeposit = 0,
    this.totalUpfrontPayment = 0,
    this.dueDate,
    this.lateFee = 0,
    this.paymentMethod = '',
    this.bankCode,
    this.bankBranch = '',
    this.accountName = '',
    this.accountNumber = '',
    this.attachments = const [],
  });

  ContractFormState copyWith({
    int? step,
    int? contractId,
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
    List<Owner>? owners,
    Owner? selectedOwner,
    PersonType? buyerType,
    String? buyerName,
    String? buyerIdCard,
    String? buyerAddress,
    String? buyerPhone,
    String? buyerEmail,
    List<Buyer>? buyers,
    Buyer? selectedBuyer,
    List<ApplianceItem>? applianceItems,
    List<FurnitureItem>? furnitureItems,
    ContractCreateData? contractCreateData,
    String? leaseFormat,
    DateTime? leaseStartDate,
    DateTime? leaseEndDate,
    int? leaseDuration,
    String? additionalConditions,
    double? price,
    double? commonFee,
    double? otherServiceFee,
    double? totalMonthlyPayment,
    double? advanceRent,
    double? securityDeposit,
    double? totalUpfrontPayment,
    int? dueDate,
    double? lateFee,
    String? paymentMethod,
    String? bankCode,
    String? bankBranch,
    String? accountName,
    String? accountNumber,
    List<ContractAttachment>? attachments,
    bool clearBankCode = false,
  }) {
    return ContractFormState(
      step: step ?? this.step,
      contractId: contractId ?? this.contractId,
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
      buyerType: buyerType ?? this.buyerType,
      buyerName: buyerName ?? this.buyerName,
      buyerIdCard: buyerIdCard ?? this.buyerIdCard,
      buyerAddress: buyerAddress ?? this.buyerAddress,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      buyers: buyers ?? this.buyers,
      selectedBuyer: selectedBuyer ?? this.selectedBuyer,
      applianceItems: applianceItems ?? this.applianceItems,
      furnitureItems: furnitureItems ?? this.furnitureItems,
      contractCreateData: contractCreateData ?? this.contractCreateData,
      leaseFormat: leaseFormat ?? this.leaseFormat,
      leaseStartDate: leaseStartDate ?? this.leaseStartDate,
      leaseEndDate: leaseEndDate ?? this.leaseEndDate,
      leaseDuration: leaseDuration ?? this.leaseDuration,
      additionalConditions: additionalConditions ?? this.additionalConditions,
      price: price ?? this.price,
      commonFee: commonFee ?? this.commonFee,
      otherServiceFee: otherServiceFee ?? this.otherServiceFee,
      totalMonthlyPayment: totalMonthlyPayment ?? this.totalMonthlyPayment,
      advanceRent: advanceRent ?? this.advanceRent,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      totalUpfrontPayment: totalUpfrontPayment ?? this.totalUpfrontPayment,
      dueDate: dueDate ?? this.dueDate,
      lateFee: lateFee ?? this.lateFee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bankCode: clearBankCode ? null : (bankCode ?? this.bankCode),
      bankBranch: bankBranch ?? this.bankBranch,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  List<Object?> get props => [
    step,
    contractId,
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
    buyerType,
    buyerName,
    buyerIdCard,
    buyerAddress,
    buyerPhone,
    buyerEmail,
    buyers,
    selectedBuyer,
    applianceItems,
    furnitureItems,
    contractCreateData,
    leaseFormat,
    leaseStartDate,
    leaseEndDate,
    leaseDuration,
    additionalConditions,
    price,
    commonFee,
    otherServiceFee,
    totalMonthlyPayment,
    advanceRent,
    securityDeposit,
    totalUpfrontPayment,
    dueDate,
    lateFee,
    paymentMethod,
    bankCode,
    bankBranch,
    accountName,
    accountNumber,
    attachments,
  ];
}
