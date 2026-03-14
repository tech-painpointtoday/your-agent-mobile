import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../domain/entities/property.dart';
import '../../../../services/property_api_service.dart';
import '../../services/property_search_recent_service.dart';
import 'property_search_event.dart';
import 'property_search_state.dart';

const int _perPage = 10;

class PropertySearchBloc
    extends Bloc<PropertySearchEvent, PropertySearchState> {
  PropertySearchBloc({
    PropertyApiService? propertyApiService,
    PropertySearchRecentService? recentService,
  })  : _api = propertyApiService ?? DependencyInjection.propertyApiService,
        _recentService =
            recentService ?? DependencyInjection.propertySearchRecentService,
        super(const PropertySearchState()) {
    on<PropertySearchOpened>(_onOpened);
    on<PropertySearchSubmitted>(_onSubmitted);
    on<PropertySearchLoadMore>(_onLoadMore);
    on<PropertySearchCleared>(_onCleared);
    on<PropertySearchRecentLoaded>(_onRecentLoaded);
  }

  final PropertyApiService _api;
  final PropertySearchRecentService _recentService;

  void _onOpened(
    PropertySearchOpened event,
    Emitter<PropertySearchState> emit,
  ) async {
    final recent = await _recentService.getRecentSearches();
    emit(state.copyWith(recentSearches: recent));
  }

  void _onRecentLoaded(
    PropertySearchRecentLoaded event,
    Emitter<PropertySearchState> emit,
  ) {
    emit(state.copyWith(recentSearches: event.recent));
  }

  void _onSubmitted(
    PropertySearchSubmitted event,
    Emitter<PropertySearchState> emit,
  ) async {
    final query = event.query.trim();
    emit(state.copyWith(
      query: query,
      listingType: event.listingType,
      status: PropertySearchStatus.loading,
      properties: [],
      currentPage: 1,
      hasReachedMax: false,
      totalCount: 0,
      errorMessage: null,
    ));

    try {
      if (query.isEmpty) {
        emit(state.copyWith(
          status: PropertySearchStatus.initial,
          properties: [],
          currentPage: 1,
          hasReachedMax: true,
        ));
        return;
      }

      await _recentService.addRecentSearch(query);

      final results = await _api.getProperties(
        q: query,
        listingType: event.listingType,
        page: 1,
        perPage: _perPage,
      );

      final hasReachedMax = results.properties.length < _perPage ||
          (results.pagination.lastPage <= 1);

      emit(state.copyWith(
        status: PropertySearchStatus.success,
        properties: results.properties,
        currentPage: 1,
        hasReachedMax: hasReachedMax,
        totalCount: results.pagination.total,
        errorMessage: null,
      ));

      final recent = await _recentService.getRecentSearches();
      emit(state.copyWith(recentSearches: recent));
    } catch (e, st) {
      debugPrint('PropertySearchBloc submit error: $e\n$st');
      emit(state.copyWith(
        status: PropertySearchStatus.failure,
        errorMessage: e.toString(),
        properties: [],
        hasReachedMax: true,
      ));
    }
  }

  void _onLoadMore(
    PropertySearchLoadMore event,
    Emitter<PropertySearchState> emit,
  ) async {
    if (state.hasReachedMax ||
        state.status != PropertySearchStatus.success ||
        state.query.isEmpty) {
      return;
    }

    final nextPage = state.currentPage + 1;

    try {
      final results = await _api.getProperties(
        q: state.query,
        listingType: state.listingType,
        page: nextPage,
        perPage: _perPage,
      );

      final combined = List<Property>.from(state.properties)
        ..addAll(results.properties);
      final hasReachedMax = results.properties.length < _perPage ||
          (results.pagination.currentPage >= results.pagination.lastPage);

      emit(state.copyWith(
        properties: combined,
        currentPage: nextPage,
        hasReachedMax: hasReachedMax,
        totalCount: results.pagination.total,
      ));
    } catch (e, st) {
      debugPrint('PropertySearchBloc loadMore error: $e\n$st');
      emit(state.copyWith(hasReachedMax: true));
    }
  }

  void _onCleared(
    PropertySearchCleared event,
    Emitter<PropertySearchState> emit,
  ) {
    emit(const PropertySearchState(
      recentSearches: [],
    ).copyWith(recentSearches: state.recentSearches));
  }
}
