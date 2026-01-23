part of 'properties_bloc.dart';

sealed class PropertiesEvent extends Equatable {
  const PropertiesEvent();

  @override
  List<Object?> get props => [];
}

final class PropertiesLoadRequested extends PropertiesEvent {
  const PropertiesLoadRequested();
}

final class PropertiesFilterChanged extends PropertiesEvent {
  final String? searchQuery;
  final String? selectedStatus;
  final String? selectedPropertyType;
  final String? selectedOwnership;
  final String? selectedProvince;

  const PropertiesFilterChanged({
    this.searchQuery,
    this.selectedStatus,
    this.selectedPropertyType,
    this.selectedOwnership,
    this.selectedProvince,
  });

  @override
  List<Object?> get props => [searchQuery, selectedStatus, selectedPropertyType, selectedOwnership, selectedProvince];
}

final class PropertiesPageChanged extends PropertiesEvent {
  final int page;
  const PropertiesPageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

final class PropertiesItemsPerPageChanged extends PropertiesEvent {
  final int itemsPerPage;
  const PropertiesItemsPerPageChanged(this.itemsPerPage);

  @override
  List<Object?> get props => [itemsPerPage];
}

final class PropertiesDeleteRequested extends PropertiesEvent {
  final int propertyId;
  const PropertiesDeleteRequested(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}
