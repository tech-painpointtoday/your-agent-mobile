import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/data/models/property_model.dart';
import 'package:youragent/services/property_api_service.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/domain/entities/user.dart';
import 'property_detail_event.dart';
import 'property_detail_state.dart';

/// BLoC for handling property detail flow
class PropertyDetailBloc
    extends Bloc<PropertyDetailEvent, PropertyDetailState> {
  final PropertyApiService _propertyApiService;

  PropertyDetailBloc({required PropertyApiService propertyApiService})
    : _propertyApiService = propertyApiService,
      super(PropertyDetailInitial()) {
    on<PropertyDetailLoad>(_onLoad);
    on<PropertyDetailDelete>(_onDelete);
    on<PropertyDetailReset>(_onReset);
  }

  Future<void> _onLoad(
    PropertyDetailLoad event,
    Emitter<PropertyDetailState> emit,
  ) async {
    emit(PropertyDetailLoading());

    try {
      final role = DependencyInjection.authRepository.currentRole;
      final property = await _propertyApiService.getPropertyStatus(
        role: (role ?? UserRole.agent).name,
        propertyId: event.propertyId,
      );

      emit(PropertyDetailLoaded(property: property));
    } catch (e) {
      emit(PropertyDetailFailure(e.toString()));
    }
  }

  Future<void> _onDelete(
    PropertyDetailDelete event,
    Emitter<PropertyDetailState> emit,
  ) async {
    // Get current property from state if available
    final currentState = state;
    PropertyModel? currentProperty;
    if (currentState is PropertyDetailLoaded) {
      currentProperty = currentState.property;
    } else if (currentState is PropertyDetailDeleting) {
      currentProperty = currentState.property;
    }

    // Emit deleting state if we have a property
    if (currentProperty != null) {
      emit(PropertyDetailDeleting(property: currentProperty));
    }

    try {
      final role =
          DependencyInjection.authRepository.currentRole ?? UserRole.agent;
      await _propertyApiService.deleteProperty(
        role: role.name,
        propertyId: event.propertyId,
      );

      emit(PropertyDetailDeleted());
    } catch (e) {
      emit(PropertyDetailFailure(e.toString()));
    }
  }

  void _onReset(PropertyDetailReset event, Emitter<PropertyDetailState> emit) {
    emit(PropertyDetailInitial());
  }
}
