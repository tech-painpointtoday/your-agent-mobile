import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/data/models/contract_create_data_model.dart';
import 'package:youragent/domain/entities/contract_type.dart';
import 'package:youragent/services/contract_api_service.dart';
import 'package:youragent/services/client_service.dart';
import 'contract_form_event.dart';
import 'contract_form_state.dart';

/// BLoC for handling contract form state management
class ContractFormBloc extends Bloc<ContractFormEvent, ContractFormState> {
  final ClientService _clientService = ClientService();
  final ContractApiService _contractApiService =
      DependencyInjection.contractApiService;

  ContractFormBloc() : super(ContractFormInitial()) {
    on<ContractFormInitialized>(_onInitialized);
    on<ContractFormInitializeCreate>(_onInitializeCreate);
    on<ContractFormInitializeEdit>(_onInitializeEdit);
    on<ContractFormInitializeDetail>(_onInitializeDetail);
    on<ContractFormFieldUpdated>(_onFieldUpdated);
    on<ContractFormTypeChanged>(_onTypeChanged);
    on<ContractFormLessorTypeChanged>(_onLessorTypeChanged);
    on<ContractFormLesseeTypeChanged>(_onLesseeTypeChanged);
    on<ContractFormPropertyTypeChanged>(_onPropertyTypeChanged);
    on<ContractFormCountryChanged>(_onCountryChanged);
    on<ContractFormProvinceChanged>(_onProvinceChanged);
    on<ContractFormDistrictChanged>(_onDistrictChanged);
    on<ContractFormSubdistrictChanged>(_onSubdistrictChanged);
    on<ContractFormContractDateChanged>(_onContractDateChanged);
    on<ContractFormStartDateChanged>(_onStartDateChanged);
    on<ContractFormEndDateChanged>(_onEndDateChanged);
    on<ContractFormRenewalFormatChanged>(_onRenewalFormatChanged);
    on<ContractFormPaymentChannelChanged>(_onPaymentChannelChanged);
    on<ContractFormSubmitted>(_onSubmitted);
    on<ContractFormRegisterClient>(_onRegisterClient);
    on<ContractFormClearRegistration>(_onClearRegistration);
  }

  Future<void> _onInitializeCreate(
    ContractFormInitializeCreate event,
    Emitter<ContractFormState> emit,
  ) async {
    final baseState = ContractFormData(
      isReadOnly: false,
      isLoading: true,
      propertyId: event.propertyId,
      bookingId: event.bookingId,
      errorMessage: null,
      submitSuccess: false,
      submitErrorMessage: null,
    );
    emit(baseState);

    try {
      ContractCreateData createData;
      if (event.bookingId != null) {
        createData = await _contractApiService.getCreateDataFromBooking(
          bookingId: event.bookingId!,
        );
      } else if (event.propertyId != null) {
        createData = await _contractApiService.getCreateDataFromProperty(
          propertyId: event.propertyId!,
        );
      } else {
        throw Exception('Missing propertyId or bookingId');
      }

      var nextState = baseState.copyWith(
        isLoading: false,
        sourceProperty: createData.property,
        banks: createData.banks,
        accountTypes: createData.accountTypes,
        country: 'ไทย',
      );

      // Map property into form fields
      if (createData.property != null) {
        nextState = _mapPropertyToState(nextState, createData.property);
      }

      // Map owner (prefill lessor)
      if (createData.owner != null) {
        nextState = _mapOwnerToState(
          nextState,
          owner: createData.owner!,
          ownerType: createData.ownerType,
        );
      }

      // Set default contract type (from API) if present
      if (createData.contractType != null) {
        nextState = nextState.copyWith(
          contractType: ContractType.fromApiValue(createData.contractType),
        );
      } else {
        nextState = nextState.copyWith(contractType: ContractType.rent);
      }

      // Default contract date
      nextState = nextState.copyWith(contractDate: DateTime.now());

      emit(nextState);
    } catch (e) {
      emit(
        baseState.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onInitializeEdit(
    ContractFormInitializeEdit event,
    Emitter<ContractFormState> emit,
  ) async {
    final baseState = ContractFormData(
      isReadOnly: false,
      isLoading: true,
      contractIdInt: event.contractId,
      errorMessage: null,
      submitSuccess: false,
      submitErrorMessage: null,
    );
    emit(baseState);

    try {
      final editData = await _contractApiService.getEditData(
        contractId: event.contractId,
      );

      var nextState = baseState.copyWith(
        isLoading: false,
        contract: editData.contract,
        originalContract: editData.contract,
        banks: editData.banks,
        accountTypes: editData.accountTypes,
      );

      // Map contract json into form fields
      nextState = _mapContractToState(
        nextState,
        editData.contract,
        editData.contractJson,
      );

      emit(nextState);
    } catch (e) {
      emit(
        baseState.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onInitializeDetail(
    ContractFormInitializeDetail event,
    Emitter<ContractFormState> emit,
  ) async {
    final baseState = ContractFormData(
      isReadOnly: true,
      isLoading: true,
      contractIdInt: event.contractId,
      errorMessage: null,
    );
    emit(baseState);

    try {
      // Use /edit payload for view mode as well (full mapping + banks/accountTypes)
      final editData = await _contractApiService.getEditData(
        contractId: event.contractId,
      );

      var nextState = baseState.copyWith(
        isLoading: false,
        contract: editData.contract,
        originalContract: editData.contract,
        banks: editData.banks,
        accountTypes: editData.accountTypes,
      );

      nextState = _mapContractToState(
        nextState,
        editData.contract,
        editData.contractJson,
      );

      emit(nextState);
    } catch (e) {
      emit(
        baseState.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onInitialized(
    ContractFormInitialized event,
    Emitter<ContractFormState> emit,
  ) async {
    ContractFormData initialState = ContractFormData(
      isReadOnly: event.isReadOnly,
      isLoading: false,
      originalContract: event.contract,
      sourceProperty: event.property,
    );

    // Edit/View Mode: Load from contract
    if (event.contract != null || event.contractJson != null) {
      initialState = _mapContractToState(
        initialState,
        event.contract,
        event.contractJson,
      );
    }
    // Create Mode: Load from property if available
    else if (event.property != null) {
      initialState = _mapPropertyToState(initialState, event.property);
    }

    // Set defaults for create mode
    if (event.contract == null && event.contractJson == null) {
      initialState = initialState.copyWith(
        country: 'ไทย',
        contractType: ContractType.rent,
        contractDate: DateTime.now(),
      );
    }

    emit(initialState);
  }

  ContractFormData _mapOwnerToState(
    ContractFormData state, {
    required PropertyOwner owner,
    required String? ownerType,
  }) {
    final inferredType = ownerType?.toLowerCase();
    final lessorType = inferredType == 'company'
        ? 'company'
        : inferredType == 'person'
        ? 'person'
        : null;

    return state.copyWith(
      lessorType: lessorType,
      lessorName: owner.name,
      lessorEmail: owner.email,
      lessorPhone: owner.mobileNumber,
      lessorLicenseNumber: owner.licenseNumber,
    );
  }

  ContractFormData _mapContractToState(
    ContractFormData state,
    eventContract,
    Map<String, dynamic>? contractJson,
  ) {
    // Handle nested API response structure: data.contract or direct contract object
    Map<String, dynamic> json = contractJson ?? {};
    Map<String, dynamic>? dataLevel;

    if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
      dataLevel = json['data'] as Map<String, dynamic>;
      // Extract contract object from data
      if (dataLevel.containsKey('contract') &&
          dataLevel['contract'] is Map<String, dynamic>) {
        json = dataLevel['contract'] as Map<String, dynamic>;
      }
    }

    final property = json['property'] ?? {};
    final specs = property['specs'] ?? {};
    final location = property['location'] ?? {};
    final buyer = json['buyer'] ?? {};
    final owner = json['owner'] ?? {};
    final bankAccounts = json['bank_accounts'] as List<dynamic>? ?? [];
    final appliances = json['appliances'] as List<dynamic>? ?? [];
    final furniture = json['furniture'] as List<dynamic>? ?? [];

    // General Info
    String? contractId;
    String? contractNumber;
    ContractType? contractType;
    DateTime? contractDate;

    if (eventContract != null) {
      contractId = eventContract.id;
      contractNumber = eventContract.contractNumber;
      contractType = eventContract.contractType;
      contractDate = eventContract.createdAt;
    } else if (json.isNotEmpty) {
      contractId = json['id']?.toString();
      if (contractId != null) {
        final idInt = int.tryParse(contractId);
        if (idInt != null) {
          contractNumber = idInt.toString().padLeft(11, '0');
        }
      }
      contractType = ContractType.fromApiValue(
        json['contract_type']?.toString(),
      );
      if (json['created_at'] != null) {
        try {
          contractDate = DateTime.parse(json['created_at']);
        } catch (e) {
          debugPrint('Error parsing created_at: $e');
        }
      }
    }

    // Lessor (Owner) Info
    String? lessorType;
    String? lessorName = owner['name']?.toString();
    String? lessorIdCard =
        owner['id_card']?.toString() ?? owner['national_id']?.toString();
    String? lessorTaxId = owner['tax_id']?.toString();
    String? lessorLicenseNumber = owner['license_number']?.toString();
    String? lessorAddress = owner['address']?.toString();
    String? lessorPhone =
        owner['mobile_number']?.toString() ?? owner['phone']?.toString();
    String? lessorEmail = owner['email']?.toString();
    String? lessorAuthorizedSignatory = owner['authorized_signatory']
        ?.toString();

    // Determine lessor type
    if (lessorIdCard != null) {
      lessorType = 'person';
    } else if (lessorTaxId != null || owner['company_name'] != null) {
      lessorType = 'company';
    }

    // Lessee (Buyer) Info
    String? lesseeType;
    String? lesseeName = buyer['name']?.toString();
    String? lesseeIdCard =
        buyer['id_card']?.toString() ?? buyer['national_id']?.toString();
    String? lesseeTaxId = buyer['tax_id']?.toString();
    String? lesseeAddress = buyer['address']?.toString();
    String? lesseePhone =
        buyer['mobile_number']?.toString() ?? buyer['phone']?.toString();
    String? lesseeEmail = buyer['email']?.toString();
    String? lesseeAuthorizedSignatory = buyer['authorized_signatory']
        ?.toString();

    // Determine lessee type
    if (lesseeIdCard != null) {
      lesseeType = 'person';
    } else if (lesseeTaxId != null || buyer['company_name'] != null) {
      lesseeType = 'company';
    }

    // Asset (Property) Info
    String? propertyType = specs['type']?.toString();
    // Property project name: from contract JSON first, then property specs
    String? projectName =
        json['property_project_name']?.toString() ??
        property['property_project_name']?.toString() ??
        specs['name']?.toString();
    // House number: from contract JSON first, then location
    String? houseNumber = json['property_unit_no']?.toString();
    if (houseNumber == null || houseNumber.isEmpty) {
      if (location['number'] != null) {
        if (location['number'] is Map<String, dynamic>) {
          final numberObj = location['number'] as Map<String, dynamic>;
          houseNumber =
              numberObj['original']?.toString() ??
              numberObj['number']?.toString() ??
              numberObj.toString();
        } else {
          houseNumber = location['number']?.toString();
        }
      }
      houseNumber ??= location['computed_house_number']?.toString();
    }
    // Floor: from contract JSON first, then location
    String? floor =
        json['property_floor']?.toString() ?? location['floor']?.toString();
    String? soi = location['soi']?.toString();
    String? road = location['road']?.toString();
    // Normalize country value: convert "ประเทศไทย" or "Thailand" to "ไทย"
    String? countryRaw = location['country']?.toString();
    String? country = 'ไทย'; // Default
    if (countryRaw != null) {
      final normalized = countryRaw.trim();
      if (normalized == 'ประเทศไทย' ||
          normalized == 'Thailand' ||
          normalized == 'ไทย') {
        country = 'ไทย';
      } else {
        country = normalized;
      }
    }
    String? province = location['state']?.toString();
    String? district = location['city']?.toString();
    String? subdistrict =
        location['subdistrict']?.toString() ?? location['district']?.toString();
    String? postalCode = location['postal_code']?.toString();
    String? bedrooms = specs['bedrooms']?.toString();
    String? bathrooms = specs['bathrooms']?.toString();
    String? parking = specs['garage']?.toString();
    String? landSize = specs['land_size']?.toString();
    // Usable area: from contract JSON first, then specs
    String? usableArea =
        json['property_area_sqm']?.toString() ??
        specs['building_size']?.toString();

    // Contract Duration
    DateTime? startDate;
    DateTime? endDate;
    String? renewalFormat = json['renewal_format']?.toString();
    String? renewalConditions = json['renewal_conditions']?.toString();

    if (json['start_date'] != null) {
      try {
        startDate = DateTime.parse(json['start_date']);
      } catch (e) {
        debugPrint('Error parsing start_date: $e');
      }
    }
    if (json['end_date'] != null) {
      try {
        endDate = DateTime.parse(json['end_date']);
      } catch (e) {
        debugPrint('Error parsing end_date: $e');
      }
    }

    // Calculate lease period
    String? leasePeriod;
    if (startDate != null && endDate != null) {
      final difference = endDate.difference(startDate);
      final months = (difference.inDays / 30).round();
      leasePeriod = '$months เดือน';
    }

    // Payment Terms - Format with commas
    String? rentalFee;
    String? commonFee;
    String? serviceFee;
    String? advanceRental;
    String? damageDeposit;
    String? waterFee;
    String? lateFee;
    String? totalMonthlyPayment;

    if (json['monthly_rental_cost'] != null) {
      rentalFee = _formatCurrency(json['monthly_rental_cost'].toString());
    }
    if (json['common_fee'] != null) {
      commonFee = _formatCurrency(json['common_fee'].toString());
    }
    if (json['service_fee'] != null) {
      serviceFee = _formatCurrency(json['service_fee'].toString());
    }
    if (json['upfront_fee'] != null) {
      advanceRental = _formatCurrency(json['upfront_fee'].toString());
    }
    final securityDepositRaw =
        json['security_deposit'] ?? json['damage_deposit'];
    if (securityDepositRaw != null) {
      damageDeposit = _formatCurrency(securityDepositRaw.toString());
    }
    if (json['water_fee'] != null) {
      waterFee = json['water_fee'].toString();
    }
    if (json['late_fee'] != null) {
      lateFee = _formatCurrency(json['late_fee'].toString());
    }

    // Calculate totals
    String? totalPayment;
    final monthlyRent = _parseCurrency(rentalFee ?? '');
    final monthlyCommon = _parseCurrency(commonFee ?? '');
    final monthlyService = _parseCurrency(serviceFee ?? '');
    final monthlyTotal =
        (monthlyRent ?? 0) + (monthlyCommon ?? 0) + (monthlyService ?? 0);
    if (monthlyTotal > 0) {
      totalMonthlyPayment = _formatCurrency(monthlyTotal.toString());
    }

    final advance = _parseCurrency(advanceRental ?? '');
    final deposit = _parseCurrency(damageDeposit ?? '');
    if (advance != null || deposit != null) {
      final total = (advance ?? 0) + (deposit ?? 0);
      if (total > 0) {
        totalPayment = _formatCurrency(total.toString());
      }
    }

    String? paymentDueDate = json['rental_payment_date']?.toString();
    String? paymentChannel;
    String? branch;
    String? accountName;
    String? accountNumber;

    // Bank info - from bank_accounts array
    if (bankAccounts.isNotEmpty) {
      final bankAccount = bankAccounts
          .whereType<Map<String, dynamic>>()
          .firstWhere(
            (account) =>
                account['bank_name'] != null ||
                account['account_number'] != null,
            orElse: () => <String, dynamic>{},
          );
      if (bankAccount.isNotEmpty) {
        paymentChannel = bankAccount['bank_name']?.toString();
        branch = bankAccount['branch']?.toString();
        // Handle both account_name and account_holder_name
        accountName =
            bankAccount['account_name']?.toString() ??
            bankAccount['account_holder_name']?.toString();
        accountNumber = bankAccount['account_number']?.toString();
      }
    }

    // Extract banks and account_types from data level if available
    List<Bank> banks = state.banks;
    Map<String, String> accountTypes = state.accountTypes;
    if (dataLevel != null) {
      if (dataLevel.containsKey('banks') && dataLevel['banks'] is List) {
        final banksList = dataLevel['banks'] as List;
        banks = banksList
            .whereType<Map<String, dynamic>>()
            .map(
              (bankJson) => Bank(
                code: bankJson['code']?.toString() ?? '',
                name: bankJson['name']?.toString() ?? '',
              ),
            )
            .toList();
      }
      if (dataLevel.containsKey('account_types') &&
          dataLevel['account_types'] is Map) {
        accountTypes = Map<String, String>.from(
          (dataLevel['account_types'] as Map).map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ),
        );
      }
    }

    // Terms
    String? additionalConditions = json['common_terms']?.toString();
    String? flexibleTerms = json['flexible_terms']?.toString();

    return state.copyWith(
      contractId: contractId,
      contractNumber: contractNumber,
      contractType: contractType,
      contractDate: contractDate,
      signingPlace: json['signing_place']?.toString(),
      appliances: appliances,
      furniture: furniture,
      lessorType: lessorType,
      lessorName: lessorName,
      lessorIdCard: lessorIdCard,
      lessorTaxId: lessorTaxId,
      lessorLicenseNumber: lessorLicenseNumber,
      lessorAddress: lessorAddress,
      lessorPhone: lessorPhone,
      lessorEmail: lessorEmail,
      lessorAuthorizedSignatory: lessorAuthorizedSignatory,
      lesseeType: lesseeType,
      lesseeName: lesseeName,
      lesseeIdCard: lesseeIdCard,
      lesseeTaxId: lesseeTaxId,
      lesseeAddress: lesseeAddress,
      lesseePhone: lesseePhone,
      lesseeEmail: lesseeEmail,
      lesseeAuthorizedSignatory: lesseeAuthorizedSignatory,
      propertyType: propertyType,
      projectName: projectName,
      houseNumber: houseNumber,
      floor: floor,
      building: json['property_building']?.toString(),
      soi: soi,
      road: road,
      country: country,
      province: province,
      district: district,
      subdistrict: subdistrict,
      postalCode: postalCode,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      parking: parking,
      landSize: landSize,
      usableArea: usableArea,
      startDate: startDate,
      endDate: endDate,
      leasePeriod: leasePeriod,
      renewalFormat: renewalFormat,
      renewalConditions: renewalConditions,
      rentalFee: rentalFee,
      commonFee: commonFee,
      serviceFee: serviceFee,
      advanceRental: advanceRental,
      damageDeposit: damageDeposit,
      totalMonthlyPayment: totalMonthlyPayment,
      totalPayment: totalPayment,
      paymentDueDate: paymentDueDate,
      waterFee: waterFee,
      lateFee: lateFee,
      paymentChannel: paymentChannel,
      branch: branch,
      accountName: accountName,
      accountNumber: accountNumber,
      additionalConditions: additionalConditions,
      flexibleTerms: flexibleTerms,
      banks: banks,
      accountTypes: accountTypes,
    );
  }

  ContractFormData _mapPropertyToState(ContractFormData state, property) {
    final specs = property.specs;
    final location = property.propertyLocation;

    // Asset - Pre-fill from property
    String? projectName = specs?.name ?? property.name;
    // Get house number from number.original first, then fallback to number, then computedHouseNumber
    String? houseNumber;
    if (location?.number != null) {
      // If number is a string, use it directly
      houseNumber = location!.number;
    }
    houseNumber ??= location?.computedHouseNumber;
    // Normalize country value: convert "ประเทศไทย" or "Thailand" to "ไทย"
    String? countryRaw = location?.country;
    String? country = 'ไทย'; // Default
    if (countryRaw != null) {
      final normalized = countryRaw.trim();
      if (normalized == 'ประเทศไทย' ||
          normalized == 'Thailand' ||
          normalized == 'ไทย') {
        country = 'ไทย';
      } else {
        country = normalized;
      }
    }
    String? province = location?.state;
    String? district = location?.city;
    String? postalCode = location?.postalCode;
    String? bedrooms = specs?.bedrooms.toString();
    String? bathrooms = specs?.bathrooms.toString();
    String? parking = specs?.garage.toString();
    String? landSize = specs?.landSize?.toString();
    String? usableArea = specs?.buildingSize?.toString();

    return state.copyWith(
      propertyType: specs?.type,
      projectName: projectName,
      houseNumber: houseNumber,
      country: country,
      province: province,
      district: district,
      postalCode: postalCode,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      parking: parking,
      landSize: landSize,
      usableArea: usableArea,
    );
  }

  void _onFieldUpdated(
    ContractFormFieldUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is ContractFormData) {
      final currentState = state as ContractFormData;
      ContractFormData newState = currentState;

      switch (event.field) {
        // Lessor fields
        case 'lessorName':
          newState = currentState.copyWith(lessorName: event.value as String?);
          break;
        case 'lessorIdCard':
          newState = currentState.copyWith(
            lessorIdCard: event.value as String?,
          );
          break;
        case 'lessorTaxId':
          newState = currentState.copyWith(lessorTaxId: event.value as String?);
          break;
        case 'lessorLicenseNumber':
          newState = currentState.copyWith(
            lessorLicenseNumber: event.value as String?,
          );
          break;
        case 'lessorAddress':
          newState = currentState.copyWith(
            lessorAddress: event.value as String?,
          );
          break;
        case 'lessorPhone':
          newState = currentState.copyWith(lessorPhone: event.value as String?);
          break;
        case 'lessorEmail':
          newState = currentState.copyWith(lessorEmail: event.value as String?);
          break;
        case 'lessorAuthorizedSignatory':
          newState = currentState.copyWith(
            lessorAuthorizedSignatory: event.value as String?,
          );
          break;

        // Lessee fields
        case 'lesseeName':
          newState = currentState.copyWith(lesseeName: event.value as String?);
          break;
        case 'lesseeIdCard':
          newState = currentState.copyWith(
            lesseeIdCard: event.value as String?,
          );
          break;
        case 'lesseeTaxId':
          newState = currentState.copyWith(lesseeTaxId: event.value as String?);
          break;
        case 'lesseeAddress':
          newState = currentState.copyWith(
            lesseeAddress: event.value as String?,
          );
          break;
        case 'lesseePhone':
          newState = currentState.copyWith(lesseePhone: event.value as String?);
          break;
        case 'lesseeEmail':
          newState = currentState.copyWith(lesseeEmail: event.value as String?);
          break;
        case 'lesseeAuthorizedSignatory':
          newState = currentState.copyWith(
            lesseeAuthorizedSignatory: event.value as String?,
          );
          break;

        // Property fields
        case 'projectName':
          newState = currentState.copyWith(projectName: event.value as String?);
          break;
        case 'houseNumber':
          newState = currentState.copyWith(houseNumber: event.value as String?);
          break;
        case 'floor':
          newState = currentState.copyWith(floor: event.value as String?);
          break;
        case 'soi':
          newState = currentState.copyWith(soi: event.value as String?);
          break;
        case 'road':
          newState = currentState.copyWith(road: event.value as String?);
          break;
        case 'postalCode':
          newState = currentState.copyWith(postalCode: event.value as String?);
          break;
        case 'bedrooms':
          newState = currentState.copyWith(bedrooms: event.value as String?);
          break;
        case 'bathrooms':
          newState = currentState.copyWith(bathrooms: event.value as String?);
          break;
        case 'parking':
          newState = currentState.copyWith(parking: event.value as String?);
          break;
        case 'landSize':
          newState = currentState.copyWith(landSize: event.value as String?);
          break;
        case 'usableArea':
          newState = currentState.copyWith(usableArea: event.value as String?);
          break;

        // Contract duration fields
        case 'renewalConditions':
          newState = currentState.copyWith(
            renewalConditions: event.value as String?,
          );
          break;

        // Payment fields - format currency
        case 'rentalFee':
          newState = currentState.copyWith(
            rentalFee: _formatCurrency(event.value as String? ?? ''),
          );
          _recalculateTotalMonthlyPayment(newState, emit);
          return;
        case 'commonFee':
          newState = currentState.copyWith(
            commonFee: _formatCurrency(event.value as String? ?? ''),
          );
          _recalculateTotalMonthlyPayment(newState, emit);
          return;
        case 'serviceFee':
          newState = currentState.copyWith(
            serviceFee: _formatCurrency(event.value as String? ?? ''),
          );
          _recalculateTotalMonthlyPayment(newState, emit);
          return;
        case 'advanceRental':
          newState = currentState.copyWith(
            advanceRental: _formatCurrency(event.value as String? ?? ''),
          );
          _recalculateTotalUpfrontPayment(newState, emit);
          return; // Early return after recalculation
        case 'damageDeposit':
          newState = currentState.copyWith(
            damageDeposit: _formatCurrency(event.value as String? ?? ''),
          );
          _recalculateTotalUpfrontPayment(newState, emit);
          return; // Early return after recalculation
        case 'waterFee':
          newState = currentState.copyWith(waterFee: event.value as String?);
          break;
        case 'lateFee':
          newState = currentState.copyWith(
            lateFee: _formatCurrency(event.value as String? ?? ''),
          );
          break;
        case 'paymentDueDate':
          newState = currentState.copyWith(
            paymentDueDate: event.value as String?,
          );
          break;
        case 'branch':
          newState = currentState.copyWith(branch: event.value as String?);
          break;
        case 'accountName':
          newState = currentState.copyWith(accountName: event.value as String?);
          break;
        case 'accountNumber':
          newState = currentState.copyWith(
            accountNumber: event.value as String?,
          );
          break;

        // Terms
        case 'additionalConditions':
          newState = currentState.copyWith(
            additionalConditions: event.value as String?,
          );
          break;
      }

      emit(newState);
    }
  }

  void _recalculateTotalMonthlyPayment(
    ContractFormData state,
    Emitter<ContractFormState> emit,
  ) {
    final rent = _parseCurrency(state.rentalFee ?? '') ?? 0;
    final common = _parseCurrency(state.commonFee ?? '') ?? 0;
    final service = _parseCurrency(state.serviceFee ?? '') ?? 0;
    final total = rent + common + service;
    emit(
      state.copyWith(
        totalMonthlyPayment: total > 0
            ? _formatCurrency(total.toString())
            : null,
      ),
    );
  }

  void _recalculateTotalUpfrontPayment(
    ContractFormData state,
    Emitter<ContractFormState> emit,
  ) {
    final advance = _parseCurrency(state.advanceRental ?? '');
    final deposit = _parseCurrency(state.damageDeposit ?? '');
    final total = (advance ?? 0) + (deposit ?? 0);
    final totalPayment = total > 0 ? _formatCurrency(total.toString()) : null;
    emit(state.copyWith(totalPayment: totalPayment));
  }

  void _onTypeChanged(
    ContractFormTypeChanged event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is ContractFormData) {
      emit((state as ContractFormData).copyWith(contractType: event.type));
    }
  }

  void _onLessorTypeChanged(
    ContractFormLessorTypeChanged event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is ContractFormData) {
      emit((state as ContractFormData).copyWith(lessorType: event.type));
    }
  }

  void _onLesseeTypeChanged(
    ContractFormLesseeTypeChanged event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is ContractFormData) {
      emit((state as ContractFormData).copyWith(lesseeType: event.type));
    }
  }

  void _onPropertyTypeChanged(
    ContractFormPropertyTypeChanged event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is ContractFormData) {
      emit((state as ContractFormData).copyWith(propertyType: event.type));
    }
  }

  void _onCountryChanged(
    ContractFormCountryChanged event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is ContractFormData) {
      emit((state as ContractFormData).copyWith(country: event.country));
    }
  }

  void _onProvinceChanged(
    ContractFormProvinceChanged event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is ContractFormData) {
      emit((state as ContractFormData).copyWith(province: event.province));
    }
  }

  void _onDistrictChanged(
    ContractFormDistrictChanged event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is ContractFormData) {
      emit((state as ContractFormData).copyWith(district: event.district));
    }
  }

  void _onSubdistrictChanged(
    ContractFormSubdistrictChanged event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is ContractFormData) {
      emit(
        (state as ContractFormData).copyWith(subdistrict: event.subdistrict),
      );
    }
  }

  void _onContractDateChanged(
    ContractFormContractDateChanged event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is ContractFormData) {
      emit((state as ContractFormData).copyWith(contractDate: event.date));
    }
  }

  void _onStartDateChanged(
    ContractFormStartDateChanged event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is ContractFormData) {
      final currentState = state as ContractFormData;
      String? leasePeriod;

      if (event.date != null && currentState.endDate != null) {
        final difference = currentState.endDate!.difference(event.date!);
        final months = (difference.inDays / 30).round();
        leasePeriod = '$months เดือน';
      }

      emit(
        currentState.copyWith(startDate: event.date, leasePeriod: leasePeriod),
      );
    }
  }

  void _onEndDateChanged(
    ContractFormEndDateChanged event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is ContractFormData) {
      final currentState = state as ContractFormData;
      String? leasePeriod;

      if (currentState.startDate != null && event.date != null) {
        final difference = event.date!.difference(currentState.startDate!);
        final months = (difference.inDays / 30).round();
        leasePeriod = '$months เดือน';
      }

      emit(
        currentState.copyWith(endDate: event.date, leasePeriod: leasePeriod),
      );
    }
  }

  void _onRenewalFormatChanged(
    ContractFormRenewalFormatChanged event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is ContractFormData) {
      emit((state as ContractFormData).copyWith(renewalFormat: event.format));
    }
  }

  void _onPaymentChannelChanged(
    ContractFormPaymentChannelChanged event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is ContractFormData) {
      emit((state as ContractFormData).copyWith(paymentChannel: event.channel));
    }
  }

  void _onSubmitted(
    ContractFormSubmitted event,
    Emitter<ContractFormState> emit,
  ) async {
    if (state is! ContractFormData) return;
    final currentState = state as ContractFormData;

    emit(
      currentState.copyWith(
        isSubmitting: true,
        submitSuccess: false,
        submitErrorMessage: null,
      ),
    );

    try {
      final payload = Map<String, dynamic>.from(event.formData);

      // Ensure identifiers are included when creating from property/booking
      if (currentState.propertyId != null) {
        payload['property_id'] = currentState.propertyId;
      }
      if (currentState.bookingId != null) {
        payload['booking_id'] = currentState.bookingId;
      }

      if (currentState.contractIdInt != null) {
        await _contractApiService.updateContractRaw(
          contractId: currentState.contractIdInt!,
          payload: payload,
        );
      } else if (currentState.propertyId != null) {
        await _contractApiService.createContractFromPropertyRaw(
          payload: payload,
        );
      } else if (currentState.bookingId != null) {
        await _contractApiService.createContractFromBookingRaw(
          payload: payload,
        );
      } else {
        throw Exception('Unknown submit mode (no ids found)');
      }

      emit(
        currentState.copyWith(
          isSubmitting: false,
          submitSuccess: true,
          submitErrorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        currentState.copyWith(
          isSubmitting: false,
          submitSuccess: false,
          submitErrorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  // Helper methods
  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    final clean = value.replaceAll(',', '').replaceAll(' ', '');
    final num = double.tryParse(clean);
    if (num == null) return value;
    return NumberFormat('#,###').format(num.round());
  }

  double? _parseCurrency(String value) {
    if (value.isEmpty) return null;
    final clean = value.replaceAll(',', '').replaceAll(' ', '');
    return double.tryParse(clean);
  }

  Future<void> _onRegisterClient(
    ContractFormRegisterClient event,
    Emitter<ContractFormState> emit,
  ) async {
    if (state is! ContractFormData) return;

    final currentState = state as ContractFormData;

    // Emit loading state
    if (event.type == 'lessor') {
      emit(
        currentState.copyWith(
          lessorRegistrationStatus: RegistrationStatus.loading,
          registrationErrorMessage: null,
        ),
      );
    } else if (event.type == 'lessee') {
      emit(
        currentState.copyWith(
          lesseeRegistrationStatus: RegistrationStatus.loading,
          registrationErrorMessage: null,
        ),
      );
    }

    try {
      // Call appropriate service method
      if (event.type == 'lessor') {
        await _clientService.registerSeller(event.data);
      } else if (event.type == 'lessee') {
        await _clientService.registerBuyer(event.data);
      } else {
        throw Exception('Invalid client type: ${event.type}');
      }

      // On success: emit success status and auto-fill form fields
      final name = event.data['name']?.toString();
      final email = event.data['email']?.toString();
      final phone = event.data['phone']?.toString();

      if (event.type == 'lessor') {
        emit(
          currentState.copyWith(
            lessorRegistrationStatus: RegistrationStatus.success,
            registrationErrorMessage: null,
            lessorName: name ?? currentState.lessorName,
            lessorEmail: email ?? currentState.lessorEmail,
            lessorPhone: phone ?? currentState.lessorPhone,
          ),
        );
      } else if (event.type == 'lessee') {
        emit(
          currentState.copyWith(
            lesseeRegistrationStatus: RegistrationStatus.success,
            registrationErrorMessage: null,
            lesseeName: name ?? currentState.lesseeName,
            lesseeEmail: email ?? currentState.lesseeEmail,
            lesseePhone: phone ?? currentState.lesseePhone,
          ),
        );
      }
    } catch (e) {
      // On failure: emit failure status with error message
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      if (event.type == 'lessor') {
        emit(
          currentState.copyWith(
            lessorRegistrationStatus: RegistrationStatus.failure,
            registrationErrorMessage: errorMessage,
          ),
        );
      } else if (event.type == 'lessee') {
        emit(
          currentState.copyWith(
            lesseeRegistrationStatus: RegistrationStatus.failure,
            registrationErrorMessage: errorMessage,
          ),
        );
      }
    }
  }

  void _onClearRegistration(
    ContractFormClearRegistration event,
    Emitter<ContractFormState> emit,
  ) {
    if (state is! ContractFormData) return;

    final currentState = state as ContractFormData;

    if (event.type == 'lessor') {
      emit(
        currentState.copyWith(
          lessorRegistrationStatus: RegistrationStatus.initial,
          registrationErrorMessage: null,
        ),
      );
    } else if (event.type == 'lessee') {
      emit(
        currentState.copyWith(
          lesseeRegistrationStatus: RegistrationStatus.initial,
          registrationErrorMessage: null,
        ),
      );
    }
  }
}
