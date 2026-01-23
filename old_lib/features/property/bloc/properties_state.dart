part of 'properties_bloc.dart';

sealed class PropertiesState extends Equatable {
  const PropertiesState();

  @override
  List<Object?> get props => [];
}

final class PropertiesLoading extends PropertiesState {
  const PropertiesLoading();
}

final class PropertiesLoaded extends PropertiesState {
  final List<PropertyModel> allProperties;
  final List<PropertyModel> filteredProperties;
  final String? searchQuery;
  final String? selectedStatus;
  final String? selectedPropertyType;
  final String? selectedOwnership;
  final String? selectedProvince;
  final int currentPage;
  final int itemsPerPage;

  const PropertiesLoaded({
    required this.allProperties,
    required this.filteredProperties,
    this.searchQuery,
    this.selectedStatus,
    this.selectedPropertyType,
    this.selectedOwnership,
    this.selectedProvince,
    this.currentPage = 1,
    this.itemsPerPage = 10,
  });

  List<PropertyModel> get paginatedProperties {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    if (startIndex >= filteredProperties.length) return [];

    return filteredProperties.sublist(
      startIndex,
      endIndex > filteredProperties.length ? filteredProperties.length : endIndex,
    );
  }

  int get totalPages => (filteredProperties.length / itemsPerPage).ceil();

  @override
  List<Object?> get props => [
    allProperties,
    filteredProperties,
    searchQuery,
    selectedStatus,
    selectedPropertyType,
    selectedOwnership,
    selectedProvince,
    currentPage,
    itemsPerPage,
  ];

  PropertiesLoaded copyWith({
    List<PropertyModel>? allProperties,
    List<PropertyModel>? filteredProperties,
    String? searchQuery,
    String? selectedStatus,
    String? selectedPropertyType,
    String? selectedOwnership,
    String? selectedProvince,
    int? currentPage,
    int? itemsPerPage,
  }) {
    return PropertiesLoaded(
      allProperties: allProperties ?? this.allProperties,
      filteredProperties: filteredProperties ?? this.filteredProperties,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedPropertyType: selectedPropertyType ?? this.selectedPropertyType,
      selectedOwnership: selectedOwnership ?? this.selectedOwnership,
      selectedProvince: selectedProvince ?? this.selectedProvince,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }
}

final class PropertiesError extends PropertiesState {
  final String message;
  const PropertiesError(this.message);

  @override
  List<Object?> get props => [message];
}

final class PropertiesDeleteSuccess extends PropertiesState {
  final String message;
  const PropertiesDeleteSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
