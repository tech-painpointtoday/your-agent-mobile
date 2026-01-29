import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/property_api_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../data/models/property_specification_filters.dart';
import '../../../../services/address_lookup_service.dart';

import '../../../../domain/entities/property.dart';
import '../../../../data/models/developer_model.dart';
import '../../../../data/models/condo_project_model.dart';
import 'property_form_event.dart';
import 'property_form_state.dart';

export 'property_form_event.dart';
export 'property_form_state.dart';

class PropertyFormBloc extends Bloc<PropertyFormEvent, PropertyFormState> {
  final PropertyApiService _propertyApiService;
  final AddressLookupService _addressLookupService;
  final PropertySpecificationFilters? initialFilters;
  final List<CondoProject> _allCondoProjects;

  PropertyFormBloc({
    PropertyApiService? propertyApiService,
    AddressLookupService? addressLookupService,
    this.initialFilters,
    Property? initialProperty,
    List<Developer>? initialDevelopers,
    List<CondoProject>? initialCondoProjects,
  }) : _propertyApiService =
           propertyApiService ?? DependencyInjection.propertyApiService,
       _addressLookupService =
           addressLookupService ?? DependencyInjection.addressLookupService,
       _allCondoProjects = initialCondoProjects ?? const [],
       super(
         initialProperty != null
             ? PropertyFormState.fromProperty(
                 initialProperty,
                 filters: initialFilters,
               ).copyWith(
                 developers: initialDevelopers,
                 condoProjects: initialCondoProjects,
               )
             : PropertyFormState(
                 specificationFilters:
                     initialFilters ?? const PropertySpecificationFilters(),
                 developers: initialDevelopers ?? const [],
                 condoProjects: initialCondoProjects ?? const [],
               ),
       ) {
    on<PropertyFormStepChanged>(_onStepChanged);
    on<PropertyFormTypeSelected>(_onTypeSelected);
    on<PropertyFormGeneralInfoUpdated>(_onGeneralInfoUpdated);
    on<PropertyFormDataUpdated>(_onDataUpdated);
    on<PropertyFormLocationUpdated>(_onLocationUpdated);
    on<PropertyFormLocationFieldUpdated>(_onLocationFieldUpdated);
    on<PropertyFormDetailsUpdated>(_onDetailsUpdated);
    on<PropertyFormAdditionalInfoUpdated>(_onAdditionalInfoUpdated);
    on<PropertyFormImagesUpdated>(_onImagesUpdated);
    on<PropertyFormSubmitted>(_onSubmitted);
    on<PropertyFormReset>(_onReset);

    // New handlers for master data
    on<PropertyFormDevelopersFetched>(_onDevelopersFetched);
    on<PropertyFormCondoProjectsFetched>(_onCondoProjectsFetched);
    on<PropertyFormDeveloperChanged>(_onDeveloperChanged);
    on<PropertyFormCondoProjectChanged>(_onCondoProjectChanged);
    on<PropertyFormListingTypeChanged>(_onListingTypeChanged);
    on<PropertyFormStatusChanged>(_onStatusChanged);
    on<PropertyFormStyleChanged>(_onStyleChanged);
    on<PropertyFormFiltersFetched>(_onFiltersFetched);
    on<PropertyFormDynamicSingleSelectChanged>(_onDynamicSingleSelectChanged);
    on<PropertyFormDynamicMultiSelectToggled>(_onDynamicMultiSelectToggled);
    on<PropertyFormResetStatus>(_onResetStatus);
  }

  void _onResetStatus(
    PropertyFormResetStatus event,
    Emitter<PropertyFormState> emit,
  ) {
    emit(state.copyWith(propertyFormStatus: PropertyFormStatus.initial));
  }

  void _onStepChanged(
    PropertyFormStepChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    emit(state.copyWith(step: event.step));
  }

  void _onTypeSelected(
    PropertyFormTypeSelected event,
    Emitter<PropertyFormState> emit,
  ) {
    emit(state.copyWith(selectedPropertyType: event.type));
  }

  void _onGeneralInfoUpdated(
    PropertyFormGeneralInfoUpdated event,
    Emitter<PropertyFormState> emit,
  ) {
    emit(
      state.copyWith(
        name: event.name,
        price: event.price,
        description: event.description,
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
      ),
    );
  }

  void _onDataUpdated(
    PropertyFormDataUpdated event,
    Emitter<PropertyFormState> emit,
  ) {
    // This is a generic way to update any field in the state.
    // For simplicity, we'll map key to field here.
    switch (event.key) {
      case 'name':
        emit(state.copyWith(name: event.value as String?));
        break;
      case 'address':
        emit(state.copyWith(address: event.value as String?));
        break;
      case 'project':
        // Handle project if needed (missed in current state fields)
        break;
      case 'developer':
        // Handle developer if needed
        break;
      case 'building':
        emit(state.copyWith(tower: event.value as String?));
        break;
      case 'floor':
        emit(state.copyWith(condoFloor: event.value as String?));
        break;
      case 'room_number':
        emit(state.copyWith(unitNo: event.value as String?));
        break;
    }
  }

  void _onLocationUpdated(
    PropertyFormLocationUpdated event,
    Emitter<PropertyFormState> emit,
  ) {
    final data = event.locationData;
    emit(
      state.copyWith(
        latitude: data['latitude'] as double?,
        longitude: data['longitude'] as double?,
        number: data['number'] as String?,
        city: data['city'] as String?,
        state: data['state'] as String?,
        province: data['province'] as String?,
        subdistrict: data['subdistrict'] as String?,
        soi: data['soi'] as String?,
        road: data['road'] as String?,
        postalCode: data['postal_code'] as String?,
        country: data['country'] as String?,
        district: data['district'] as String?,
        formattedAddressEn: data['formatted_address_en'] as String?,
        formattedAddressTh: data['formatted_address_th'] as String?,
      ),
    );
  }

  void _onLocationFieldUpdated(
    PropertyFormLocationFieldUpdated event,
    Emitter<PropertyFormState> emit,
  ) {
    switch (event.key) {
      case 'number':
        emit(state.copyWith(number: event.value));
        break;
      case 'road':
        emit(state.copyWith(road: event.value));
        break;
      case 'soi':
        emit(state.copyWith(soi: event.value));
        break;
      case 'subdistrict':
        emit(state.copyWith(subdistrict: event.value));
        break;
      case 'district':
        emit(state.copyWith(district: event.value));
        break;
      case 'city':
        emit(state.copyWith(city: event.value));
        break;
      case 'state':
        emit(state.copyWith(state: event.value));
        break;
      case 'postal_code':
        emit(state.copyWith(postalCode: event.value));
        break;
      case 'formatted_address_en':
        emit(state.copyWith(formattedAddressEn: event.value));
        break;
      case 'province':
        emit(state.copyWith(province: event.value));
        break;
    }
  }

  void _onDetailsUpdated(
    PropertyFormDetailsUpdated event,
    Emitter<PropertyFormState> emit,
  ) {
    emit(
      state.copyWith(
        bedrooms: event.bedrooms,
        bathrooms: event.bathrooms,
        garage: event.garage,
        landSize: event.landSize,
        buildingSize: event.buildingSize,
        houseColor: event.houseColor,
        totalFloors: event.totalFloors,
      ),
    );
  }

  void _onAdditionalInfoUpdated(
    PropertyFormAdditionalInfoUpdated event,
    Emitter<PropertyFormState> emit,
  ) {
    emit(
      state.copyWith(
        built: event.built,
        direction: event.direction,
        availableFrom: event.availableFrom,
      ),
    );
  }

  void _onImagesUpdated(
    PropertyFormImagesUpdated event,
    Emitter<PropertyFormState> emit,
  ) {
    emit(state.copyWith(images: event.images));
  }

  Future<void> _onSubmitted(
    PropertyFormSubmitted event,
    Emitter<PropertyFormState> emit,
  ) async {
    // 1. Validate
    if (!state.isValid) {
      emit(
        state.copyWith(
          propertyFormStatus: PropertyFormStatus.submissionFailure,
          errorMessage: 'กรุณากรอกข้อมูลให้ครบถ้วน',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        propertyFormStatus: PropertyFormStatus.submissionInProgress,
      ),
    );

    try {
      final roleName = state.selectedDeveloperId != null ? 'agency' : 'agent';

      // 2. Auto-fill Address Lookup
      PropertyFormState currentState = state;

      // Check if critical fields are missing
      final bool missingSubdistrict =
          currentState.subdistrict == null || currentState.subdistrict!.isEmpty;
      final bool missingDistrict =
          currentState.district == null || currentState.district!.isEmpty;
      final bool missingProvince =
          currentState.province == null || currentState.province!.isEmpty;
      final bool missingPostalCode =
          currentState.postalCode == null || currentState.postalCode!.isEmpty;

      if (missingSubdistrict ||
          missingDistrict ||
          missingProvince ||
          missingPostalCode) {
        final lookupResult = _addressLookupService.lookup(
          district: currentState.subdistrict,
          city: currentState.district,
          province: currentState.province,
          postalCode: currentState.postalCode,
        );

        if (lookupResult != null) {
          final foundAmphoe = lookupResult['amphoe'] as String;
          final foundDistrict = lookupResult['district'] as String;
          final foundProvince = lookupResult['province'] as String;
          final foundZipcode = lookupResult['zipcode'].toString();

          currentState = currentState.copyWith(
            subdistrict: missingSubdistrict
                ? foundDistrict
                : currentState.subdistrict,
            district: missingDistrict ? foundAmphoe : currentState.district,
            city: (currentState.city == null || currentState.city!.isEmpty)
                ? foundAmphoe
                : currentState.city,
            province: missingProvince ? foundProvince : currentState.province,
            postalCode: missingPostalCode
                ? foundZipcode
                : currentState.postalCode,
          );
        }
      }

      // 3. Build Payload (Unified)
      // Use state.data which constructs the map for API
      final payload = currentState.data;

      Property responseProperty;

      if (state.propertyId != null) {
        responseProperty = await _propertyApiService.updateProperty(
          role: roleName,
          propertyId: state.propertyId!,
          data: payload,
        );
      } else {
        // CREATE
        responseProperty = await _propertyApiService.saveProperty(
          role: roleName,
          data: payload,
        );
      }

      final propertyId = responseProperty.id;

      // Upload photos if any
      final localImages = state.images
          .where((img) => img.isFile)
          .map((img) => img.file!)
          .toList();
      if (localImages.isNotEmpty && propertyId != null) {
        await _propertyApiService.uploadPhotosSimple(
          role: roleName,
          propertyId: propertyId,
          photos: localImages,
          tag: 'gallery',
        );
      }

      emit(
        state.copyWith(
          propertyFormStatus: PropertyFormStatus.submissionSuccess,
          propertyId: propertyId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          propertyFormStatus: PropertyFormStatus.submissionFailure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onReset(PropertyFormReset event, Emitter<PropertyFormState> emit) {
    emit(const PropertyFormState());
  }

  Future<void> _onDevelopersFetched(
    PropertyFormDevelopersFetched event,
    Emitter<PropertyFormState> emit,
  ) async {
    // 1. Use cached if available
    if (state.developers.isNotEmpty) return;

    try {
      final developers = await _propertyApiService.getDevelopers();
      emit(state.copyWith(developers: developers));
    } catch (e) {
      // Silently fail or log
    }
  }

  Future<void> _onCondoProjectsFetched(
    PropertyFormCondoProjectsFetched event,
    Emitter<PropertyFormState> emit,
  ) async {
    // 1. Use cached master list if available
    if (_allCondoProjects.isNotEmpty) {
      if (event.developerId == null) {
        emit(state.copyWith(condoProjects: _allCondoProjects));
        return;
      }
      final filtered = _allCondoProjects
          .where((p) => p.developerId == event.developerId)
          .toList();
      emit(state.copyWith(condoProjects: filtered));
      return;
    }

    // 2. Fallback to API
    try {
      final projects = await _propertyApiService.getCondoProjects(
        developerId: event.developerId,
      );
      emit(state.copyWith(condoProjects: projects));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _onDeveloperChanged(
    PropertyFormDeveloperChanged event,
    Emitter<PropertyFormState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedDeveloperId: event.developerId,
        selectedCondoProjectId: null,
      ),
    );

    try {
      final projects = await _propertyApiService.getCondoProjects(
        developerId: event.developerId,
      );
      emit(state.copyWith(condoProjects: projects));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _onCondoProjectChanged(
    PropertyFormCondoProjectChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    // Bidirectional sync: If project is selected, also select its developer
    int? devId;
    if (event.projectId != null) {
      try {
        final project = state.condoProjects.firstWhere(
          (p) => p.id == event.projectId,
        );
        devId = project.developerId;
      } catch (_) {
        devId = state.selectedDeveloperId;
      }
    }

    emit(
      state.copyWith(
        selectedCondoProjectId: event.projectId,
        selectedDeveloperId: devId ?? state.selectedDeveloperId,
      ),
    );
  }

  void _onListingTypeChanged(
    PropertyFormListingTypeChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    emit(state.copyWith(listingType: event.listingType));
  }

  void _onStatusChanged(
    PropertyFormStatusChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    emit(state.copyWith(status: event.status));
  }

  void _onStyleChanged(
    PropertyFormStyleChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    emit(state.copyWith(propertyStyle: event.style));
  }

  Future<void> _onFiltersFetched(
    PropertyFormFiltersFetched event,
    Emitter<PropertyFormState> emit,
  ) async {
    try {
      final filters = await _propertyApiService.getSpecificationFilters();
      emit(state.copyWith(specificationFilters: filters));
    } catch (e) {
      debugPrint('Error fetching filters: $e');
    }
  }

  void _onDynamicSingleSelectChanged(
    PropertyFormDynamicSingleSelectChanged event,
    Emitter<PropertyFormState> emit,
  ) {
    final newValues = Map<String, dynamic>.from(state.dynamicValues);
    newValues[event.key] = event.value;

    // Also sync with legacy fields if they match known keys for backward compatibility
    PropertyFormState newState = state.copyWith(dynamicValues: newValues);

    switch (event.key) {
      case 'floors':
        // Try parsing float first then int, "10+" -> 10 ??
        // The API returns strings like "10+", "1".
        // State expects Int for totalFloors.
        final cleanVal = event.value.replaceAll(RegExp(r'[^0-9]'), '');
        newState = newState.copyWith(totalFloors: int.tryParse(cleanVal));
        break;
      case 'bedrooms':
        if (event.value == 'Studio') {
          newState = newState.copyWith(bedrooms: 0);
        } else {
          final cleanVal = event.value.replaceAll(RegExp(r'[^0-9]'), '');
          newState = newState.copyWith(bedrooms: int.tryParse(cleanVal));
        }
        break;
      case 'bathrooms':
        final cleanVal = event.value.replaceAll(RegExp(r'[^0-9]'), '');
        newState = newState.copyWith(bathrooms: int.tryParse(cleanVal));
        break;
      case 'parking_spaces':
        final cleanVal = event.value.replaceAll(RegExp(r'[^0-9]'), '');
        newState = newState.copyWith(garage: int.tryParse(cleanVal));
        break;
      case 'house_color':
        newState = newState.copyWith(
          houseColor: PropertyColor.fromLabel(event.value),
        );
        break;
      case 'direction':
        newState = newState.copyWith(
          direction: PropertyDirection.fromLabel(event.value),
        );
        break;
    }

    emit(newState);
  }

  void _onDynamicMultiSelectToggled(
    PropertyFormDynamicMultiSelectToggled event,
    Emitter<PropertyFormState> emit,
  ) {
    final newValues = Map<String, dynamic>.from(state.dynamicValues);
    final currentList =
        (newValues[event.key] as List<dynamic>?)?.cast<String>() ?? [];
    final newList = List<String>.from(currentList);

    if (newList.contains(event.value)) {
      newList.remove(event.value);
    } else {
      newList.add(event.value);
    }
    newValues[event.key] = newList;
    emit(state.copyWith(dynamicValues: newValues));
  }
}
