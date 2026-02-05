import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/domain/entities/person_type.dart';
import 'package:youragent/domain/entities/owner.dart';
import 'package:youragent/domain/entities/buyer.dart';
import 'package:youragent/domain/entities/appliance_item.dart';
import 'package:youragent/domain/entities/furniture_item.dart';
import 'package:youragent/services/property_api_service.dart';
import 'package:youragent/services/contract_api_service.dart';
import 'contract_form_event.dart';
import 'contract_form_state.dart';
import 'package:youragent/domain/entities/contract_type.dart';
import 'package:youragent/domain/entities/contract_edit_data.dart';
import 'package:youragent/domain/entities/contract_attachment.dart';

class ContractFormBloc extends Bloc<ContractFormEvent, ContractFormState> {
  final PropertyApiService _propertyApiService;
  final ContractApiService _contractApiService;

  ContractFormBloc({
    required PropertyApiService propertyApiService,
    required ContractApiService contractApiService,
  }) : _propertyApiService = propertyApiService,
       _contractApiService = contractApiService,
       super(const ContractFormState()) {
    on<ContractFormStepChanged>(_onStepChanged);
    on<ContractFormPropertyNameUpdated>(_onPropertyNameUpdated);
    on<ContractFormPropertiesFetched>(_onPropertiesFetched);
    on<ContractFormPropertySelected>(_onPropertySelected);
    on<ContractFormPropertyDataFetched>(_onPropertyDataFetched);
    on<ContractFormDateUpdated>(_onDateUpdated);
    on<ContractFormTypeUpdated>(_onTypeUpdated);
    on<ContractFormSubmitted>(_onSubmitted);

    // Step 2
    on<ContractFormOwnerTypeUpdated>(_onOwnerTypeUpdated);
    on<ContractFormOwnerNameUpdated>(_onOwnerNameUpdated);
    on<ContractFormOwnerIdCardUpdated>(_onOwnerIdCardUpdated);
    on<ContractFormOwnerAddressUpdated>(_onOwnerAddressUpdated);
    on<ContractFormOwnerPhoneUpdated>(_onOwnerPhoneUpdated);
    on<ContractFormOwnerEmailUpdated>(_onOwnerEmailUpdated);
    on<ContractFormOwnerSignatoryUpdated>(_onOwnerSignatoryUpdated);
    on<ContractFormOwnersFetched>(_onOwnersFetched);
    on<ContractFormOwnerSelected>(_onOwnerSelected);

    // Step 3
    on<ContractFormBuyerTypeUpdated>(_onBuyerTypeUpdated);
    on<ContractFormBuyerNameUpdated>(_onBuyerNameUpdated);
    on<ContractFormBuyerIdCardUpdated>(_onBuyerIdCardUpdated);
    on<ContractFormBuyerAddressUpdated>(_onBuyerAddressUpdated);
    on<ContractFormBuyerPhoneUpdated>(_onBuyerPhoneUpdated);
    on<ContractFormBuyerEmailUpdated>(_onBuyerEmailUpdated);
    on<ContractFormBuyersFetched>(_onBuyersFetched);
    on<ContractFormBuyerSelected>(_onBuyerSelected);

    // Step 4
    on<ContractFormApplianceAdded>(_onApplianceAdded);
    on<ContractFormApplianceRemoved>(_onApplianceRemoved);
    on<ContractFormApplianceUpdated>(_onApplianceUpdated);
    on<ContractFormApplianceImagesAdded>(_onApplianceImagesAdded);
    on<ContractFormApplianceImageRemoved>(_onApplianceImageRemoved);
    on<ContractFormAppliancePropertyImageSelected>(
      _onAppliancePropertyImageSelected,
    );

    // Step 5
    on<ContractFormFurnitureAdded>(_onFurnitureAdded);
    on<ContractFormFurnitureRemoved>(_onFurnitureRemoved);
    on<ContractFormFurnitureUpdated>(_onFurnitureUpdated);
    on<ContractFormFurnitureImagesAdded>(_onFurnitureImagesAdded);
    on<ContractFormFurnitureImageRemoved>(_onFurnitureImageRemoved);
    on<ContractFormFurniturePropertyImageSelected>(
      _onFurniturePropertyImageSelected,
    );

    // Step 6
    on<ContractFormPriceUpdated>(_onPriceUpdated);
    on<ContractFormCommonFeeUpdated>(_onCommonFeeUpdated);
    on<ContractFormOtherServiceFeeUpdated>(_onOtherServiceFeeUpdated);
    on<ContractFormAdvanceRentUpdated>(_onAdvanceRentUpdated);
    on<ContractFormSecurityDepositUpdated>(_onSecurityDepositUpdated);
    on<ContractFormDueDateUpdated>(_onDueDateUpdated);
    on<ContractFormLateFeeUpdated>(_onLateFeeUpdated);
    on<ContractFormPaymentMethodUpdated>(_onPaymentMethodUpdated);
    on<ContractFormBankCodeUpdated>(_onBankCodeUpdated);
    on<ContractFormBankBranchUpdated>(_onBankBranchUpdated);
    on<ContractFormAccountNameUpdated>(_onAccountNameUpdated);
    on<ContractFormAccountNumberUpdated>(_onAccountNumberUpdated);

    // Step 1 Refinement
    on<ContractFormLeaseFormatUpdated>(_onLeaseFormatUpdated);
    on<ContractFormLeaseStartDateUpdated>(_onLeaseStartDateUpdated);
    on<ContractFormLeaseEndDateUpdated>(_onLeaseEndDateUpdated);
    on<ContractFormAdditionalConditionsUpdated>(_onAdditionalConditionsUpdated);
    on<ContractFormInitialized>(_onInitialized);
    on<ContractFormEditStarted>(_onEditStarted);

    // Step 8: Attachments
    on<ContractFormAttachmentAdded>(_onAttachmentAdded);
    on<ContractFormAttachmentRemoved>(_onAttachmentRemoved);
    on<ContractFormAttachmentNameUpdated>(_onAttachmentNameUpdated);
    on<ContractFormAttachmentFileUpdated>(_onAttachmentFileUpdated);
    on<ContractFormRemoteAttachmentDeleted>(_onRemoteAttachmentDeleted);
  }

  Future<void> _onEditStarted(
    ContractFormEditStarted event,
    Emitter<ContractFormState> emit,
  ) async {
    emit(state.copyWith(status: ContractFormStatus.loading));
    try {
      final ContractEditData data = await _contractApiService
          .getContractEditData(event.contractId);

      final contract = data.contract;
      final createData = data.config;

      // Re-use logic to populate state from contract
      // We essentially do what _onInitialized does, plus setting createData

      // Helper to parse double
      double parseDouble(String? val) {
        if (val == null) return 0.0;
        return double.tryParse(val.replaceAll(',', '')) ?? 0.0;
      }

      emit(
        state.copyWith(
          // Basic Info
          contractId: contract.id,
          selectedProperty: contract.property,
          propertyName: contract.propertyName,
          contractDate: contract.contractDate,
          contractType: contract.contractType,
          leaseFormat: contract.commonTerms ?? '',

          // Owner
          ownerType: contract.owner?.type ?? PersonType.individual,
          ownerName: contract.owner?.name ?? '',
          ownerIdCard: contract.owner?.idCard ?? '',
          ownerAddress: contract.owner?.address ?? '',
          ownerPhone: contract.owner?.phone ?? '',
          ownerEmail: contract.owner?.email ?? '',
          ownerSignatory: contract.owner?.signatory ?? '',

          // Buyer
          buyerType: contract.buyer?.type ?? PersonType.individual,
          buyerName: contract.buyer?.name ?? '',
          buyerIdCard: contract.buyer?.idCard ?? '',
          buyerAddress: contract.buyer?.address ?? '',
          buyerPhone: contract.buyer?.phone ?? '',
          buyerEmail: contract.buyer?.email ?? '',

          // Items
          applianceItems: contract.appliances,
          furnitureItems: contract.furniture,

          // Payment
          price: parseDouble(contract.monthlyRentalCost),
          commonFee: parseDouble(contract.commonFee),
          advanceRent: parseDouble(contract.advanceRent),
          securityDeposit: parseDouble(contract.securityDeposit),
          dueDate: contract.rentalPaymentDate,
          paymentMethod: contract.paymentMethod ?? 'Bank',

          // Bank Details
          bankBranch: contract.bankAccounts.isNotEmpty
              ? contract.bankAccounts.first.branch ?? ''
              : '',
          accountName: contract.bankAccounts.isNotEmpty
              ? contract.bankAccounts.first.accountHolderName
              : '',
          accountNumber: contract.bankAccounts.isNotEmpty
              ? contract.bankAccounts.first.accountNumber
              : '',
          bankCode: contract.bankAccounts.isNotEmpty
              ? contract.bankAccounts.first.bankCode
              : '',

          // Additional
          additionalConditions: contract.flexibleTerms ?? '',

          // Config Data
          contractCreateData: createData,
        ),
      );

      _validateCurrentStep(emit);

      // Fetch documents if editing
      try {
        final documents = await _contractApiService.getContractDocuments(
          event.contractId,
        );
        emit(state.copyWith(attachments: documents));
      } catch (e) {
        // Log error but don't fail the whole edit start
        print('Error fetching documents: $e');
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ContractFormStatus.failure,
          errorMessage: 'Failed to fetch contract edit data: $e',
        ),
      );
    }
  }

  void _onInitialized(
    ContractFormInitialized event,
    Emitter<ContractFormState> emit,
  ) {
    final c = event.contract;

    // Parse numeric values with defaults
    double parseDouble(String? val) {
      if (val == null) return 0.0;
      return double.tryParse(val.replaceAll(',', '')) ?? 0.0;
    }

    // Parse date if string, though entity has DateTime?
    // Entity fields are already DateTime? or String?

    emit(
      state.copyWith(
        // Basic Info
        contractId: c.id,
        selectedProperty: c.property,
        propertyName: c.propertyName,
        contractDate: c.contractDate,
        contractType: c.contractType,
        leaseFormat:
            c.commonTerms ??
            '', // Assuming map to lease format if needed, or separate field
        // Note: Lease Start/End dates might be in flexibleTerms or strictly not in current entity structure clearly.
        // Assuming current display logic uses Entity fields.

        // Owner
        ownerType: c.owner?.type ?? PersonType.individual,
        ownerName: c.owner?.name ?? '',
        ownerIdCard: c.owner?.idCard ?? '',
        ownerAddress: c.owner?.address ?? '',
        ownerPhone: c.owner?.phone ?? '',
        ownerEmail: c.owner?.email ?? '',
        ownerSignatory: c.owner?.signatory ?? '', // Assuming mapped/available
        // Buyer
        buyerType: c.buyer?.type ?? PersonType.individual,
        buyerName: c.buyer?.name ?? '',
        buyerIdCard: c.buyer?.idCard ?? '',
        buyerAddress: c.buyer?.address ?? '',
        buyerPhone: c.buyer?.phone ?? '',
        buyerEmail: c.buyer?.email ?? '',

        // Items
        applianceItems: c.appliances,
        furnitureItems: c.furniture,

        // Payment
        price: parseDouble(c.monthlyRentalCost),
        commonFee: parseDouble(c.commonFee),
        // otherServiceFee: not directly in entity unless mapped
        advanceRent: parseDouble(c.advanceRent),
        securityDeposit: parseDouble(c.securityDeposit),
        dueDate: c.rentalPaymentDate,
        // lateFee: not directly in entity
        paymentMethod: c.paymentMethod ?? 'Bank',
        // Bank details would need to be extracted from c.bankAccounts if singular or picked
        bankBranch: c.bankAccounts.isNotEmpty
            ? c.bankAccounts.first.branch ?? ''
            : '',
        accountName: c.bankAccounts.isNotEmpty
            ? c.bankAccounts.first.accountHolderName
            : '',
        accountNumber: c.bankAccounts.isNotEmpty
            ? c.bankAccounts.first.accountNumber
            : '',
        bankCode: c.bankAccounts.isNotEmpty
            ? c.bankAccounts.first.bankCode
            : '',
        // Additional
        additionalConditions:
            c.flexibleTerms ??
            '', // Assuming this maps to additional conditions
      ),
    );

    _validateCurrentStep(emit);
  }

  void _onStepChanged(
    ContractFormStepChanged event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(step: event.step));
    _validateCurrentStep(emit);
  }

  void _onPropertyNameUpdated(
    ContractFormPropertyNameUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(propertyName: event.propertyName));
    _validateCurrentStep(emit);
  }

  Future<void> _onPropertiesFetched(
    ContractFormPropertiesFetched event,
    Emitter<ContractFormState> emit,
  ) async {
    try {
      final properties = await _propertyApiService.getProperties();

      List<Property> filtered;
      if (event.query.isEmpty) {
        filtered = properties.toList();
      } else {
        final query = event.query.toLowerCase();
        filtered = properties.where((p) {
          final nameMatch = p.name?.toLowerCase().contains(query) ?? false;
          final titleMatch = p.title.toLowerCase().contains(query);
          final addressMatch =
              p.address?.toLowerCase().contains(query) ?? false;
          return nameMatch || titleMatch || addressMatch;
        }).toList();
      }

      // Sort by name (prefer name, then title)
      filtered.sort((a, b) {
        final nameA = (a.name ?? a.title).toLowerCase();
        final nameB = (b.name ?? b.title).toLowerCase();
        return nameA.compareTo(nameB);
      });

      emit(state.copyWith(properties: filtered));
    } catch (e) {
      // Just log and ignore for now in search
    }
  }

  void _onPropertySelected(
    ContractFormPropertySelected event,
    Emitter<ContractFormState> emit,
  ) {
    emit(
      state.copyWith(
        selectedProperty: event.property,
        propertyName: event.property.name ?? event.property.title,
      ),
    );
    _validateCurrentStep(emit);

    // Fetch additional property data for auto-filling
    if (event.property.id != null) {
      add(ContractFormPropertyDataFetched(event.property.id!));
    }
  }

  Future<void> _onPropertyDataFetched(
    ContractFormPropertyDataFetched event,
    Emitter<ContractFormState> emit,
  ) async {
    emit(state.copyWith(status: ContractFormStatus.loading));
    try {
      final createData = await _contractApiService.getContractCreateData(
        propertyId: event.propertyId,
      );

      final owner = createData.owner;

      // Auto-fill Step 1 Contract Type
      ContractType? contractType;
      if (createData.contractType == 'buy' ||
          createData.contractType == 'sale') {
        contractType = ContractType.buy;
      } else if (createData.contractType == 'rent' ||
          createData.contractType == 'rental') {
        contractType = ContractType.rent;
      }

      // Auto-fill Step 4 Appliances
      final applianceItems = createData.appliances.map((a) {
        return ApplianceItem(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              a['name'].hashCode.toString(),
          name: a['name']?.toString() ?? '',
          description: a['description']?.toString(),
          propertyImageId: a['property_image_id'] as int?,
          existingPhotoUrl: a['existing_photo_url']?.toString(),
          images: const [],
        );
      }).toList();

      // Auto-fill Step 5 Furniture
      final furnitureItems = createData.furniture.map((f) {
        return FurnitureItem(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              f['name'].hashCode.toString(),
          name: f['name']?.toString() ?? '',
          description: f['description']?.toString(),
          propertyImageId: f['property_image_id'] as int?,
          existingPhotoUrl: f['existing_photo_url']?.toString(),
          images: const [],
        );
      }).toList();

      if (owner != null) {
        emit(
          state.copyWith(
            contractCreateData: createData,
            contractType: contractType ?? state.contractType,
            ownerName: owner.name,
            ownerIdCard: owner.idCard ?? '',
            ownerAddress: owner.address ?? '',
            ownerPhone: owner.phone ?? '',
            ownerEmail: owner.email ?? '',
            ownerType: owner.type,
            applianceItems: applianceItems.isNotEmpty
                ? applianceItems
                : state.applianceItems,
            furnitureItems: furnitureItems.isNotEmpty
                ? furnitureItems
                : state.furnitureItems,
            status: ContractFormStatus.initial,
          ),
        );
      } else {
        emit(
          state.copyWith(
            contractCreateData: createData,
            contractType: contractType ?? state.contractType,
            applianceItems: applianceItems.isNotEmpty
                ? applianceItems
                : state.applianceItems,
            furnitureItems: furnitureItems.isNotEmpty
                ? furnitureItems
                : state.furnitureItems,
            status: ContractFormStatus.initial,
          ),
        );
      }

      _validateCurrentStep(emit);
    } catch (e) {
      emit(
        state.copyWith(
          status: ContractFormStatus.failure,
          errorMessage: 'Failed to fetch property details: $e',
        ),
      );
    }
  }

  void _onDateUpdated(
    ContractFormDateUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(contractDate: event.date));
    _validateCurrentStep(emit);
  }

  void _onTypeUpdated(
    ContractFormTypeUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(contractType: event.type));
    _validateCurrentStep(emit);
  }

  void _validateCurrentStep(Emitter<ContractFormState> emit) {
    bool isValid = false;
    if (state.step == 1) {
      final baseValid =
          state.propertyName.isNotEmpty &&
          state.contractDate != null &&
          state.contractType != null;

      if (state.contractType == ContractType.rent) {
        isValid =
            baseValid &&
            state.leaseFormat.isNotEmpty &&
            state.leaseStartDate != null &&
            state.leaseEndDate != null;
      } else {
        isValid = baseValid;
      }
    } else if (state.step == 2) {
      // Step 2 Validation: Red asterisk fields from Image 1
      isValid =
          state.ownerName.isNotEmpty &&
          state.ownerIdCard.isNotEmpty &&
          state.ownerAddress.isNotEmpty &&
          state.ownerPhone.isNotEmpty &&
          state.ownerEmail.isNotEmpty;
    } else if (state.step == 3) {
      // Step 3 Validation: Red asterisk fields from Image for buyer
      isValid =
          state.buyerName.isNotEmpty &&
          state.buyerIdCard.isNotEmpty &&
          state.buyerAddress.isNotEmpty &&
          state.buyerPhone.isNotEmpty &&
          state.buyerEmail.isNotEmpty;
    } else if (state.step == 4) {
      // Step 4 Validation: Appliances
      if (state.applianceItems.isEmpty) {
        isValid = true;
      } else {
        isValid = state.applianceItems.every(
          (item) =>
              item.name.isNotEmpty &&
              (item.images.isNotEmpty || item.propertyImageId != null),
        );
      }
    } else if (state.step == 5) {
      // Step 5 Validation: Furniture
      if (state.furnitureItems.isEmpty) {
        isValid = true;
      } else {
        isValid = state.furnitureItems.every(
          (item) =>
              item.name.isNotEmpty &&
              (item.images.isNotEmpty || item.propertyImageId != null),
        );
      }
    } else if (state.step == 6) {
      // Step 6 Validation: Payment
      final isRent = state.contractType == ContractType.rent;

      bool baseValid =
          state.price > 0 &&
          state.paymentMethod.isNotEmpty &&
          state.bankBranch.isNotEmpty &&
          state.accountName.isNotEmpty &&
          state.accountNumber.isNotEmpty;

      if (state.paymentMethod == 'Bank' && (state.bankCode?.isEmpty ?? true)) {
        baseValid = false;
      }

      if (isRent) {
        isValid =
            baseValid &&
            state.commonFee >= 0 &&
            state.otherServiceFee >= 0 &&
            state.advanceRent > 0 &&
            state.securityDeposit > 0 &&
            state.dueDate != null &&
            state.lateFee >= 0;
      } else {
        isValid = baseValid;
      }
    } else if (state.step == 7) {
      // Step 7 Validation: Additional Conditions
      // Usually optional, but we can set it to true or check if it's not too long
      isValid = true;
    } else if (state.step == 8) {
      // Step 8 Validation: Attachments
      if (state.attachments.isEmpty) {
        isValid = true; // Optional step
      } else {
        isValid = state.attachments.every(
          (a) => a.name.isNotEmpty && a.filePath != null,
        );
      }
    } else {
      // Logic for other steps
      isValid = true;
    }
    emit(state.copyWith(isValid: isValid));
  }

  // Step 2 Handlers
  void _onOwnerTypeUpdated(
    ContractFormOwnerTypeUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(ownerType: event.type));
    _validateCurrentStep(emit);
  }

  void _onOwnerNameUpdated(
    ContractFormOwnerNameUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(ownerName: event.name));
    _validateCurrentStep(emit);
  }

  void _onOwnerIdCardUpdated(
    ContractFormOwnerIdCardUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(ownerIdCard: event.idCard));
    _validateCurrentStep(emit);
  }

  void _onOwnerAddressUpdated(
    ContractFormOwnerAddressUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(ownerAddress: event.address));
    _validateCurrentStep(emit);
  }

  void _onOwnerPhoneUpdated(
    ContractFormOwnerPhoneUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(ownerPhone: event.phone));
    _validateCurrentStep(emit);
  }

  void _onOwnerEmailUpdated(
    ContractFormOwnerEmailUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(ownerEmail: event.email));
    _validateCurrentStep(emit);
  }

  void _onOwnerSignatoryUpdated(
    ContractFormOwnerSignatoryUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(ownerSignatory: event.signatory));
    _validateCurrentStep(emit);
  }

  Future<void> _onOwnersFetched(
    ContractFormOwnersFetched event,
    Emitter<ContractFormState> emit,
  ) async {
    try {
      final owners = [
        const Owner(
          id: 1,
          name: 'สมชาย ใจดี',
          idCard: '1234567890123',
          address: '123/456 กรุงเทพฯ',
          phone: '0812345678',
          email: 'somchai@example.com',
          type: PersonType.individual,
        ),
      ];

      final filtered = owners.where((o) {
        return o.name.toLowerCase().contains(event.query.toLowerCase());
      }).toList();

      emit(state.copyWith(owners: filtered));
    } catch (e) {
      // Ignore
    }
  }

  void _onOwnerSelected(
    ContractFormOwnerSelected event,
    Emitter<ContractFormState> emit,
  ) {
    emit(
      state.copyWith(
        selectedOwner: event.owner,
        ownerType: event.owner.type,
        ownerName: event.owner.name,
        ownerIdCard: event.owner.idCard ?? '',
        ownerAddress: event.owner.address ?? '',
        ownerPhone: event.owner.phone ?? '',
        ownerEmail: event.owner.email ?? '',
        ownerSignatory: event.owner.signatory ?? '',
      ),
    );
    _validateCurrentStep(emit);
  }

  // Step 3 Handlers
  void _onBuyerTypeUpdated(
    ContractFormBuyerTypeUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(buyerType: event.type));
    _validateCurrentStep(emit);
  }

  void _onBuyerNameUpdated(
    ContractFormBuyerNameUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(buyerName: event.name));
    _validateCurrentStep(emit);
  }

  void _onBuyerIdCardUpdated(
    ContractFormBuyerIdCardUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(buyerIdCard: event.idCard));
    _validateCurrentStep(emit);
  }

  void _onBuyerAddressUpdated(
    ContractFormBuyerAddressUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(buyerAddress: event.address));
    _validateCurrentStep(emit);
  }

  void _onBuyerPhoneUpdated(
    ContractFormBuyerPhoneUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(buyerPhone: event.phone));
    _validateCurrentStep(emit);
  }

  void _onBuyerEmailUpdated(
    ContractFormBuyerEmailUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(buyerEmail: event.email));
    _validateCurrentStep(emit);
  }

  Future<void> _onBuyersFetched(
    ContractFormBuyersFetched event,
    Emitter<ContractFormState> emit,
  ) async {
    try {
      // Mocking for now
      final buyers = [
        const Buyer(
          id: 1,
          name: 'ใจดี มีสุข',
          idCard: '9876543210987',
          address: '456/789 กรุงเทพฯ',
          phone: '0898765432',
          email: 'jaidee@example.com',
          type: PersonType.individual,
        ),
      ];

      final filtered = buyers.where((b) {
        return b.name.toLowerCase().contains(event.query.toLowerCase());
      }).toList();

      emit(state.copyWith(buyers: filtered));
    } catch (e) {
      // Ignore
    }
  }

  void _onBuyerSelected(
    ContractFormBuyerSelected event,
    Emitter<ContractFormState> emit,
  ) {
    emit(
      state.copyWith(
        selectedBuyer: event.buyer,
        buyerName: event.buyer.name,
        buyerIdCard: event.buyer.idCard,
        buyerAddress: event.buyer.address,
        buyerPhone: event.buyer.phone,
        buyerEmail: event.buyer.email,
        buyerType: event.buyer.type,
      ),
    );
    _validateCurrentStep(emit);
  }

  // Step 4 Handlers
  void _onApplianceAdded(
    ContractFormApplianceAdded event,
    Emitter<ContractFormState> emit,
  ) {
    final newItem = ApplianceItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
      images: const [],
    );
    final newList = List<ApplianceItem>.from(state.applianceItems)
      ..add(newItem);
    emit(state.copyWith(applianceItems: newList));
    _validateCurrentStep(emit);
  }

  void _onApplianceRemoved(
    ContractFormApplianceRemoved event,
    Emitter<ContractFormState> emit,
  ) {
    final newList = state.applianceItems
        .where((item) => item.id != event.id)
        .toList();
    emit(state.copyWith(applianceItems: newList));
    _validateCurrentStep(emit);
  }

  void _onApplianceUpdated(
    ContractFormApplianceUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    final newList = state.applianceItems.map((item) {
      return item.id == event.item.id ? event.item : item;
    }).toList();
    emit(state.copyWith(applianceItems: newList));
    _validateCurrentStep(emit);
  }

  void _onApplianceImagesAdded(
    ContractFormApplianceImagesAdded event,
    Emitter<ContractFormState> emit,
  ) {
    final newList = state.applianceItems.map((item) {
      if (item.id == event.id) {
        return item.copyWith(
          images: List<String>.from(item.images)..addAll(event.images),
        );
      }
      return item;
    }).toList();
    emit(state.copyWith(applianceItems: newList));
    _validateCurrentStep(emit);
  }

  void _onApplianceImageRemoved(
    ContractFormApplianceImageRemoved event,
    Emitter<ContractFormState> emit,
  ) {
    final newList = state.applianceItems.map((item) {
      if (item.id == event.id) {
        return item.copyWith(
          images: item.images.where((img) => img != event.imagePath).toList(),
        );
      }
      return item;
    }).toList();
    emit(state.copyWith(applianceItems: newList));
    _validateCurrentStep(emit);
  }

  Future<void> _onSubmitted(
    ContractFormSubmitted event,
    Emitter<ContractFormState> emit,
  ) async {
    emit(state.copyWith(status: ContractFormStatus.submmitting));
    try {
      final contractData = _collectContractData();

      if (state.contractId != null) {
        // Update existing contract
        await _contractApiService.updateContract(
          id: state.contractId!,
          data: contractData,
        );

        // Upload attachments
        await _uploadAttachments(state.contractId!);

        emit(state.copyWith(status: ContractFormStatus.success));
      } else {
        // Create new contract
        final newContractId = await _contractApiService.createContract(
          data: contractData,
        );

        // Upload attachments
        await _uploadAttachments(newContractId);

        emit(state.copyWith(status: ContractFormStatus.success));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ContractFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Map<String, dynamic> _collectContractData() {
    return {
      if (state.contractId != null) 'id': state.contractId,
      'property_id': state.selectedProperty?.id,
      'contract_date': state.contractDate?.toIso8601String(),
      'contract_type': state.contractType == ContractType.buy ? 'buy' : 'rent',

      // Step 2: Owner
      'owner': {
        'type': state.ownerType == PersonType.individual
            ? 'individual'
            : 'juristic',
        'name': state.ownerName,
        'id_card': state.ownerIdCard,
        'address': state.ownerAddress,
        'phone': state.ownerPhone,
        'email': state.ownerEmail,
        if (state.ownerType == PersonType.juristic)
          'signatory': state.ownerSignatory,
      },

      // Step 3: Buyer
      'buyer': {
        'type': state.buyerType == PersonType.individual
            ? 'individual'
            : 'juristic',
        'name': state.buyerName,
        'id_card': state.buyerIdCard,
        'address': state.buyerAddress,
        'phone': state.buyerPhone,
        'email': state.buyerEmail,
      },

      // Step 4: Appliances
      'appliances': state.applianceItems.map((item) {
        return {
          'id': item.id,
          'name': item.name,
          'description': item.description,
          'property_image_id': item.propertyImageId,
          'existing_photo_url': item.existingPhotoUrl,
          // 'images': item.images,
        };
      }).toList(),

      // Step 5: Furniture
      'furniture': state.furnitureItems.map((item) {
        return {
          'id': item.id,
          'name': item.name,
          'description': item.description,
          'property_image_id': item.propertyImageId,
          'existing_photo_url': item.existingPhotoUrl,
        };
      }).toList(),

      // Step 6: Payment
      'monthly_rental_cost': state.price,
      'common_fee': state.commonFee,
      'other_service_fee': state.otherServiceFee,
      'advance_rent': state.advanceRent,
      'security_deposit': state.securityDeposit,
      'rental_payment_date': state.dueDate,
      'late_fee': state.lateFee,
      'payment_method': state.paymentMethod,

      'bank_accounts': [
        if (state.paymentMethod == 'Bank')
          {
            'bank_code': state.bankCode,
            'branch': state.bankBranch,
            'account_holder_name': state.accountName,
            'account_number': state.accountNumber,
          },
      ],

      // Step 7/Refinement
      'common_terms': state.leaseFormat,
      'flexible_terms': state.additionalConditions,

      // Dates
      'lease_start_date': state.leaseStartDate?.toIso8601String(),
      'lease_end_date': state.leaseEndDate?.toIso8601String(),
    };
  }

  void _onAppliancePropertyImageSelected(
    ContractFormAppliancePropertyImageSelected event,
    Emitter<ContractFormState> emit,
  ) {
    final newList = state.applianceItems.map((item) {
      if (item.id == event.applianceId) {
        return item.copyWith(
          propertyImageId: event.propertyImageId,
          existingPhotoUrl: event.url,
        );
      }
      return item;
    }).toList();
    emit(state.copyWith(applianceItems: newList));
    _validateCurrentStep(emit);
  }

  // Step 5 Handlers
  void _onFurnitureAdded(
    ContractFormFurnitureAdded event,
    Emitter<ContractFormState> emit,
  ) {
    final newItem = FurnitureItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '',
      images: const [],
    );
    final newList = List<FurnitureItem>.from(state.furnitureItems)
      ..add(newItem);
    emit(state.copyWith(furnitureItems: newList));
    _validateCurrentStep(emit);
  }

  void _onFurnitureRemoved(
    ContractFormFurnitureRemoved event,
    Emitter<ContractFormState> emit,
  ) {
    final newList = state.furnitureItems
        .where((item) => item.id != event.id)
        .toList();
    emit(state.copyWith(furnitureItems: newList));
    _validateCurrentStep(emit);
  }

  void _onFurnitureUpdated(
    ContractFormFurnitureUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    final newList = state.furnitureItems.map((item) {
      return item.id == event.item.id ? event.item : item;
    }).toList();
    emit(state.copyWith(furnitureItems: newList));
    _validateCurrentStep(emit);
  }

  void _onFurnitureImagesAdded(
    ContractFormFurnitureImagesAdded event,
    Emitter<ContractFormState> emit,
  ) {
    final newList = state.furnitureItems.map((item) {
      if (item.id == event.id) {
        return item.copyWith(
          images: List<String>.from(item.images)..addAll(event.images),
        );
      }
      return item;
    }).toList();
    emit(state.copyWith(furnitureItems: newList));
    _validateCurrentStep(emit);
  }

  void _onFurnitureImageRemoved(
    ContractFormFurnitureImageRemoved event,
    Emitter<ContractFormState> emit,
  ) {
    final newList = state.furnitureItems.map((item) {
      if (item.id == event.id) {
        return item.copyWith(
          images: item.images.where((img) => img != event.imagePath).toList(),
        );
      }
      return item;
    }).toList();
    emit(state.copyWith(furnitureItems: newList));
    _validateCurrentStep(emit);
  }

  void _onFurniturePropertyImageSelected(
    ContractFormFurniturePropertyImageSelected event,
    Emitter<ContractFormState> emit,
  ) {
    final newList = state.furnitureItems.map((item) {
      if (item.id == event.furnitureId) {
        return item.copyWith(
          propertyImageId: event.propertyImageId,
          existingPhotoUrl: event.url,
        );
      }
      return item;
    }).toList();
    emit(state.copyWith(furnitureItems: newList));
    _validateCurrentStep(emit);
  }

  // Step 6 Handlers
  void _onPriceUpdated(
    ContractFormPriceUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    final newState = state.copyWith(price: event.price);
    _calculateTotals(newState, emit);
  }

  void _onCommonFeeUpdated(
    ContractFormCommonFeeUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    final newState = state.copyWith(commonFee: event.fee);
    _calculateTotals(newState, emit);
  }

  void _onOtherServiceFeeUpdated(
    ContractFormOtherServiceFeeUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    final newState = state.copyWith(otherServiceFee: event.fee);
    _calculateTotals(newState, emit);
  }

  void _onAdvanceRentUpdated(
    ContractFormAdvanceRentUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    final newState = state.copyWith(advanceRent: event.rent);
    _calculateTotals(newState, emit);
  }

  void _onSecurityDepositUpdated(
    ContractFormSecurityDepositUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    final newState = state.copyWith(securityDeposit: event.deposit);
    _calculateTotals(newState, emit);
  }

  void _calculateTotals(
    ContractFormState stateBeforeCalculation,
    Emitter<ContractFormState> emit,
  ) {
    final totalMonthly =
        stateBeforeCalculation.price +
        stateBeforeCalculation.commonFee +
        stateBeforeCalculation.otherServiceFee;
    final totalUpfront =
        stateBeforeCalculation.advanceRent +
        stateBeforeCalculation.securityDeposit;

    emit(
      stateBeforeCalculation.copyWith(
        totalMonthlyPayment: totalMonthly,
        totalUpfrontPayment: totalUpfront,
      ),
    );
    _validateCurrentStep(emit);
  }

  void _onDueDateUpdated(
    ContractFormDueDateUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(dueDate: event.dueDate));
    _validateCurrentStep(emit);
  }

  void _onLateFeeUpdated(
    ContractFormLateFeeUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(lateFee: event.fee));
    _validateCurrentStep(emit);
  }

  void _onPaymentMethodUpdated(
    ContractFormPaymentMethodUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(paymentMethod: event.method));
    _validateCurrentStep(emit);
  }

  void _onBankCodeUpdated(
    ContractFormBankCodeUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(bankCode: event.code));
    _validateCurrentStep(emit);
  }

  void _onBankBranchUpdated(
    ContractFormBankBranchUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(bankBranch: event.branch));
    _validateCurrentStep(emit);
  }

  void _onAccountNameUpdated(
    ContractFormAccountNameUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(accountName: event.name));
    _validateCurrentStep(emit);
  }

  void _onAccountNumberUpdated(
    ContractFormAccountNumberUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(accountNumber: event.number));
    _validateCurrentStep(emit);
  }

  // Step 1 Refinement Handlers
  void _onLeaseFormatUpdated(
    ContractFormLeaseFormatUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    // If selecting the same format, unselect it (toggle behavior)
    final newFormat = state.leaseFormat == event.format ? '' : event.format;

    // Create new state with updated format
    var newState = state.copyWith(leaseFormat: newFormat);

    // If format is selected, auto-calculate end date
    if (newFormat.isNotEmpty && newState.leaseStartDate != null) {
      newState = _autoCalculateEndDate(newState);
    }

    emit(newState);
    _calculateLeaseDuration(newState, emit); // Recalculate duration if needed
  }

  void _onLeaseStartDateUpdated(
    ContractFormLeaseStartDateUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    var newState = state.copyWith(leaseStartDate: event.date);

    // If format is selected, auto-calculate end date
    if (newState.leaseFormat.isNotEmpty && newState.leaseStartDate != null) {
      newState = _autoCalculateEndDate(newState);
    }

    _calculateLeaseDuration(newState, emit);
  }

  ContractFormState _autoCalculateEndDate(ContractFormState currentState) {
    if (currentState.leaseStartDate == null) return currentState;

    DateTime start = currentState.leaseStartDate!;
    int monthsToAdd = 0;

    if (currentState.leaseFormat.contains('6')) {
      monthsToAdd = 6;
    } else if (currentState.leaseFormat.contains('12')) {
      monthsToAdd = 12;
    }

    if (monthsToAdd > 0) {
      // Calculate end date: Start Date + N months - 1 day
      // Example: Jan 1 + 12 months = Jan 1 next year. Minus 1 day = Dec 31.
      DateTime endDate = DateTime(
        start.year,
        start.month + monthsToAdd,
        start.day,
      );
      endDate = endDate.subtract(const Duration(days: 1));

      return currentState.copyWith(leaseEndDate: endDate);
    }

    return currentState;
  }

  void _onLeaseEndDateUpdated(
    ContractFormLeaseEndDateUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    if (state.leaseFormat.isEmpty) {
      final newState = state.copyWith(leaseEndDate: event.date);
      _calculateLeaseDuration(newState, emit);
    }
  }

  void _calculateLeaseDuration(
    ContractFormState stateBeforeCalc,
    Emitter<ContractFormState> emit,
  ) {
    if (stateBeforeCalc.leaseStartDate != null &&
        stateBeforeCalc.leaseEndDate != null) {
      final start = stateBeforeCalc.leaseStartDate!;
      final end = stateBeforeCalc.leaseEndDate!;

      final days = end.difference(start).inDays;

      emit(stateBeforeCalc.copyWith(leaseDuration: days));
    } else {
      emit(stateBeforeCalc.copyWith(leaseDuration: 0));
    }
    _validateCurrentStep(emit);
  }

  void _onAdditionalConditionsUpdated(
    ContractFormAdditionalConditionsUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    emit(state.copyWith(additionalConditions: event.conditions));
    _validateCurrentStep(emit);
  }

  // Step 8 Handlers
  void _onAttachmentAdded(
    ContractFormAttachmentAdded event,
    Emitter<ContractFormState> emit,
  ) {
    final newItem = ContractAttachment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    final newList = List<ContractAttachment>.from(state.attachments)
      ..add(newItem);
    emit(state.copyWith(attachments: newList));
    _validateCurrentStep(emit);
  }

  void _onAttachmentRemoved(
    ContractFormAttachmentRemoved event,
    Emitter<ContractFormState> emit,
  ) {
    final newList = state.attachments.where((a) => a.id != event.id).toList();
    emit(state.copyWith(attachments: newList));
    _validateCurrentStep(emit);
  }

  void _onAttachmentNameUpdated(
    ContractFormAttachmentNameUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    final newList = state.attachments.map((a) {
      return a.id == event.id ? a.copyWith(name: event.name) : a;
    }).toList();
    emit(state.copyWith(attachments: newList));
    _validateCurrentStep(emit);
  }

  void _onAttachmentFileUpdated(
    ContractFormAttachmentFileUpdated event,
    Emitter<ContractFormState> emit,
  ) {
    final newList = state.attachments.map((a) {
      return a.id == event.id
          ? a.copyWith(
              filePath: event.filePath,
              fileSize: event.fileSize,
              clearFilePath: event.filePath == null,
              clearFileSize: event.fileSize == null,
            )
          : a;
    }).toList();
    emit(state.copyWith(attachments: newList));
    _validateCurrentStep(emit);
  }

  Future<void> _onRemoteAttachmentDeleted(
    ContractFormRemoteAttachmentDeleted event,
    Emitter<ContractFormState> emit,
  ) async {
    try {
      await _contractApiService.deleteContractDocument(
        event.contractId,
        event.documentId,
      );
      final newList = state.attachments
          .where((a) => a.id != event.attachmentId)
          .toList();
      emit(state.copyWith(attachments: newList));
      _validateCurrentStep(emit);
    } catch (e) {
      emit(
        state.copyWith(
          status: ContractFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _uploadAttachments(int contractId) async {
    for (final attachment in state.attachments) {
      if (attachment.filePath != null && !attachment.isRemote) {
        await _contractApiService.uploadContractDocument(
          contractId: contractId,
          name: attachment.name,
          filePath: attachment.filePath!,
        );
      }
    }
  }
}
