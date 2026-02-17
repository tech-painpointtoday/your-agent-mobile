import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/property_api_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../data/models/property_specification_filters.dart';
import '../../../../services/address_lookup_service.dart';
import '../../../../services/api_response_service.dart';

import '../../../../domain/entities/property.dart';
import '../../../../data/models/developer_model.dart';
import '../../../../data/models/condo_project_model.dart';
import '../../../../domain/entities/user.dart';
import 'property_form_event.dart';
import 'property_form_state.dart';
import '../../../../data/models/house_project_model.dart';

export 'property_form_event.dart';
export 'property_form_state.dart';

class PropertyFormBloc extends Bloc<PropertyFormEvent, PropertyFormState> {
  final PropertyApiService _propertyApiService;
  final AddressLookupService _addressLookupService;
  final PropertySpecificationFilters? initialFilters;

  /// Cache: projects by developerId (null = all projects). Used so we don't refetch when switching back.
  final Map<int?, List<CondoProject>> _projectsByDeveloper = {};
  final Map<int?, List<HouseProject>> _houseProjectsByDeveloper = {};

  PropertyFormBloc({
    PropertyApiService? propertyApiService,
    AddressLookupService? addressLookupService,
    this.initialFilters,
    Property? initialProperty,
    List<Developer>? initialDevelopers,
    List<CondoProject>? initialCondoProjects,
    List<HouseProject>? initialHouseProjects,
  }) : _propertyApiService =
           propertyApiService ?? DependencyInjection.propertyApiService,
       _addressLookupService =
           addressLookupService ?? DependencyInjection.addressLookupService,
       super(
         initialProperty != null
             ? () {
                 // Create state from property
                 final state = PropertyFormState.fromProperty(
                   initialProperty,
                   filters: initialFilters,
                 );
                 // Filter condo/house projects if developer is selected
                 final devId = state.selectedDeveloperId;
                 final filteredCondoProjects = devId != null
                     ? (initialCondoProjects ?? const [])
                           .where((p) => p.developerId == devId)
                           .toList()
                     : (initialCondoProjects ?? const []);
                 final filteredHouseProjects = devId != null
                     ? (initialHouseProjects ?? const [])
                           .where((p) => p.developerId == devId)
                           .toList()
                     : (initialHouseProjects ?? const []);

                 return state.copyWith(
                   developers: initialDevelopers,
                   condoProjects: filteredCondoProjects,
                   houseProjects: filteredHouseProjects,
                 );
               }()
             : PropertyFormState(
                 specificationFilters:
                     initialFilters ?? const PropertySpecificationFilters(),
                 developers: initialDevelopers ?? const [],
                 condoProjects: initialCondoProjects ?? const [],
                 houseProjects: initialHouseProjects ?? const [],
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
    on<PropertyFormImageDeleted>(_onImageDeleted);
    on<PropertyFormAllImagesDeleted>(_onAllImagesDeleted);
    on<PropertyFormSubmitted>(_onSubmitted);
    on<PropertyFormReset>(_onReset);

    // New handlers for master data
    on<PropertyFormDevelopersFetched>(_onDevelopersFetched);
    on<PropertyFormCondoProjectsFetched>(_onCondoProjectsFetched);
    on<PropertyFormHouseProjectsFetched>(_onHouseProjectsFetched);
    on<PropertyFormDeveloperChanged>(_onDeveloperChanged);
    on<PropertyFormCondoProjectChanged>(_onCondoProjectChanged);
    on<PropertyFormHouseProjectChanged>(_onHouseProjectChanged);
    on<PropertyFormListingTypeChanged>(_onListingTypeChanged);
    on<PropertyFormStatusChanged>(_onStatusChanged);
    on<PropertyFormStyleChanged>(_onStyleChanged);
    on<PropertyFormFiltersFetched>(_onFiltersFetched);
    on<PropertyFormDynamicSingleSelectChanged>(_onDynamicSingleSelectChanged);
    on<PropertyFormDynamicMultiSelectToggled>(_onDynamicMultiSelectToggled);
    on<PropertyFormResetStatus>(_onResetStatus);
    on<PropertyFormDraftSaved>(_onDraftSaved);
    on<PropertyFormValidateRequested>(_onValidateRequested);
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
    emit(state.copyWith(step: event.step, showErrors: false));
  }

  void _onValidateRequested(
    PropertyFormValidateRequested event,
    Emitter<PropertyFormState> emit,
  ) {
    emit(state.copyWith(showErrors: true));
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
        if (state.isCondoOrApt) {
          if (event.value is int) {
            emit(state.copyWith(selectedCondoProjectId: event.value as int?));
          }
        } else {
          emit(
            state.copyWith(
              villageName: event.value as String?,
              selectedHouseProjectId: null,
            ),
          );
        }
        break;
      case 'developer':
        if (event.value is int) {
          emit(state.copyWith(selectedDeveloperId: event.value as int?));
        }
        break;
      case 'building':
        emit(state.copyWith(tower: event.value as String?));
        break;
      case 'floor':
        emit(state.copyWith(condoFloor: event.value as String?));
        break;
      case 'unit_no':
        emit(state.copyWith(unitNo: event.value as String?));
        break;
      case 'number':
        emit(state.copyWith(number: event.value as String?));
        break;
      case 'price':
        emit(state.copyWith(price: event.value as double?));
        break;
      case 'monthly_rental_price':
        emit(state.copyWith(monthlyRentalPrice: event.value as double?));
        break;
      case 'description':
        emit(state.copyWith(description: event.value as String?));
        break;
      case 'land_size':
        emit(state.copyWith(landSize: event.value as double?));
        break;
      case 'building_size':
        emit(state.copyWith(buildingSize: event.value as double?));
        break;
      case 'bedrooms':
        emit(state.copyWith(bedrooms: event.value as int?));
        break;
      case 'bathrooms':
        emit(state.copyWith(bathrooms: event.value as int?));
        break;
      case 'garage':
        emit(state.copyWith(garage: event.value as int?));
        break;
      case 'floors':
        emit(state.copyWith(totalFloors: event.value as int?));
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
        //number: data['number'] as String?,
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
      // case 'number':
      //   emit(state.copyWith(number: event.value));
      //   break;
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
    final newSpecs = Map<String, String>.from(state.specifications);
    if (event.bedrooms != null) {
      newSpecs['bedrooms'] = event.bedrooms.toString();
    }
    if (event.bathrooms != null) {
      newSpecs['bathrooms'] = event.bathrooms.toString();
    }
    if (event.garage != null) {
      newSpecs['garage'] = event.garage.toString();
      newSpecs['parking_spaces'] = event.garage.toString();
    }
    if (event.totalFloors != null) {
      newSpecs['total_floors'] = event.totalFloors.toString();
      newSpecs['floors'] = event.totalFloors.toString();
    }

    emit(
      state.copyWith(
        bedrooms: event.bedrooms,
        bathrooms: event.bathrooms,
        garage: event.garage,
        landSize: event.landSize,
        buildingSize: event.buildingSize,
        houseColor: event.houseColor,
        totalFloors: event.totalFloors,
        specifications: newSpecs,
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

  Future<void> _onImageDeleted(
    PropertyFormImageDeleted event,
    Emitter<PropertyFormState> emit,
  ) async {
    final index = event.index;
    if (index < 0 || index >= state.images.length) return;

    final image = state.images[index];
    final propertyId = state.propertyId;

    // If it's a remote image with an ID and we have a property ID, call the API
    if (image.isNetwork && image.id != null && propertyId != null) {
      try {
        await _propertyApiService.deletePropertyImage(
          propertyId: propertyId,
          imageId: image.id!,
        );
      } catch (e) {
        debugPrint('Failed to delete image from API: $e');
        // We could emit a failure state here, but for now we follow the user's logic
        // and proceed to remove it from the local state list anyway.
      }
    }

    final newImages = List<PropertyFormImage>.from(state.images)
      ..removeAt(index);
    emit(state.copyWith(images: newImages));
  }

  Future<void> _onAllImagesDeleted(
    PropertyFormAllImagesDeleted event,
    Emitter<PropertyFormState> emit,
  ) async {
    final propertyId = state.propertyId;

    if (propertyId != null) {
      // Loop and delete all remote images one by one as requested
      final remoteImages = state.images.where(
        (img) => img.isNetwork && img.id != null,
      );
      for (final image in remoteImages) {
        try {
          await _propertyApiService.deletePropertyImage(
            propertyId: propertyId,
            imageId: image.id!,
          );
        } catch (e) {
          debugPrint('Failed to delete image ${image.id} from API: $e');
        }
      }
    }

    emit(state.copyWith(images: const []));
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
      // Check if publishing a draft - Update it first
      if (state.isDraft && state.propertyId != null) {
        final roleName =
            DependencyInjection.authRepository.currentRole == UserRole.agency
            ? 'agency'
            : 'agent';

        // 1. Update with latest fields
        await _propertyApiService.updateProperty(
          role: roleName,
          propertyId: state.propertyId!,
          data: state.data,
        );

        // 2. Upload photos if any before publishing (Draft might have new local photos)
        final localImages = state.images
            .where((img) => img.isFile)
            .map((img) => img.file!)
            .toList();
        if (localImages.isNotEmpty) {
          await _propertyApiService.uploadPhotosProperty(
            role: roleName,
            propertyId: state.propertyId!,
            photos: localImages,
            tag: 'gallery',
          );
        }

        // 3. Publishing a draft property
        await _propertyApiService.publishProperty(
          propertyId: state.propertyId!,
        );

        // 4. Set condo/house details if present
        await _setPropertyTypeDetails(state, state.propertyId!);

        emit(
          state.copyWith(
            propertyFormStatus: PropertyFormStatus.submissionSuccess,
          ),
        );
        return;
      }

      // Creating a new property (original logic)
      final roleName =
          DependencyInjection.authRepository.currentRole == UserRole.agency
          ? 'agency'
          : 'agent';

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
      final payload = currentState.data;

      Property responseProperty;
      if (currentState.propertyId != null) {
        responseProperty = await _propertyApiService.updateProperty(
          role: roleName,
          propertyId: currentState.propertyId!,
          data: payload,
        );
      } else {
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
        await _propertyApiService.uploadPhotosProperty(
          role: roleName,
          propertyId: propertyId,
          photos: localImages,
          tag: 'gallery',
        );
      }

      // Set condo/house details if present
      await _setPropertyTypeDetails(currentState, propertyId!);

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
          errorMessage: ApiResponseService.getErrorMessage(e),
        ),
      );
    }
  }

  Future<void> _onDraftSaved(
    PropertyFormDraftSaved event,
    Emitter<PropertyFormState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          propertyFormStatus: PropertyFormStatus.draftSaveInProgress,
        ),
      );

      // No validation required - save partial data as-is
      final draftData = state.data;

      int? propertyId;
      if (state.propertyId != null) {
        // Update existing property/draft
        final response = await _propertyApiService.updateProperty(
          propertyId: state.propertyId!,
          data: draftData,
        );
        propertyId = response.id;
      } else {
        // Call API to save draft for the first time
        final response = await _propertyApiService.saveDraft(data: draftData);
        propertyId = response['data']?['id'] as int?;
      }

      // Upload photos if any (Draft might have new local photos)
      final localImages = state.images
          .where((img) => img.isFile)
          .map((img) => img.file!)
          .toList();
      if (localImages.isNotEmpty && propertyId != null) {
        final roleName =
            DependencyInjection.authRepository.currentRole == UserRole.agency
            ? 'agency'
            : 'agent';
        await _propertyApiService.uploadPhotosProperty(
          role: roleName,
          propertyId: propertyId,
          photos: localImages,
          tag: 'gallery',
        );
      }

      if (propertyId != null) {
        await _setPropertyTypeDetails(state, propertyId);
      }

      emit(
        state.copyWith(
          propertyFormStatus: PropertyFormStatus.draftSaveSuccess,
          propertyId: propertyId,
          isDraft: true,
        ),
      );
    } catch (e) {
      debugPrint('Draft save error: $e');
      emit(
        state.copyWith(
          propertyFormStatus: PropertyFormStatus.draftSaveFailure,
          errorMessage: ApiResponseService.getErrorMessage(e),
        ),
      );
    }
  }

  /// Calls setCondoDetails or setHouseDetails when the property has condo/house detail data.
  Future<void> _setPropertyTypeDetails(
    PropertyFormState state,
    int propertyId,
  ) async {
    final type = state.selectedPropertyType;
    if (type == PropertyType.condo && state.selectedCondoProjectId != null) {
      await _propertyApiService.setCondoDetails(
        propertyId: propertyId,
        condoProjectId: state.selectedCondoProjectId!,
        tower: state.tower,
        floor: state.condoFloor,
        unitNo: state.unitNo,
      );
    } else if (type == PropertyType.house) {
      final hasHouseDetails =
          state.selectedHouseProjectId != null ||
          (state.villageName != null && state.villageName!.isNotEmpty) ||
          (state.moo != null && state.moo!.isNotEmpty) ||
          (state.houseSubtype != null && state.houseSubtype!.isNotEmpty) ||
          (state.parkingType != null && state.parkingType!.isNotEmpty) ||
          state.isCornerPlot != null ||
          (state.houseNotes != null && state.houseNotes!.isNotEmpty);
      if (hasHouseDetails) {
        await _propertyApiService.setHouseDetails(
          propertyId: propertyId,
          houseProjectId: state.selectedHouseProjectId,
          villageName: state.villageName,
          moo: state.moo,
          houseSubtype: state.houseSubtype,
          parkingType: state.parkingType,
          isCornerPlot: state.isCornerPlot,
          notes: state.houseNotes,
        );
      }
    }
  }

  void _onReset(PropertyFormReset event, Emitter<PropertyFormState> emit) {
    emit(const PropertyFormState());
  }

  Future<void> _onDevelopersFetched(
    PropertyFormDevelopersFetched event,
    Emitter<PropertyFormState> emit,
  ) async {
    if (state.developers.isNotEmpty && !event.refresh) return;
    emit(state.copyWith(isFetchingDevelopers: true));
    try {
      final developers = await _propertyApiService.getDevelopers();
      emit(state.copyWith(developers: developers, isFetchingDevelopers: false));
    } catch (e) {
      emit(state.copyWith(isFetchingDevelopers: false));
    }
  }

  /// Loads condo projects for the given developer (null = all).
  /// Uses cache; only calls API on cache miss.
  Future<List<CondoProject>> _loadCondoProjectsForDeveloper(
    int? developerId, {
    bool refresh = false,
  }) async {
    if (!refresh && _projectsByDeveloper.containsKey(developerId)) {
      return _projectsByDeveloper[developerId]!;
    }
    try {
      final projects = await _propertyApiService.getCondoProjects(
        developerId: developerId,
      );
      _projectsByDeveloper[developerId] = projects;
      return projects;
    } catch (e) {
      debugPrint('PropertyFormBloc getCondoProjects error: $e');
      // If refresh failed, maybe we should keep old data?
      // For now, clear it as per original logic, or we could just return empty.
      _projectsByDeveloper[developerId] = const [];
      return const [];
    }
  }

  Future<void> _onCondoProjectsFetched(
    PropertyFormCondoProjectsFetched event,
    Emitter<PropertyFormState> emit,
  ) async {
    emit(state.copyWith(isFetchingProjects: true));
    final projects = await _loadCondoProjectsForDeveloper(
      event.developerId,
      refresh: event.refresh,
    );
    emit(state.copyWith(condoProjects: projects, isFetchingProjects: false));
  }

  Future<void> _onDeveloperChanged(
    PropertyFormDeveloperChanged event,
    Emitter<PropertyFormState> emit,
  ) async {
    final developerChanged = event.developerId != state.selectedDeveloperId;
    emit(
      state.copyWith(
        selectedDeveloperId: event.developerId,
        selectedCondoProjectId: developerChanged
            ? null
            : state.selectedCondoProjectId,
        selectedHouseProjectId: developerChanged
            ? null
            : state.selectedHouseProjectId,
        condoProjects: developerChanged ? [] : state.condoProjects,
        houseProjects: developerChanged ? [] : state.houseProjects,
        isFetchingProjects: true,
      ),
    );
    final projects = await _loadCondoProjectsForDeveloper(event.developerId);
    // Also load house projects
    final houseProjects = await _loadHouseProjectsForDeveloper(
      event.developerId,
    );
    emit(
      state.copyWith(
        condoProjects: projects,
        houseProjects: houseProjects,
        isFetchingProjects: false,
      ),
    );
  }

  Future<void> _onCondoProjectChanged(
    PropertyFormCondoProjectChanged event,
    Emitter<PropertyFormState> emit,
  ) async {
    int? devId = state.selectedDeveloperId;
    if (event.projectId != null) {
      try {
        final project = state.condoProjects.firstWhere(
          (p) => p.id == event.projectId,
        );
        devId = project.developerId;
      } catch (_) {}
    }
    final developerChanged = devId != state.selectedDeveloperId;
    emit(
      state.copyWith(
        selectedCondoProjectId: event.projectId,
        selectedDeveloperId: devId ?? state.selectedDeveloperId,
      ),
    );
    // Keep condoProjects in sync when project's developer differs from current
    if (developerChanged && devId != null) {
      final projects = await _loadCondoProjectsForDeveloper(devId);
      emit(state.copyWith(condoProjects: projects));
    }
  }

  /// Loads house projects for the given developer (null = all).
  Future<List<HouseProject>> _loadHouseProjectsForDeveloper(
    int? developerId, {
    bool refresh = false,
  }) async {
    if (!refresh && _houseProjectsByDeveloper.containsKey(developerId)) {
      return _houseProjectsByDeveloper[developerId]!;
    }
    try {
      final projects = await _propertyApiService.getHouseProjects(
        developerId: developerId,
      );
      _houseProjectsByDeveloper[developerId] = projects;
      return projects;
    } catch (e) {
      debugPrint('PropertyFormBloc getHouseProjects error: $e');
      _houseProjectsByDeveloper[developerId] = const [];
      return const [];
    }
  }

  Future<void> _onHouseProjectsFetched(
    PropertyFormHouseProjectsFetched event,
    Emitter<PropertyFormState> emit,
  ) async {
    emit(state.copyWith(isFetchingProjects: true));
    final projects = await _loadHouseProjectsForDeveloper(
      event.developerId,
      refresh: event.refresh,
    );
    emit(state.copyWith(houseProjects: projects, isFetchingProjects: false));
  }

  Future<void> _onHouseProjectChanged(
    PropertyFormHouseProjectChanged event,
    Emitter<PropertyFormState> emit,
  ) async {
    int? devId = state.selectedDeveloperId;
    if (event.projectId != null) {
      try {
        final project = state.houseProjects.firstWhere(
          (p) => p.id == event.projectId,
        );
        devId = project.developerId;
      } catch (_) {}
    }
    final developerChanged = devId != state.selectedDeveloperId;
    emit(
      state.copyWith(
        selectedHouseProjectId: event.projectId,
        selectedDeveloperId: devId ?? state.selectedDeveloperId,
      ),
    );

    if (developerChanged && devId != null) {
      final projects = await _loadHouseProjectsForDeveloper(devId);
      emit(state.copyWith(houseProjects: projects));
    }
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
    final newSpecs = Map<String, String>.from(state.specifications);
    newSpecs[event.key] = event.value;

    PropertyFormState newState = state.copyWith(specifications: newSpecs);

    switch (event.key) {
      case 'floors':
      case 'total_floors':
        final cleanVal = event.value.replaceAll(RegExp(r'[^0-9]'), '');
        final intValue = int.tryParse(cleanVal);
        newSpecs['floors'] = event.value;
        newSpecs['total_floors'] = event.value;
        newState = newState.copyWith(
          totalFloors: intValue,
          specifications: newSpecs,
        );
        break;
      case 'bedrooms':
        if (event.value == 'Studio') {
          newState = newState.copyWith(bedrooms: 1);
        } else {
          final cleanVal = event.value.replaceAll(RegExp(r'[^0-9]'), '');
          newState = newState.copyWith(bedrooms: int.tryParse(cleanVal));
        }
        break;
      case 'bathrooms':
        final cleanVal = event.value.replaceAll(RegExp(r'[^0-9]'), '');
        newState = newState.copyWith(bathrooms: int.tryParse(cleanVal));
        break;
      case 'garage':
      case 'parking_spaces':
        final cleanVal = event.value.replaceAll(RegExp(r'[^0-9]'), '');
        final intValue = int.tryParse(cleanVal);
        newSpecs['garage'] = event.value;
        newSpecs['parking_spaces'] = event.value;
        newState = newState.copyWith(
          garage: intValue,
          specifications: newSpecs,
        );
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
    final newSpecValues = Map<String, List<String>>.from(
      state.specificationValues,
    );
    final currentList = newSpecValues[event.key] ?? [];
    final newList = List<String>.from(currentList);

    if (newList.contains(event.value)) {
      newList.remove(event.value);
    } else {
      newList.add(event.value);
    }
    newSpecValues[event.key] = newList;
    emit(state.copyWith(specificationValues: newSpecValues));
  }
}
