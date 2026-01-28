import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/services/property_api_service.dart';
import 'package:youragent/data/models/developer_model.dart';
import 'package:youragent/data/models/condo_project_model.dart';
import 'package:youragent/data/models/property_specification_filters.dart';
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
      final results = await Future.wait([
        _propertyApiService.getSpecificationFilters(),
        _propertyApiService.getDevelopers(),
        // Fetch generic condo projects list (assuming backend returns reasonable default)
        _propertyApiService.getCondoProjects(),
      ]);

      final filters = results[0] as PropertySpecificationFilters;
      final developers = results[1] as List<Developer>;
      final condoProjects = results[2] as List<CondoProject>;

      emit(
        state.copyWith(
          status: PropertyMetadataStatus.success,
          specificationFilters: filters,
          developers: developers,
          condoProjects: condoProjects,
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
