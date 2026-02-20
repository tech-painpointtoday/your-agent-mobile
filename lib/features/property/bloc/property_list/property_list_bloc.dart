import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/property_api_service.dart';
import 'property_list_event.dart';
import 'property_list_state.dart';

class PropertyListBloc extends Bloc<PropertyListEvent, PropertyListState> {
  final PropertyApiService _propertyApiService;
  static const int _perPage = 10;
  bool _isFetching = false;

  PropertyListBloc({required PropertyApiService propertyApiService})
    : _propertyApiService = propertyApiService,
      super(const PropertyListState()) {
    on<PropertyListFetched>(_onPropertyListFetched);
    on<PropertyListRefresh>(_onPropertyListRefresh);
  }

  Future<void> _onPropertyListFetched(
    PropertyListFetched event,
    Emitter<PropertyListState> emit,
  ) async {
    if (_isFetching) return;
    if (state.hasReachedMax && !event.isRefresh) return;

    _isFetching = true;
    try {
      if (state.status == PropertyListStatus.initial || event.isRefresh) {
        final results = await _propertyApiService.getProperties(
          page: 1,
          perPage: _perPage,
        );

        return emit(
          state.copyWith(
            status: PropertyListStatus.success,
            properties: results.properties,
            hasReachedMax:
                results.pagination.currentPage >= results.pagination.lastPage,
            currentPage: 1,
            totalCount: results.pagination.total,
          ),
        );
      }

      final results = await _propertyApiService.getProperties(
        page: state.currentPage + 1,
        perPage: _perPage,
      );

      emit(
        results.properties.isEmpty
            ? state.copyWith(hasReachedMax: true)
            : state.copyWith(
                status: PropertyListStatus.success,
                properties: List.of(state.properties)
                  ..addAll(results.properties),
                hasReachedMax:
                    results.pagination.currentPage >=
                    results.pagination.lastPage,
                currentPage: state.currentPage + 1,
                totalCount: results.pagination.total,
              ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PropertyListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isFetching = false;
    }
  }

  void _onPropertyListRefresh(
    PropertyListRefresh event,
    Emitter<PropertyListState> emit,
  ) {
    add(const PropertyListFetched(isRefresh: true));
  }
}
