import 'package:equatable/equatable.dart';
import '../../../../domain/entities/property.dart';

enum PropertyListStatus { initial, success, failure }

class PropertyListState extends Equatable {
  final PropertyListStatus status;
  final List<Property> properties;
  final bool hasReachedMax;
  final int currentPage;
  final int totalCount;
  final String? errorMessage;

  const PropertyListState({
    this.status = PropertyListStatus.initial,
    this.properties = const <Property>[],
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.totalCount = 0,
    this.errorMessage,
  });

  PropertyListState copyWith({
    PropertyListStatus? status,
    List<Property>? properties,
    bool? hasReachedMax,
    int? currentPage,
    int? totalCount,
    String? errorMessage,
  }) {
    return PropertyListState(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    properties,
    hasReachedMax,
    currentPage,
    totalCount,
    errorMessage,
  ];
}
