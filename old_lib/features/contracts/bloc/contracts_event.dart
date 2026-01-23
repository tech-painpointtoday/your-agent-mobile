part of 'contracts_bloc.dart';

sealed class ContractsEvent extends Equatable {
  const ContractsEvent();

  @override
  List<Object?> get props => [];
}

final class ContractsLoadRequested extends ContractsEvent {
  const ContractsLoadRequested();
}

final class ContractsFilterChanged extends ContractsEvent {
  final String? contractNumber;
  final String? propertyName;
  final String? lessor;
  final String? lessee;
  final ContractStatus? selectedStatus;
  final String? selectedPropertyType;

  const ContractsFilterChanged({
    this.contractNumber,
    this.propertyName,
    this.lessor,
    this.lessee,
    this.selectedStatus,
    this.selectedPropertyType,
  });

  @override
  List<Object?> get props => [contractNumber, propertyName, lessor, lessee, selectedStatus, selectedPropertyType];
}

final class ContractsPageChanged extends ContractsEvent {
  final int page;

  const ContractsPageChanged(this.page);

  @override
  List<Object?> get props => [page];
}

final class ContractsItemsPerPageChanged extends ContractsEvent {
  final int itemsPerPage;

  const ContractsItemsPerPageChanged(this.itemsPerPage);

  @override
  List<Object?> get props => [itemsPerPage];
}
