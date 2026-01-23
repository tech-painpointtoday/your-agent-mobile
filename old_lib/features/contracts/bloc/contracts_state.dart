part of 'contracts_bloc.dart';

sealed class ContractsState extends Equatable {
  const ContractsState();

  @override
  List<Object?> get props => [];
}

final class ContractsInitial extends ContractsState {
  const ContractsInitial();
}

final class ContractsLoading extends ContractsState {
  const ContractsLoading();
}

final class ContractsLoaded extends ContractsState {
  final List<ContractModel> allContracts;
  final List<ContractModel> filteredContracts;
  final int currentPage;
  final int itemsPerPage;
  final ContractStatus? selectedStatus;
  final String? selectedPropertyType;
  final String? contractNumber;
  final String? propertyName;
  final String? lessor;
  final String? lessee;

  const ContractsLoaded({
    required this.allContracts,
    required this.filteredContracts,
    required this.currentPage,
    required this.itemsPerPage,
    this.selectedStatus,
    this.selectedPropertyType,
    this.contractNumber,
    this.propertyName,
    this.lessor,
    this.lessee,
  });

  int get totalPages => (filteredContracts.length / itemsPerPage).ceil();

  List<ContractModel> get paginatedContracts {
    final startIndex = (currentPage - 1) * itemsPerPage;
    if (startIndex >= filteredContracts.length) return [];

    final endIndex = min(startIndex + itemsPerPage, filteredContracts.length);
    return filteredContracts.sublist(startIndex, endIndex);
  }

  @override
  List<Object?> get props => [
    allContracts,
    filteredContracts,
    currentPage,
    itemsPerPage,
    selectedStatus,
    selectedPropertyType,
    contractNumber,
    propertyName,
    lessor,
    lessee,
  ];

  ContractsLoaded copyWith({
    List<ContractModel>? allContracts,
    List<ContractModel>? filteredContracts,
    int? currentPage,
    int? itemsPerPage,
    ContractStatus? selectedStatus,
    String? selectedPropertyType,
    String? contractNumber,
    String? propertyName,
    String? lessor,
    String? lessee,
  }) {
    return ContractsLoaded(
      allContracts: allContracts ?? this.allContracts,
      filteredContracts: filteredContracts ?? this.filteredContracts,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedPropertyType: selectedPropertyType ?? this.selectedPropertyType,
      contractNumber: contractNumber ?? this.contractNumber,
      propertyName: propertyName ?? this.propertyName,
      lessor: lessor ?? this.lessor,
      lessee: lessee ?? this.lessee,
    );
  }
}

final class ContractsError extends ContractsState {
  final String message;

  const ContractsError(this.message);

  @override
  List<Object?> get props => [message];
}
