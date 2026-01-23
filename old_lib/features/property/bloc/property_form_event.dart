import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:youragent/data/models/property_model.dart';
import 'package:youragent/data/models/developer_model.dart';
import 'package:youragent/data/models/condo_project_model.dart';
import 'package:youragent/domain/entities/property_enums.dart';

/// Events for Property Form BLoC
abstract class PropertyFormEvent extends Equatable {
  const PropertyFormEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize form with property data (for edit mode)
class PropertyFormInitialized extends PropertyFormEvent {
  final PropertyModel? property;

  const PropertyFormInitialized({this.property});

  @override
  List<Object?> get props => [property];
}

/// Update form field value
class PropertyFormFieldUpdated extends PropertyFormEvent {
  final String field;
  final dynamic value;

  const PropertyFormFieldUpdated({required this.field, required this.value});

  @override
  List<Object?> get props => [field, value];
}

/// Update selected type
class PropertyFormTypeChanged extends PropertyFormEvent {
  final PropertyType? type;

  const PropertyFormTypeChanged(this.type);

  @override
  List<Object?> get props => [type];
}

/// Update selected status
class PropertyFormStatusChanged extends PropertyFormEvent {
  final PropertyStatus? status;

  const PropertyFormStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

/// Update selected sale type
class PropertyFormSaleTypeChanged extends PropertyFormEvent {
  final SaleType? saleType;

  const PropertyFormSaleTypeChanged(this.saleType);

  @override
  List<Object?> get props => [saleType];
}

/// Update selected property style
class PropertyFormStyleChanged extends PropertyFormEvent {
  final PropertyStyle? style;

  const PropertyFormStyleChanged(this.style);

  @override
  List<Object?> get props => [style];
}

/// Update selected property color
class PropertyFormColorChanged extends PropertyFormEvent {
  final PropertyColor? color;

  const PropertyFormColorChanged(this.color);

  @override
  List<Object?> get props => [color];
}

/// Update selected direction
class PropertyFormDirectionChanged extends PropertyFormEvent {
  final Direction? direction;

  const PropertyFormDirectionChanged(this.direction);

  @override
  List<Object?> get props => [direction];
}

/// Update selected country
class PropertyFormCountryChanged extends PropertyFormEvent {
  final Country? country;

  const PropertyFormCountryChanged(this.country);

  @override
  List<Object?> get props => [country];
}

/// Update built date
class PropertyFormBuiltDateChanged extends PropertyFormEvent {
  final DateTime? date;

  const PropertyFormBuiltDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

/// Update available from date
class PropertyFormAvailableFromDateChanged extends PropertyFormEvent {
  final DateTime? date;

  const PropertyFormAvailableFromDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

/// Update selected highlights
class PropertyFormHighlightsChanged extends PropertyFormEvent {
  final List<String> highlights;

  const PropertyFormHighlightsChanged(this.highlights);

  @override
  List<Object?> get props => [highlights];
}

/// Update selected common areas
class PropertyFormCommonAreasChanged extends PropertyFormEvent {
  final List<String> commonAreas;

  const PropertyFormCommonAreasChanged(this.commonAreas);

  @override
  List<Object?> get props => [commonAreas];
}

/// Update selected furniture
class PropertyFormFurnitureChanged extends PropertyFormEvent {
  final List<String> furniture;

  const PropertyFormFurnitureChanged(this.furniture);

  @override
  List<Object?> get props => [furniture];
}

/// Update selected air conditioning
class PropertyFormAirConditioningChanged extends PropertyFormEvent {
  final List<String> airConditioning;

  const PropertyFormAirConditioningChanged(this.airConditioning);

  @override
  List<Object?> get props => [airConditioning];
}

/// Update location
class PropertyFormLocationChanged extends PropertyFormEvent {
  final LatLng? location;

  const PropertyFormLocationChanged(this.location);

  @override
  List<Object?> get props => [location];
}

/// Update address from reverse geocoding
class PropertyFormAddressUpdated extends PropertyFormEvent {
  final String address;
  final String? district;
  final String? subdistrict;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? houseNumber;
  final String? soi;
  final String? road;

  const PropertyFormAddressUpdated({
    required this.address,
    this.district,
    this.subdistrict,
    this.state,
    this.country,
    this.postalCode,
    this.houseNumber,
    this.soi,
    this.road,
  });

  @override
  List<Object?> get props => [
    address,
    district,
    subdistrict,
    state,
    country,
    postalCode,
    houseNumber,
    soi,
    road,
  ];
}

/// Add new photo
class PropertyFormPhotoAdded extends PropertyFormEvent {
  final XFile photo;

  const PropertyFormPhotoAdded(this.photo);

  @override
  List<Object?> get props => [photo];
}

/// Remove new photo
class PropertyFormPhotoRemoved extends PropertyFormEvent {
  final int index;

  const PropertyFormPhotoRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

/// Remove existing photo
class PropertyFormExistingPhotoRemoved extends PropertyFormEvent {
  final int index;

  const PropertyFormExistingPhotoRemoved(this.index);

  @override
  List<Object?> get props => [index];
}

/// Load filter options
class PropertyFormFilterOptionsLoadRequested extends PropertyFormEvent {}

/// Filter options loaded
class PropertyFormFilterOptionsLoaded extends PropertyFormEvent {
  final Map<String, List<String>> options;

  const PropertyFormFilterOptionsLoaded(this.options);

  @override
  List<Object?> get props => [options];
}

/// Reset form
class PropertyFormReset extends PropertyFormEvent {}

/// Load master data (developers, condo projects)
class PropertyFormLoadMasterData extends PropertyFormEvent {
  const PropertyFormLoadMasterData();

  @override
  List<Object?> get props => [];
}

/// Update selected developer
class PropertyFormDeveloperChanged extends PropertyFormEvent {
  final Developer? developer;

  const PropertyFormDeveloperChanged(this.developer);

  @override
  List<Object?> get props => [developer];
}

/// Update condo project selection
class PropertyFormCondoProjectChanged extends PropertyFormEvent {
  final CondoProject? project;

  const PropertyFormCondoProjectChanged(this.project);

  @override
  List<Object?> get props => [project];
}

/// Update condo field
class PropertyFormCondoFieldUpdated extends PropertyFormEvent {
  final String field;
  final dynamic value;

  const PropertyFormCondoFieldUpdated({
    required this.field,
    required this.value,
  });

  @override
  List<Object?> get props => [field, value];
}

/// Update house field
class PropertyFormHouseFieldUpdated extends PropertyFormEvent {
  final String field;
  final dynamic value;

  const PropertyFormHouseFieldUpdated({
    required this.field,
    required this.value,
  });

  @override
  List<Object?> get props => [field, value];
}
