
import 'package:equatable/equatable.dart';
import 'package:youragent/data/models/contract_create_data_model.dart';
import 'package:youragent/data/models/contract_model.dart';
import 'package:youragent/data/models/property_model.dart';
import 'package:youragent/domain/entities/contract_type.dart';

/// Registration status enum
enum RegistrationStatus { initial, loading, success, failure }

/// States for Contract Form BLoC
abstract class ContractFormState extends Equatable {
  const ContractFormState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ContractFormInitial extends ContractFormState {}

/// Form data state - contains all form values
class ContractFormData extends ContractFormState {
  // Mode flags
  final bool isReadOnly;
  final bool isLoading;
  final String? errorMessage;

  // Submission flags
  final bool isSubmitting;
  final bool submitSuccess;
  final String? submitErrorMessage;

  // Original data references
  final ContractModel? originalContract;
  final PropertyModel? sourceProperty;

  // Mode identifiers
  final int? contractIdInt;
  final int? propertyId;
  final int? bookingId;

  // Auxiliary data
  final ContractModel? contract;
  final List<Bank> banks;
  final Map<String, String> accountTypes;
  final List<dynamic> appliances;
  final List<dynamic> furniture;

  // General Info
  final String? contractId;
  final String? contractNumber;
  final ContractType? contractType;
  final DateTime? contractDate;
  final String? signingPlace;

  // Lessor (Owner) Info
  final String? lessorType; // 'person' or 'company'
  final String? lessorName;
  final String? lessorIdCard;
  final String? lessorTaxId;
  final String? lessorLicenseNumber;
  final String? lessorAddress;
  final String? lessorPhone;
  final String? lessorEmail;
  final String? lessorAuthorizedSignatory;

  // Lessee (Buyer) Info
  final String? lesseeType; // 'person' or 'company'
  final String? lesseeName;
  final String? lesseeIdCard;
  final String? lesseeTaxId;
  final String? lesseeAddress;
  final String? lesseePhone;
  final String? lesseeEmail;
  final String? lesseeAuthorizedSignatory;

  // Asset (Property) Info
  final String? propertyType;
  final String? projectName;
  final String? houseNumber;
  final String? floor;
  final String? building;
  final String? soi;
  final String? road;
  final String? country;
  final String? province;
  final String? district;
  final String? subdistrict;
  final String? postalCode;
  final String? bedrooms;
  final String? bathrooms;
  final String? parking;
  final String? landSize;
  final String? usableArea;

  // Contract Duration
  final DateTime? startDate;
  final DateTime? endDate;
  final String? leasePeriod; // Auto-calculated, read-only
  final String? renewalFormat;
  final String? renewalConditions;

  // Payment Terms
  final String? rentalFee;
  final String? commonFee;
  final String? serviceFee;
  final String? totalMonthlyPayment;
  final String? advanceRental;
  final String? damageDeposit;
  final String? totalPayment; // Auto-calculated
  final String? paymentDueDate;
  final String? waterFee;
  final String? lateFee;
  final String? paymentChannel;
  final String? branch;
  final String? accountName;
  final String? accountNumber;

  // Terms
  final String? additionalConditions;
  final String? flexibleTerms;

  // Registration status
  final RegistrationStatus lessorRegistrationStatus;
  final RegistrationStatus lesseeRegistrationStatus;
  final String? registrationErrorMessage;

  const ContractFormData({
    this.isReadOnly = false,
    this.isLoading = false,
    this.errorMessage,
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.submitErrorMessage,
    this.originalContract,
    this.sourceProperty,
    this.contractIdInt,
    this.propertyId,
    this.bookingId,
    this.contract,
    this.banks = const [],
    this.accountTypes = const {},
    this.appliances = const [],
    this.furniture = const [],
    this.contractId,
    this.contractNumber,
    this.contractType,
    this.contractDate,
    this.signingPlace,
    this.lessorType,
    this.lessorName,
    this.lessorIdCard,
    this.lessorTaxId,
    this.lessorLicenseNumber,
    this.lessorAddress,
    this.lessorPhone,
    this.lessorEmail,
    this.lessorAuthorizedSignatory,
    this.lesseeType,
    this.lesseeName,
    this.lesseeIdCard,
    this.lesseeTaxId,
    this.lesseeAddress,
    this.lesseePhone,
    this.lesseeEmail,
    this.lesseeAuthorizedSignatory,
    this.propertyType,
    this.projectName,
    this.houseNumber,
    this.floor,
    this.building,
    this.soi,
    this.road,
    this.country,
    this.province,
    this.district,
    this.subdistrict,
    this.postalCode,
    this.bedrooms,
    this.bathrooms,
    this.parking,
    this.landSize,
    this.usableArea,
    this.startDate,
    this.endDate,
    this.leasePeriod,
    this.renewalFormat,
    this.renewalConditions,
    this.rentalFee,
    this.commonFee,
    this.serviceFee,
    this.totalMonthlyPayment,
    this.advanceRental,
    this.damageDeposit,
    this.totalPayment,
    this.paymentDueDate,
    this.waterFee,
    this.lateFee,
    this.paymentChannel,
    this.branch,
    this.accountName,
    this.accountNumber,
    this.additionalConditions,
    this.flexibleTerms,
    this.lessorRegistrationStatus = RegistrationStatus.initial,
    this.lesseeRegistrationStatus = RegistrationStatus.initial,
    this.registrationErrorMessage,
  });

  ContractFormData copyWith({
    bool? isReadOnly,
    bool? isLoading,
    String? errorMessage,
    bool? isSubmitting,
    bool? submitSuccess,
    String? submitErrorMessage,
    ContractModel? originalContract,
    PropertyModel? sourceProperty,
    int? contractIdInt,
    int? propertyId,
    int? bookingId,
    ContractModel? contract,
    List<Bank>? banks,
    Map<String, String>? accountTypes,
    List<dynamic>? appliances,
    List<dynamic>? furniture,
    String? contractId,
    String? contractNumber,
    ContractType? contractType,
    DateTime? contractDate,
    String? signingPlace,
    String? lessorType,
    String? lessorName,
    String? lessorIdCard,
    String? lessorTaxId,
    String? lessorLicenseNumber,
    String? lessorAddress,
    String? lessorPhone,
    String? lessorEmail,
    String? lessorAuthorizedSignatory,
    String? lesseeType,
    String? lesseeName,
    String? lesseeIdCard,
    String? lesseeTaxId,
    String? lesseeAddress,
    String? lesseePhone,
    String? lesseeEmail,
    String? lesseeAuthorizedSignatory,
    String? propertyType,
    String? projectName,
    String? houseNumber,
    String? floor,
    String? building,
    String? soi,
    String? road,
    String? country,
    String? province,
    String? district,
    String? subdistrict,
    String? postalCode,
    String? bedrooms,
    String? bathrooms,
    String? parking,
    String? landSize,
    String? usableArea,
    DateTime? startDate,
    DateTime? endDate,
    String? leasePeriod,
    String? renewalFormat,
    String? renewalConditions,
    String? rentalFee,
    String? commonFee,
    String? serviceFee,
    String? totalMonthlyPayment,
    String? advanceRental,
    String? damageDeposit,
    String? totalPayment,
    String? paymentDueDate,
    String? waterFee,
    String? lateFee,
    String? paymentChannel,
    String? branch,
    String? accountName,
    String? accountNumber,
    String? additionalConditions,
    String? flexibleTerms,
    RegistrationStatus? lessorRegistrationStatus,
    RegistrationStatus? lesseeRegistrationStatus,
    String? registrationErrorMessage,
  }) {
    return ContractFormData(
      isReadOnly: isReadOnly ?? this.isReadOnly,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      submitErrorMessage: submitErrorMessage ?? this.submitErrorMessage,
      originalContract: originalContract ?? this.originalContract,
      sourceProperty: sourceProperty ?? this.sourceProperty,
      contractIdInt: contractIdInt ?? this.contractIdInt,
      propertyId: propertyId ?? this.propertyId,
      bookingId: bookingId ?? this.bookingId,
      contract: contract ?? this.contract,
      banks: banks ?? this.banks,
      accountTypes: accountTypes ?? this.accountTypes,
      appliances: appliances ?? this.appliances,
      furniture: furniture ?? this.furniture,
      contractId: contractId ?? this.contractId,
      contractNumber: contractNumber ?? this.contractNumber,
      contractType: contractType ?? this.contractType,
      contractDate: contractDate ?? this.contractDate,
      signingPlace: signingPlace ?? this.signingPlace,
      lessorType: lessorType ?? this.lessorType,
      lessorName: lessorName ?? this.lessorName,
      lessorIdCard: lessorIdCard ?? this.lessorIdCard,
      lessorTaxId: lessorTaxId ?? this.lessorTaxId,
      lessorLicenseNumber: lessorLicenseNumber ?? this.lessorLicenseNumber,
      lessorAddress: lessorAddress ?? this.lessorAddress,
      lessorPhone: lessorPhone ?? this.lessorPhone,
      lessorEmail: lessorEmail ?? this.lessorEmail,
      lessorAuthorizedSignatory:
          lessorAuthorizedSignatory ?? this.lessorAuthorizedSignatory,
      lesseeType: lesseeType ?? this.lesseeType,
      lesseeName: lesseeName ?? this.lesseeName,
      lesseeIdCard: lesseeIdCard ?? this.lesseeIdCard,
      lesseeTaxId: lesseeTaxId ?? this.lesseeTaxId,
      lesseeAddress: lesseeAddress ?? this.lesseeAddress,
      lesseePhone: lesseePhone ?? this.lesseePhone,
      lesseeEmail: lesseeEmail ?? this.lesseeEmail,
      lesseeAuthorizedSignatory:
          lesseeAuthorizedSignatory ?? this.lesseeAuthorizedSignatory,
      propertyType: propertyType ?? this.propertyType,
      projectName: projectName ?? this.projectName,
      houseNumber: houseNumber ?? this.houseNumber,
      floor: floor ?? this.floor,
      building: building ?? this.building,
      soi: soi ?? this.soi,
      road: road ?? this.road,
      country: country ?? this.country,
      province: province ?? this.province,
      district: district ?? this.district,
      subdistrict: subdistrict ?? this.subdistrict,
      postalCode: postalCode ?? this.postalCode,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      parking: parking ?? this.parking,
      landSize: landSize ?? this.landSize,
      usableArea: usableArea ?? this.usableArea,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      leasePeriod: leasePeriod ?? this.leasePeriod,
      renewalFormat: renewalFormat ?? this.renewalFormat,
      renewalConditions: renewalConditions ?? this.renewalConditions,
      rentalFee: rentalFee ?? this.rentalFee,
      commonFee: commonFee ?? this.commonFee,
      serviceFee: serviceFee ?? this.serviceFee,
      totalMonthlyPayment: totalMonthlyPayment ?? this.totalMonthlyPayment,
      advanceRental: advanceRental ?? this.advanceRental,
      damageDeposit: damageDeposit ?? this.damageDeposit,
      totalPayment: totalPayment ?? this.totalPayment,
      paymentDueDate: paymentDueDate ?? this.paymentDueDate,
      waterFee: waterFee ?? this.waterFee,
      lateFee: lateFee ?? this.lateFee,
      paymentChannel: paymentChannel ?? this.paymentChannel,
      branch: branch ?? this.branch,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      additionalConditions: additionalConditions ?? this.additionalConditions,
      flexibleTerms: flexibleTerms ?? this.flexibleTerms,
      lessorRegistrationStatus:
          lessorRegistrationStatus ?? this.lessorRegistrationStatus,
      lesseeRegistrationStatus:
          lesseeRegistrationStatus ?? this.lesseeRegistrationStatus,
      registrationErrorMessage:
          registrationErrorMessage ?? this.registrationErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isReadOnly,
    isLoading,
    errorMessage,
    isSubmitting,
    submitSuccess,
    submitErrorMessage,
    originalContract,
    sourceProperty,
    contractIdInt,
    propertyId,
    bookingId,
    contract,
    banks,
    accountTypes,
    appliances,
    furniture,
    contractId,
    contractNumber,
    contractType,
    contractDate,
    signingPlace,
    lessorType,
    lessorName,
    lessorIdCard,
    lessorTaxId,
    lessorLicenseNumber,
    lessorAddress,
    lessorPhone,
    lessorEmail,
    lessorAuthorizedSignatory,
    lesseeType,
    lesseeName,
    lesseeIdCard,
    lesseeTaxId,
    lesseeAddress,
    lesseePhone,
    lesseeEmail,
    lesseeAuthorizedSignatory,
    propertyType,
    projectName,
    houseNumber,
    floor,
    building,
    soi,
    road,
    country,
    province,
    district,
    subdistrict,
    postalCode,
    bedrooms,
    bathrooms,
    parking,
    landSize,
    usableArea,
    startDate,
    endDate,
    leasePeriod,
    renewalFormat,
    renewalConditions,
    rentalFee,
    commonFee,
    serviceFee,
    totalMonthlyPayment,
    advanceRental,
    damageDeposit,
    totalPayment,
    paymentDueDate,
    waterFee,
    lateFee,
    paymentChannel,
    branch,
    accountName,
    accountNumber,
    additionalConditions,
    flexibleTerms,
    lessorRegistrationStatus,
    lesseeRegistrationStatus,
    registrationErrorMessage,
  ];
}
