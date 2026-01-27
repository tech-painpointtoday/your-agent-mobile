import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/property_api_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../domain/entities/user.dart';
import 'create_property_event.dart';
import 'create_property_state.dart';

export 'create_property_event.dart';
export 'create_property_state.dart';

class CreatePropertyBloc
    extends Bloc<CreatePropertyEvent, CreatePropertyState> {
  final PropertyApiService _propertyApiService;

  CreatePropertyBloc({PropertyApiService? propertyApiService})
    : _propertyApiService =
          propertyApiService ?? DependencyInjection.propertyApiService,
      super(const CreatePropertyState()) {
    on<CreatePropertyStepChanged>(_onStepChanged);
    on<CreatePropertyTypeSelected>(_onTypeSelected);
    on<CreatePropertyGeneralInfoUpdated>(_onGeneralInfoUpdated);
    on<CreatePropertyDataUpdated>(_onDataUpdated);
    on<CreatePropertyLocationUpdated>(_onLocationUpdated);
    on<CreatePropertyLocationFieldUpdated>(_onLocationFieldUpdated);
    on<CreatePropertyDetailsUpdated>(_onDetailsUpdated);
    on<CreatePropertyAdditionalInfoUpdated>(_onAdditionalInfoUpdated);
    on<CreatePropertyImagesUpdated>(_onImagesUpdated);
    on<CreatePropertySubmitted>(_onSubmitted);
    on<CreatePropertyReset>(_onReset);
  }

  void _onStepChanged(
    CreatePropertyStepChanged event,
    Emitter<CreatePropertyState> emit,
  ) {
    emit(state.copyWith(step: event.step));
  }

  void _onTypeSelected(
    CreatePropertyTypeSelected event,
    Emitter<CreatePropertyState> emit,
  ) {
    emit(state.copyWith(selectedPropertyType: event.type));
  }

  void _onGeneralInfoUpdated(
    CreatePropertyGeneralInfoUpdated event,
    Emitter<CreatePropertyState> emit,
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
    CreatePropertyDataUpdated event,
    Emitter<CreatePropertyState> emit,
  ) {
    // This is a generic way to update any field in the state.
    // For simplicity, we'll map key to field here.
    switch (event.key) {
      case 'title':
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
    CreatePropertyLocationUpdated event,
    Emitter<CreatePropertyState> emit,
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
      ),
    );
  }

  void _onLocationFieldUpdated(
    CreatePropertyLocationFieldUpdated event,
    Emitter<CreatePropertyState> emit,
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
    CreatePropertyDetailsUpdated event,
    Emitter<CreatePropertyState> emit,
  ) {
    emit(
      state.copyWith(
        bedrooms: event.bedrooms,
        bathrooms: event.bathrooms,
        garage: event.garage,
        landSize: event.landSize,
        buildingSize: event.buildingSize,
        houseColor: event.houseColor,
      ),
    );
  }

  void _onAdditionalInfoUpdated(
    CreatePropertyAdditionalInfoUpdated event,
    Emitter<CreatePropertyState> emit,
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
    CreatePropertyImagesUpdated event,
    Emitter<CreatePropertyState> emit,
  ) {
    emit(state.copyWith(images: event.images));
  }

  Future<void> _onSubmitted(
    CreatePropertySubmitted event,
    Emitter<CreatePropertyState> emit,
  ) async {
    emit(state.copyWith(status: CreatePropertyStatus.submissionInProgress));

    try {
      final role =
          DependencyInjection.authRepository.currentRole ?? UserRole.agent;
      final roleName = role.name;

      final payload = <String, dynamic>{
        'built': state.built ?? '',
        'name': state.name,
        'type': state.selectedPropertyType,
        'status': 'pending',
        'bedrooms': state.bedrooms,
        'bathrooms': state.bathrooms,
        'garage': state.garage,
        'address': state.address,
        'price': state.price,
        'description': state.description,
        'land_size': state.landSize,
        'building_size': state.buildingSize,
        'available_from': state.availableFrom,
        'house_color': state.houseColor,
        'direction': state.direction,
        'latitude': state.latitude,
        'longitude': state.longitude,
        'number': state.number,
        'city': state.city,
        'state': state.state,
        'province': state.province ?? state.state,
        'postal_code': state.postalCode,
        'country': state.country,
        'subdistrict': state.subdistrict,
        'district': state.district,
        'road': state.road,
        'soi': state.soi,
        'formatted_address_en':
            state.formattedAddressEn ?? state.address ?? '',
      };

      final createResponse = await _propertyApiService.saveProperty(
        role: roleName,
        data: payload,
      );

      final propertyId = createResponse.id;
      final intPropertyId = int.tryParse(propertyId);

      if (intPropertyId == null) {
        throw Exception('Invalid property ID returned from server');
      }

      // Upload photos if any
      if (state.images.isNotEmpty) {
        await _propertyApiService.uploadPhotosSimple(
          role: roleName,
          propertyId: intPropertyId,
          photos: state.images,
          tag: 'gallery',
        );
      }

      emit(
        state.copyWith(
          status: CreatePropertyStatus.submissionSuccess,
          propertyId: propertyId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CreatePropertyStatus.submissionFailure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onReset(CreatePropertyReset event, Emitter<CreatePropertyState> emit) {
    emit(const CreatePropertyState());
  }
}
