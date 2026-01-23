import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/data/models/property_model.dart';
import 'package:youragent/services/property_api_service.dart';
import 'package:youragent/services/role_service.dart';

part 'properties_event.dart';
part 'properties_state.dart';

class PropertiesBloc extends Bloc<PropertiesEvent, PropertiesState> {
  final PropertyApiService _propertyApiService;

  PropertiesBloc(this._propertyApiService) : super(const PropertiesLoading()) {
    on<PropertiesLoadRequested>(_onLoad);
    on<PropertiesFilterChanged>(_onFilterChanged);
    on<PropertiesPageChanged>(_onPageChanged);
    on<PropertiesItemsPerPageChanged>(_onItemsPerPageChanged);
    on<PropertiesDeleteRequested>(_onDelete);
  }

  Future<void> _onLoad(PropertiesLoadRequested event, Emitter<PropertiesState> emit) async {
    emit(const PropertiesLoading());
    try {
      final roleService = RoleService();
      final role = roleService.currentRole;
      if (role == null) {
        emit(const PropertiesError('No role specified'));
        return;
      }
      // Use real API call - convert UserRole to string
      final items = await _propertyApiService.getProperties(role: role.name);
      final filtered = _applyFilters(items, null, null, null, null, null);
      emit(PropertiesLoaded(allProperties: items, filteredProperties: filtered));
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }

  Future<void> _onDelete(PropertiesDeleteRequested event, Emitter<PropertiesState> emit) async {
    try {
      final roleService = RoleService();
      final role = roleService.currentRole;
      if (role == null) {
        emit(const PropertiesError('No role specified'));
        return;
      }

      await _propertyApiService.deleteProperty(role: role.name, propertyId: event.propertyId);
      emit(const PropertiesDeleteSuccess('ลบอสังหาริมทรัพย์สำเร็จ'));
    } catch (e) {
      emit(PropertiesError(e.toString()));
    }
  }

  void _onFilterChanged(PropertiesFilterChanged event, Emitter<PropertiesState> emit) {
    if (state is! PropertiesLoaded) return;
    final currentState = state as PropertiesLoaded;

    // Logic preserves existing values if null is passed (behavior from original code)
    final searchQuery = event.searchQuery ?? currentState.searchQuery;
    final selectedStatus = event.selectedStatus ?? currentState.selectedStatus;
    final selectedPropertyType = event.selectedPropertyType ?? currentState.selectedPropertyType;
    final selectedOwnership = event.selectedOwnership ?? currentState.selectedOwnership;
    final selectedProvince = event.selectedProvince ?? currentState.selectedProvince;

    final filtered = _applyFilters(
      currentState.allProperties,
      searchQuery,
      selectedStatus,
      selectedPropertyType,
      selectedOwnership,
      selectedProvince,
    );

    emit(
      currentState.copyWith(
        filteredProperties: filtered,
        searchQuery: searchQuery,
        selectedStatus: selectedStatus,
        selectedPropertyType: selectedPropertyType,
        selectedOwnership: selectedOwnership,
        selectedProvince: selectedProvince,
        currentPage: 1, // Reset to first page
      ),
    );
  }

  void _onPageChanged(PropertiesPageChanged event, Emitter<PropertiesState> emit) {
    if (state is! PropertiesLoaded) return;
    final currentState = state as PropertiesLoaded;
    emit(currentState.copyWith(currentPage: event.page));
  }

  void _onItemsPerPageChanged(PropertiesItemsPerPageChanged event, Emitter<PropertiesState> emit) {
    if (state is! PropertiesLoaded) return;
    final currentState = state as PropertiesLoaded;
    emit(currentState.copyWith(itemsPerPage: event.itemsPerPage, currentPage: 1));
  }

  List<PropertyModel> _applyFilters(
    List<PropertyModel> properties,
    String? searchQuery,
    String? selectedStatus,
    String? selectedPropertyType,
    String? selectedOwnership,
    String? selectedProvince,
  ) {
    return properties.where((property) {
      // Search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        if (!property.name.toLowerCase().contains(searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Status filter
      if (selectedStatus != null && selectedStatus.isNotEmpty) {
        if (property.status != selectedStatus) {
          return false;
        }
      }

      // Property type filter
      if (selectedPropertyType != null && selectedPropertyType.isNotEmpty) {
        if (property.propertyType != selectedPropertyType) {
          return false;
        }
      }

      // Ownership filter
      if (selectedOwnership != null && selectedOwnership.isNotEmpty) {
        // TODO: Add ownership field to PropertyModel if needed
        // Currently ignored as field might be missing
      }

      // Province filter
      if (selectedProvince != null && selectedProvince.isNotEmpty) {
        if (property.propertyLocation?.state != selectedProvince) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
