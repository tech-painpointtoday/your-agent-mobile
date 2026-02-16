import 'package:equatable/equatable.dart';

class ContractItemDefinition extends Equatable {
  final String value;
  final String label;
  final String labelEn;
  final String labelTh;

  const ContractItemDefinition({
    required this.value,
    required this.label,
    required this.labelEn,
    required this.labelTh,
  });

  factory ContractItemDefinition.fromJson(Map<String, dynamic> json) {
    return ContractItemDefinition(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      labelEn: json['label_en']?.toString() ?? '',
      labelTh: json['label_th']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [value, label, labelEn, labelTh];
}

class ContractItemDefinitions extends Equatable {
  final List<ContractItemDefinition> appliances;
  final List<ContractItemDefinition> furniture;

  const ContractItemDefinitions({
    this.appliances = const [],
    this.furniture = const [],
  });

  factory ContractItemDefinitions.fromJson(Map<String, dynamic> json) {
    return ContractItemDefinitions(
      appliances:
          (json['appliances'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ContractItemDefinition.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      furniture:
          (json['furniture'] as List<dynamic>?)
              ?.map(
                (e) =>
                    ContractItemDefinition.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [appliances, furniture];
}
