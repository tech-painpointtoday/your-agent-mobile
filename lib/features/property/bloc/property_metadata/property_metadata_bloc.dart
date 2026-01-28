import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/services/property_api_service.dart';
import 'property_metadata_event.dart';
import 'property_metadata_state.dart';

class PropertyMetadataBloc
    extends Bloc<PropertyMetadataEvent, PropertyMetadataState> {
  final PropertyApiService _propertyApiService;

  PropertyMetadataBloc({required PropertyApiService propertyApiService})
    : _propertyApiService = propertyApiService,
      super(const PropertyMetadataState()) {
    on<LoadPropertyMetadata>(_onLoadPropertyMetadata);
  }

  Future<void> _onLoadPropertyMetadata(
    LoadPropertyMetadata event,
    Emitter<PropertyMetadataState> emit,
  ) async {
    // Don't reload if already successful or loading
    if (state.status == PropertyMetadataStatus.success ||
        state.status == PropertyMetadataStatus.loading) {
      return;
    }

    emit(state.copyWith(status: PropertyMetadataStatus.loading));

    try {
      final filters = await _propertyApiService.getSpecificationFilters();
      emit(
        state.copyWith(
          status: PropertyMetadataStatus.success,
          specificationFilters: filters,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PropertyMetadataStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }
}
