import 'package:equatable/equatable.dart';
import 'property.dart';
import 'pagination.dart';

class PropertyResults extends Equatable {
  final List<Property> properties;
  final Pagination pagination;

  const PropertyResults({required this.properties, required this.pagination});

  @override
  List<Object?> get props => [properties, pagination];
}
