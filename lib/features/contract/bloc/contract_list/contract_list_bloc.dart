import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/contract_api_service.dart';
import 'contract_list_event.dart';
import 'contract_list_state.dart';

class ContractListBloc extends Bloc<ContractListEvent, ContractListState> {
  final ContractApiService _contractApiService;
  static const int _perPage = 10;
  bool _isFetching = false;

  ContractListBloc({required ContractApiService contractApiService})
    : _contractApiService = contractApiService,
      super(const ContractListState()) {
    on<ContractListFetched>(_onContractListFetched);
    on<ContractListRefresh>(_onContractListRefresh);
  }

  Future<void> _onContractListFetched(
    ContractListFetched event,
    Emitter<ContractListState> emit,
  ) async {
    if (_isFetching) return;
    if (state.hasReachedMax && !event.isRefresh) return;

    _isFetching = true;
    try {
      if (state.status == ContractListStatus.initial || event.isRefresh) {
        final results = await _contractApiService.getContracts(
          page: 1,
          perPage: _perPage,
        );

        return emit(
          state.copyWith(
            status: ContractListStatus.success,
            contracts: results.contracts,
            hasReachedMax:
                results.pagination.currentPage >= results.pagination.lastPage,
            currentPage: 1,
            totalCount: results.pagination.total,
          ),
        );
      }

      final results = await _contractApiService.getContracts(
        page: state.currentPage + 1,
        perPage: _perPage,
      );

      emit(
        results.contracts.isEmpty
            ? state.copyWith(hasReachedMax: true)
            : state.copyWith(
                status: ContractListStatus.success,
                contracts: List.of(state.contracts)..addAll(results.contracts),
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
          status: ContractListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    } finally {
      _isFetching = false;
    }
  }

  void _onContractListRefresh(
    ContractListRefresh event,
    Emitter<ContractListState> emit,
  ) {
    add(const ContractListFetched(isRefresh: true));
  }
}
