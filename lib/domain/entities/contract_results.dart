import 'package:equatable/equatable.dart';
import 'contract.dart';
import 'pagination.dart';

class ContractResults extends Equatable {
  final List<Contract> contracts;
  final Pagination pagination;

  const ContractResults({required this.contracts, required this.pagination});

  @override
  List<Object?> get props => [contracts, pagination];
}
