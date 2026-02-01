import 'package:equatable/equatable.dart';

class BankAccount extends Equatable {
  final String id;
  final String accountHolderName;
  final String bankName;
  final String bankCode;
  final String accountNumber;
  final String? branch;
  final String? accountType;

  const BankAccount({
    required this.id,
    required this.accountHolderName,
    required this.bankName,
    required this.bankCode,
    required this.accountNumber,
    this.branch,
    this.accountType,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id']?.toString() ?? '',
      accountHolderName: json['account_holder_name']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? '',
      bankCode: json['bank_code']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      branch: json['branch']?.toString(),
      accountType: json['account_type']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    accountHolderName,
    bankName,
    bankCode,
    accountNumber,
    branch,
    accountType,
  ];
}
