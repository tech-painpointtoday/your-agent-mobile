import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/data/models/contract_model.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/domain/entities/contract_status.dart';
import 'dart:math';

part 'contracts_event.dart';
part 'contracts_state.dart';

// BLoC
class ContractsBloc extends Bloc<ContractsEvent, ContractsState> {
  ContractsBloc() : super(const ContractsInitial()) {
    on<ContractsLoadRequested>(_onLoadRequested);
    on<ContractsFilterChanged>(_onFilterChanged);
    on<ContractsPageChanged>(_onPageChanged);
    on<ContractsItemsPerPageChanged>(_onItemsPerPageChanged);
  }

  Future<void> _onLoadRequested(ContractsLoadRequested event, Emitter<ContractsState> emit) async {
    emit(const ContractsLoading());
    try {
      // Fetch from API
      // Note: Currently fetching page 1. For full pagination support, we need to handle page changes via API.
      // But preserving existing local-pagination structure for now by fetching what we can.
      final response = await DependencyInjection.contractApiService.getContracts(page: 1);

      final dataList = response['data'] as List?;
      final List<ContractModel> contracts = [];

      if (dataList != null) {
        contracts.addAll(dataList.map((json) => ContractModel.fromJson(json)).toList());
      }

      // For now, treating fetched contracts as "allContracts" for local filtering/pagination
      // TODO: Implement server-side filtering and full pagination
      emit(ContractsLoaded(allContracts: contracts, filteredContracts: contracts, currentPage: 1, itemsPerPage: 10));
    } catch (e) {
      emit(ContractsError('Failed to load contracts: ${e.toString()}'));
    }
  }

  void _onFilterChanged(ContractsFilterChanged event, Emitter<ContractsState> emit) {
    if (state is ContractsLoaded) {
      final currentState = state as ContractsLoaded;

      // Calculate new filters
      final newContractNumber = event.contractNumber ?? currentState.contractNumber;
      final newPropertyName = event.propertyName ?? currentState.propertyName;
      final newLessor = event.lessor ?? currentState.lessor;
      final newLessee = event.lessee ?? currentState.lessee;
      final newStatus = event.selectedStatus ?? currentState.selectedStatus;
      final newType = event.selectedPropertyType ?? currentState.selectedPropertyType;

      // Filter logic
      final filteredContracts = _filterContracts(
        currentState.allContracts,
        newContractNumber,
        newPropertyName,
        newLessor,
        newLessee,
        newStatus,
        newType,
      );

      emit(
        currentState.copyWith(
          filteredContracts: filteredContracts,
          currentPage: 1, // Reset to page 1 on filter change
          contractNumber: newContractNumber,
          propertyName: newPropertyName,
          lessor: newLessor,
          lessee: newLessee,
          selectedStatus: newStatus,
          selectedPropertyType: newType,
        ),
      );
    }
  }

  void _onPageChanged(ContractsPageChanged event, Emitter<ContractsState> emit) {
    if (state is ContractsLoaded) {
      final currentState = state as ContractsLoaded;
      emit(currentState.copyWith(currentPage: event.page));
    }
  }

  void _onItemsPerPageChanged(ContractsItemsPerPageChanged event, Emitter<ContractsState> emit) {
    if (state is ContractsLoaded) {
      final currentState = state as ContractsLoaded;
      emit(
        currentState.copyWith(
          itemsPerPage: event.itemsPerPage,
          currentPage: 1, // Reset to page 1
        ),
      );
    }
  }

  List<ContractModel> _filterContracts(
    List<ContractModel> contracts,
    String? contractNumber,
    String? propertyName,
    String? lessor,
    String? lessee,
    ContractStatus? status,
    String? propertyType,
  ) {
    return contracts.where((contract) {
      final matchesContractNumber =
          contractNumber == null ||
          contractNumber.isEmpty ||
          (contract.contractNumber?.toLowerCase().contains(contractNumber.toLowerCase()) ?? false);
      final matchesPropertyName =
          propertyName == null ||
          propertyName.isEmpty ||
          (contract.propertyName?.toLowerCase().contains(propertyName.toLowerCase()) ?? false);
      final matchesLessor =
          lessor == null || lessor.isEmpty || (contract.lessor?.toLowerCase().contains(lessor.toLowerCase()) ?? false);
      final matchesLessee =
          lessee == null || lessee.isEmpty || (contract.lessee?.toLowerCase().contains(lessee.toLowerCase()) ?? false);
      final matchesStatus = status == null || contract.status == status;
      final matchesPropertyType = propertyType == null || contract.propertyType == propertyType;

      return matchesContractNumber &&
          matchesPropertyName &&
          matchesLessor &&
          matchesLessee &&
          matchesStatus &&
          matchesPropertyType;
    }).toList();
  }
}
