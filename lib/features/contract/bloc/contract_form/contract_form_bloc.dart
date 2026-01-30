import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/domain/entities/person_type.dart';
import 'package:youragent/domain/entities/property_owner.dart';
import 'package:youragent/services/property_api_service.dart';
import 'contract_form_event.dart';
import 'contract_form_state.dart';

class ContractFormBloc extends Bloc<ContractFormEvent, ContractFormState> {
  final PropertyApiService _propertyApiService;

  ContractFormBloc({required PropertyApiService propertyApiService})
    : _propertyApiService = propertyApiService,
      super(const ContractFormState()) {
    on<ContractFormStepChanged>(_onStepChanged);
    on<ContractFormPropertyNameUpdated>(_onPropertyNameUpdated);
    on<ContractFormPropertiesFetched>(_onPropertiesFetched);
    on<ContractFormPropertySelected>(_onPropertySelected);
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
      isValid =
          state.propertyName.isNotEmpty &&
          state.contractDate != null &&
          state.contractType != null;
    } else if (state.step == 2) {
      // Step 2 Validation: Red asterisk fields from Image 1
      isValid =
          state.ownerName.isNotEmpty &&
          state.ownerIdCard.isNotEmpty &&
          state.ownerAddress.isNotEmpty &&
          state.ownerPhone.isNotEmpty &&
          state.ownerEmail.isNotEmpty;
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
    // For now, we'll mock this or use propertyApiService if it provides owner search
    // Based on requirements, we need to show existing owners
    try {
      // Mocking for now as we don't have a dedicated owner API service yet
      final owners = [
        const PropertyOwner(
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

  Future<void> _onSubmitted(
    ContractFormSubmitted event,
    Emitter<ContractFormState> emit,
  ) async {
    emit(state.copyWith(status: ContractFormStatus.submmitting));
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(status: ContractFormStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: ContractFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
