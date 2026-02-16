import 'package:equatable/equatable.dart';
import 'person_type.dart';

class Owner extends Equatable {
  final int? id;
  final String name;
  final String? idCard;
  final String? address;
  final String? phone;
  final String? email;
  final String? signatory;
  final PersonType type;
  final DateTime? createdAt;

  const Owner({
    this.id,
    required this.name,
    this.idCard,
    this.address,
    this.phone,
    this.email,
    this.signatory,
    required this.type,
    this.createdAt,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: (json['name'] ?? '').toString(),
      idCard: (json['id_card'] ?? json['national_id'])?.toString(),
      address: json['address']?.toString(),
      phone: (json['phone'] ?? json['mobile_number'])?.toString(),
      email: json['email']?.toString(),
      signatory: json['signatory']?.toString(),
      type: json['type'] == 'juristic'
          ? PersonType.juristic
          : PersonType.individual,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    idCard,
    address,
    phone,
    email,
    signatory,
    type,
    createdAt,
  ];
}
