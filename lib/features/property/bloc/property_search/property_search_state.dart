import 'package:equatable/equatable.dart';

import '../../../../domain/entities/property.dart';

enum PropertySearchStatus { initial, loading, success, failure }

class PropertySearchState extends Equatable {
  final String query;
  final String? listingType;
  final PropertySearchStatus status;
  final List<Property> properties;
  final bool hasReachedMax;
  final int currentPage;
  final int totalCount;
  final String? errorMessage;
  final List<String> recentSearches;

  const PropertySearchState({
    this.query = '',
    this.listingType,
    this.status = PropertySearchStatus.initial,
    this.properties = const [],
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.totalCount = 0,
    this.errorMessage,
    this.recentSearches = const [],
  });

  bool get hasSearched => status != PropertySearchStatus.initial;
  bool get isEmptyResult => hasSearched && status == PropertySearchStatus.success && properties.isEmpty;

  PropertySearchState copyWith({
    String? query,
    String? listingType,
    PropertySearchStatus? status,
    List<Property>? properties,
    bool? hasReachedMax,
    int? currentPage,
    int? totalCount,
    String? errorMessage,
    List<String>? recentSearches,
  }) {
    return PropertySearchState(
      query: query ?? this.query,
      listingType: listingType ?? this.listingType,
      status: status ?? this.status,
      properties: properties ?? this.properties,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: errorMessage ?? this.errorMessage,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }

  @override
  List<Object?> get props => [
        query,
        listingType,
        status,
        properties,
        hasReachedMax,
        currentPage,
        totalCount,
        errorMessage,
        recentSearches,
      ];
}
