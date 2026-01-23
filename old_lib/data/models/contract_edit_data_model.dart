import 'package:youragent/data/models/contract_create_data_model.dart';
import 'package:youragent/data/models/contract_model.dart';

/// Response model for contract edit data.
/// GET /agent/contracts/{id}/edit
///
/// Expected shape inside `data`:
/// {
///   "contract": { ... },
///   "banks": [ ... ],
///   "account_types": { ... }
/// }
class ContractEditData {
  final ContractModel contract;
  final Map<String, dynamic> contractJson;
  final List<Bank> banks;
  final Map<String, String> accountTypes;

  ContractEditData({
    required this.contract,
    required this.contractJson,
    this.banks = const [],
    this.accountTypes = const {},
  });

  factory ContractEditData.fromJson(Map<String, dynamic> json) {
    final contractJson = (json['contract'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    return ContractEditData(
      contract: ContractModel.fromJson(contractJson),
      contractJson: contractJson,
      banks: (json['banks'] as List<dynamic>?)
              ?.whereType<Map>()
              .map((e) => Bank.fromJson(e.cast<String, dynamic>()))
              .toList() ??
          const [],
      accountTypes: (json['account_types'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          const {},
    );
  }
}

