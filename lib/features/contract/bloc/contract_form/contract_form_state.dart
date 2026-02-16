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
import 'package:youragent/domain/entities/contract_status.dart';
import 'package:youragent/domain/entities/contract_item_definition.dart';
import 'package:youragent/domain/entities/contract.dart'; // Added import for Contract

enum ContractFormStatus {
  initial,
  loading,
  success,
  failure,
  submitting,
  draftSaveSuccess,
  draftSaveFailure,
}

class ContractFormState extends Equatable {
  final int step;
  final ContractFormStatus status;
  final String? errorMessage;
  final bool isValid;
  final ContractStatus? contractStatus;

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
  final String signingPlace; // Added
  final String propertyUnitNo; // Added
  final String propertyFloor; // Added
  final String propertyBuilding; // Added
  final String propertyProjectName; // Added
  final String propertyAreaSqm; // Added

  // Step 2 Data
  final PersonType ownerType;
  final String ownerName;
  final String ownerIdCard;
  final String ownerAddress;
  final String ownerPhone;
  final String ownerEmail;
  final String ownerPassword; // Added
  final String ownerSignatory;
  final List<Owner> owners;
  final List<Owner> allOwners; // Full list from API
  final Owner? selectedOwner;

  // Step 3 Data
  final PersonType buyerType;
  final String buyerName;
  final String buyerIdCard;
  final String buyerAddress;
  final String buyerPhone;
  final String buyerEmail;
  final String buyerPassword; // Added
  final List<Buyer> buyers;
  final List<Buyer> allBuyers; // Full list from API
  final Buyer? selectedBuyer;

  // Step 4
  final List<ApplianceItem> applianceItems;

  // Step 5
  final List<FurnitureItem> furnitureItems;

  final ContractCreateData? contractCreateData;
  final ContractItemDefinitions? itemDefinitions;

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
  final double upfrontFee;
  final String? bankCode;
  final String bankName;
  final String bankBranch;
  final String accountName;
  final String accountNumber;

  // Step 8: Attachments
  final List<ContractAttachment> attachments;

  final Map<String, dynamic>? initialData;

  /// Smart resume logic to calculate the starting step for a draft contract
  static int calculateResumeStep(Contract contract) {
    // Step 1: Basic Info
    final baseValid =
        contract.contractType != null &&
        contract.property != null &&
        contract.contractDate != null;

    if (contract.contractType == ContractType.rent) {
      final rentValid =
          baseValid && contract.startDate != null && contract.endDate != null;
      if (!rentValid) return 1;
    } else {
      if (!baseValid) return 1;
    }

    // Step 2: Property Owner
    final owner = contract.owner;
    final ownerValid =
        owner != null &&
        owner.name.isNotEmpty &&
        (owner.idCard?.isNotEmpty ?? false) &&
        (owner.address?.isNotEmpty ?? false) &&
        (owner.phone?.isNotEmpty ?? false) &&
        (owner.email?.isNotEmpty ?? false);
    if (!ownerValid) return 2;

    // Step 3: Buyer Info
    final buyer = contract.buyer;
    final buyerValid =
        buyer != null &&
        buyer.name.isNotEmpty &&
        (buyer.idCard?.isNotEmpty ?? false) &&
        (buyer.address?.isNotEmpty ?? false) &&
        (buyer.phone?.isNotEmpty ?? false) &&
        (buyer.email?.isNotEmpty ?? false);
    if (!buyerValid) return 3;

    // Step 4: Appliances (Always valid to skip)
    // Step 5: Furniture (Always valid to skip)

    // Step 6: Payment Details
    double parseDouble(String? val) {
      if (val == null) return 0.0;
      return double.tryParse(val.replaceAll(',', '')) ?? 0.0;
    }

    final price = parseDouble(contract.monthlyRentalCost);
    final bank = contract.bankAccounts.isNotEmpty
        ? contract.bankAccounts.first
        : null;
    final bankValid =
        bank != null &&
        bank.bankName.isNotEmpty &&
        bank.accountHolderName.isNotEmpty &&
        bank.accountNumber.isNotEmpty;

    final paymentMethodValid = (contract.paymentMethod?.isNotEmpty ?? false);

    if (contract.contractType == ContractType.rent) {
      final rentPaymentValid =
          price > 0 &&
          parseDouble(contract.commonFee) > 0 &&
          parseDouble(contract.advanceRent) > 0 &&
          parseDouble(contract.securityDeposit) > 0 &&
          contract.rentalPaymentDate != null &&
          paymentMethodValid &&
          bankValid;

      if (!rentPaymentValid) return 6;
    } else {
      // Buy Type
      final buyPaymentValid =
          price > 0 &&
          paymentMethodValid &&
          (contract.paymentMethod == 'Cash' || bankValid);

      if (!buyPaymentValid) return 6;
    }

    // Steps 7-8 are additional/optional, resume at step 7 if all above are valid
    return 7;
  }

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
    this.allOwners = const [],
    this.selectedOwner,
    this.buyerType = PersonType.individual,
    this.buyerName = '',
    this.buyerIdCard = '',
    this.buyerAddress = '',
    this.buyerPhone = '',
    this.buyerEmail = '',
    this.buyers = const [],
    this.allBuyers = const [],
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
    this.bankName = '',
    this.bankBranch = '',
    this.accountName = '',
    this.accountNumber = '',
    this.attachments = const [],
    this.initialData,
    this.contractStatus,
    this.ownerPassword = '',
    this.buyerPassword = '',
    this.signingPlace = '',
    this.propertyUnitNo = '',
    this.propertyFloor = '',
    this.propertyBuilding = '',
    this.propertyProjectName = '',
    this.propertyAreaSqm = '',
    this.upfrontFee = 0,
    this.itemDefinitions,
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
    List<Buyer>? buyers,
    List<Buyer>? allBuyers,
    Buyer? selectedBuyer,
    List<Owner>? owners,
    List<Owner>? allOwners,
    Owner? selectedOwner,
    PersonType? buyerType,
    String? buyerName,
    String? buyerIdCard,
    String? buyerAddress,
    String? buyerPhone,
    String? buyerEmail,
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
    double? totalUpfrontPayment,
    double? advanceRent,
    double? securityDeposit,
    int? dueDate,
    double? lateFee,
    String? paymentMethod,
    String? bankCode,
    String? bankName,
    String? bankBranch,
    String? accountName,
    String? accountNumber,
    List<ContractAttachment>? attachments,
    Map<String, dynamic>? initialData,
    ContractStatus? contractStatus,
    String? ownerPassword,
    String? buyerPassword,
    String? signingPlace,
    String? propertyUnitNo,
    String? propertyFloor,
    String? propertyBuilding,
    String? propertyProjectName,
    String? propertyAreaSqm,
    double? upfrontFee,
    ContractItemDefinitions? itemDefinitions,
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
      ownerPassword: ownerPassword ?? this.ownerPassword,
      ownerSignatory: ownerSignatory ?? this.ownerSignatory,
      owners: owners ?? this.owners,
      allOwners: allOwners ?? this.allOwners,
      selectedOwner: selectedOwner ?? this.selectedOwner,
      buyerType: buyerType ?? this.buyerType,
      buyerName: buyerName ?? this.buyerName,
      buyerIdCard: buyerIdCard ?? this.buyerIdCard,
      buyerAddress: buyerAddress ?? this.buyerAddress,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      buyerPassword: buyerPassword ?? this.buyerPassword,
      buyers: buyers ?? this.buyers,
      allBuyers: allBuyers ?? this.allBuyers,
      selectedBuyer: selectedBuyer ?? this.selectedBuyer,
      applianceItems: applianceItems ?? this.applianceItems,
      furnitureItems: furnitureItems ?? this.furnitureItems,
      contractCreateData: contractCreateData ?? this.contractCreateData,
      leaseFormat: leaseFormat ?? this.leaseFormat,
      leaseStartDate: leaseStartDate ?? this.leaseStartDate,
      leaseEndDate: leaseEndDate ?? this.leaseEndDate,
      leaseDuration: leaseDuration ?? this.leaseDuration,
      additionalConditions: additionalConditions ?? this.additionalConditions,
      signingPlace: signingPlace ?? this.signingPlace,
      propertyUnitNo: propertyUnitNo ?? this.propertyUnitNo,
      propertyFloor: propertyFloor ?? this.propertyFloor,
      propertyBuilding: propertyBuilding ?? this.propertyBuilding,
      propertyProjectName: propertyProjectName ?? this.propertyProjectName,
      propertyAreaSqm: propertyAreaSqm ?? this.propertyAreaSqm,
      upfrontFee: upfrontFee ?? this.upfrontFee,
      price: price ?? this.price,
      commonFee: commonFee ?? this.commonFee,
      otherServiceFee: otherServiceFee ?? this.otherServiceFee,
      totalMonthlyPayment: totalMonthlyPayment ?? this.totalMonthlyPayment,
      totalUpfrontPayment: totalUpfrontPayment ?? this.totalUpfrontPayment,
      advanceRent: advanceRent ?? this.advanceRent,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      dueDate: dueDate ?? this.dueDate,
      lateFee: lateFee ?? this.lateFee,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      bankCode: clearBankCode ? null : (bankCode ?? this.bankCode),
      bankName: bankName ?? this.bankName,
      bankBranch: bankBranch ?? this.bankBranch,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      attachments: attachments ?? this.attachments,
      initialData: initialData ?? this.initialData,
      contractStatus: contractStatus ?? this.contractStatus,
      itemDefinitions: itemDefinitions ?? this.itemDefinitions,
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
    allOwners,
    selectedOwner,
    buyerType,
    buyerName,
    buyerIdCard,
    buyerAddress,
    buyerPhone,
    buyerEmail,
    buyers,
    allBuyers,
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
    totalUpfrontPayment,
    advanceRent,
    securityDeposit,
    dueDate,
    lateFee,
    paymentMethod,
    bankCode,
    bankName,
    bankBranch,
    accountName,
    accountNumber,
    attachments,
    initialData,
    contractStatus,
    ownerPassword,
    buyerPassword,
    signingPlace,
    propertyUnitNo,
    propertyFloor,
    propertyBuilding,
    propertyProjectName,
    propertyAreaSqm,
    upfrontFee,
    itemDefinitions,
  ];
}
