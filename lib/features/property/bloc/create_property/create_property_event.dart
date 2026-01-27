import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

abstract class CreatePropertyEvent extends Equatable {
  const CreatePropertyEvent();

  @override
  List<Object?> get props => [];
}

class CreatePropertyStepChanged extends CreatePropertyEvent {
  final int step;
  const CreatePropertyStepChanged(this.step);

  @override
  List<Object?> get props => [step];
}

class CreatePropertyTypeSelected extends CreatePropertyEvent {
  final String type;
  const CreatePropertyTypeSelected(this.type);

  @override
  List<Object?> get props => [type];
}

class CreatePropertyGeneralInfoUpdated extends CreatePropertyEvent {
  final String? name;
  final double? price;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;

  const CreatePropertyGeneralInfoUpdated({
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

class CreatePropertyDataUpdated extends CreatePropertyEvent {
  final String key;
  final dynamic value;
  const CreatePropertyDataUpdated({required this.key, required this.value});

  @override
  List<Object?> get props => [key, value];
}

class CreatePropertyLocationUpdated extends CreatePropertyEvent {
  final Map<String, dynamic> locationData;
  const CreatePropertyLocationUpdated(this.locationData);

  @override
  List<Object?> get props => [locationData];
}

/// Update a single granular location field (road, soi, subdistrict, etc.)
/// without touching latitude/longitude or other fields.
class CreatePropertyLocationFieldUpdated extends CreatePropertyEvent {
  final String key;
  final String? value;

  const CreatePropertyLocationFieldUpdated({
    required this.key,
    required this.value,
  });

  @override
  List<Object?> get props => [key, value];
}

class CreatePropertyDetailsUpdated extends CreatePropertyEvent {
  final int? bedrooms;
  final int? bathrooms;
  final int? garage;
  final double? landSize;
  final double? buildingSize;
  final String? houseColor;

  const CreatePropertyDetailsUpdated({
    this.bedrooms,
    this.bathrooms,
    this.garage,
    this.landSize,
    this.buildingSize,
    this.houseColor,
  });

  @override
  List<Object?> get props => [
    bedrooms,
    bathrooms,
    garage,
    landSize,
    buildingSize,
    houseColor,
  ];
}

class CreatePropertyAdditionalInfoUpdated extends CreatePropertyEvent {
  final String? built;
  final String? direction;
  final String? availableFrom;

  const CreatePropertyAdditionalInfoUpdated({
    this.built,
    this.direction,
    this.availableFrom,
  });

  @override
  List<Object?> get props => [built, direction, availableFrom];
}

class CreatePropertyImagesUpdated extends CreatePropertyEvent {
  final List<XFile> images;
  const CreatePropertyImagesUpdated(this.images);

  @override
  List<Object?> get props => [images];
}

class CreatePropertySubmitted extends CreatePropertyEvent {
  const CreatePropertySubmitted();
}

class CreatePropertyReset extends CreatePropertyEvent {
  const CreatePropertyReset();
}
