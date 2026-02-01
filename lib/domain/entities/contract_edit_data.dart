import 'package:equatable/equatable.dart';
import 'contract.dart';
import 'contract_create_data.dart';

class ContractEditData extends Equatable {
  final Contract contract;
  final ContractCreateData config;

  const ContractEditData({required this.contract, required this.config});

  factory ContractEditData.fromJson(Map<String, dynamic> json) {
    return ContractEditData(
      contract: Contract.fromJson(json['contract'] as Map<String, dynamic>),
      // ContractCreateData.fromJson can take the whole map if it maps keys correctly,
      // but let's check if we can just pass the root json if it contains the keys.
      config: ContractCreateData.fromJson(json),
    );
  }

  @override
  List<Object?> get props => [contract, config];
}
