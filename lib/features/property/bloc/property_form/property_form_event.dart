import 'package:equatable/equatable.dart';
import 'package:youragent/domain/entities/property.dart';
import 'property_form_state.dart';

abstract class PropertyFormEvent extends Equatable {
  const PropertyFormEvent();

  @override
  List<Object?> get props => [];
}

class PropertyFormStepChanged extends PropertyFormEvent {
  final int step;
  const PropertyFormStepChanged(this.step);

  @override
  List<Object?> get props => [step];
}

class PropertyFormTypeSelected extends PropertyFormEvent {
  final PropertyType type;
  const PropertyFormTypeSelected(this.type);

  @override
  List<Object?> get props => [type];
}

class PropertyFormGeneralInfoUpdated extends PropertyFormEvent {
  final String? name;
  final double? price;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;

  const PropertyFormGeneralInfoUpdated({
    this.name,
    this.price,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
    name,
    price,
    description,
    address,
    latitude,
    longitude,
  ];
}

class PropertyFormDataUpdated extends PropertyFormEvent {
  final String key;
  final dynamic value;
  const PropertyFormDataUpdated({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}

class PropertyFormLocationUpdated extends PropertyFormEvent {
  final Map<String, dynamic> locationData;
  const PropertyFormLocationUpdated(this.locationData);

  @override
  List<Object?> get props => [locationData];
}

/// Update a single granular location field (road, soi, subdistrict, etc.)
/// without touching latitude/longitude or other fields.
class PropertyFormLocationFieldUpdated extends PropertyFormEvent {
  final String key;
  final String? value;

  const PropertyFormLocationFieldUpdated({
    required this.key,
    required this.value,
  });

  @override
  List<Object?> get props => [key, value];
}

class PropertyFormDetailsUpdated extends PropertyFormEvent {
  final int? bedrooms;
  final int? bathrooms;
  final int? garage;
  final double? landSize;
  final double? buildingSize;
  final PropertyColor? houseColor;
  final int? totalFloors;

  const PropertyFormDetailsUpdated({
    this.bedrooms,
    this.bathrooms,
    this.garage,
    this.landSize,
    this.buildingSize,
    this.houseColor,
    this.totalFloors,
  });

  @override
  List<Object?> get props => [
    bedrooms,
    bathrooms,
    garage,
    landSize,
    buildingSize,
    houseColor,
    totalFloors,
  ];
}

class PropertyFormAdditionalInfoUpdated extends PropertyFormEvent {
  final DateTime? built;
  final PropertyDirection? direction;
  final DateTime? availableFrom;

  const PropertyFormAdditionalInfoUpdated({
    this.built,
    this.direction,
    this.availableFrom,
  });

  @override
  List<Object?> get props => [built, direction, availableFrom];
}

class PropertyFormImagesUpdated extends PropertyFormEvent {
  final List<PropertyFormImage> images;
  const PropertyFormImagesUpdated(this.images);

  @override
  List<Object?> get props => [images];
}

class PropertyFormImageDeleted extends PropertyFormEvent {
  final int index;
  const PropertyFormImageDeleted(this.index);

  @override
  List<Object?> get props => [index];
}

class PropertyFormAllImagesDeleted extends PropertyFormEvent {
  const PropertyFormAllImagesDeleted();
}

class PropertyFormSubmitted extends PropertyFormEvent {
  const PropertyFormSubmitted();
}

class PropertyFormReset extends PropertyFormEvent {
  const PropertyFormReset();
}

class PropertyFormDevelopersFetched extends PropertyFormEvent {
  final bool refresh;
  const PropertyFormDevelopersFetched({this.refresh = false});
}

class PropertyFormCondoProjectsFetched extends PropertyFormEvent {
  final int? developerId;
  const PropertyFormCondoProjectsFetched({this.developerId});

  @override
  List<Object?> get props => [developerId];
}

class PropertyFormDeveloperChanged extends PropertyFormEvent {
  final int? developerId;
  const PropertyFormDeveloperChanged(this.developerId);

  @override
  List<Object?> get props => [developerId];
}

class PropertyFormCondoProjectChanged extends PropertyFormEvent {
  final int? projectId;
  const PropertyFormCondoProjectChanged(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class PropertyFormHouseProjectChanged extends PropertyFormEvent {
  final int? projectId;
  const PropertyFormHouseProjectChanged(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class PropertyFormHouseProjectsFetched extends PropertyFormEvent {
  final int? developerId;
  const PropertyFormHouseProjectsFetched({this.developerId});

  @override
  List<Object?> get props => [developerId];
}

class PropertyFormListingTypeChanged extends PropertyFormEvent {
  final PropertyListingType listingType;
  const PropertyFormListingTypeChanged(this.listingType);

  @override
  List<Object?> get props => [listingType];
}

class PropertyFormStatusChanged extends PropertyFormEvent {
  final PropertyAvailabilityStatus status;
  const PropertyFormStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class PropertyFormStyleChanged extends PropertyFormEvent {
  final StyleProperty? style;
  const PropertyFormStyleChanged(this.style);

  @override
  List<Object?> get props => [style];
}

class PropertyFormHighlightToggled extends PropertyFormEvent {
  final String highlight;
  const PropertyFormHighlightToggled(this.highlight);

  @override
  List<Object?> get props => [highlight];
}

class PropertyFormFacilityToggled extends PropertyFormEvent {
  final String facility;
  const PropertyFormFacilityToggled(this.facility);

  @override
  List<Object?> get props => [facility];
}

class PropertyFormFiltersFetched extends PropertyFormEvent {
  const PropertyFormFiltersFetched();

  @override
  List<Object?> get props => [];
}

class PropertyFormDynamicSingleSelectChanged extends PropertyFormEvent {
  final String key;
  final String value;
  const PropertyFormDynamicSingleSelectChanged(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

class PropertyFormDynamicMultiSelectToggled extends PropertyFormEvent {
  final String key;
  final String value;
  const PropertyFormDynamicMultiSelectToggled(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

class PropertyFormResetStatus extends PropertyFormEvent {
  const PropertyFormResetStatus();

  @override
  List<Object?> get props => [];
}

/// Event to save current form data as draft
class PropertyFormDraftSaved extends PropertyFormEvent {
  const PropertyFormDraftSaved();

  @override
  List<Object?> get props => [];
}

class PropertyFormValidateRequested extends PropertyFormEvent {
  const PropertyFormValidateRequested();

  @override
  List<Object?> get props => [];
}
