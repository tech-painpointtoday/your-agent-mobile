import 'package:equatable/equatable.dart';
import '../../../../domain/entities/contract.dart';

enum ContractListStatus { initial, success, failure }

class ContractListState extends Equatable {
  final ContractListStatus status;
  final List<Contract> contracts;
  final bool hasReachedMax;
  final int currentPage;
  final int totalCount;
  final String? errorMessage;

  const ContractListState({
    this.status = ContractListStatus.initial,
    this.contracts = const <Contract>[],
    this.hasReachedMax = false,
    this.currentPage = 1,
    this.totalCount = 0,
    this.errorMessage,
  });

  ContractListState copyWith({
    ContractListStatus? status,
    List<Contract>? contracts,
    bool? hasReachedMax,
    int? currentPage,
    int? totalCount,
    String? errorMessage,
  }) {
    return ContractListState(
      status: status ?? this.status,
      contracts: contracts ?? this.contracts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    contracts,
    hasReachedMax,
    currentPage,
    totalCount,
    errorMessage,
  ];
}
