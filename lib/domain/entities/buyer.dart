import 'package:equatable/equatable.dart';
import 'person_type.dart';

class Buyer extends Equatable {
  final int? id;
  final String name;
  final String? idCard;
  final String? address;
  final String? phone;
  final String? email;
  final PersonType type;
  final DateTime? createdAt;

  const Buyer({
    this.id,
    required this.name,
    this.idCard,
    this.address,
    this.phone,
    this.email,
    required this.type,
    this.createdAt,
  });

  factory Buyer.fromJson(Map<String, dynamic> json) {
    return Buyer(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: (json['name'] ?? '').toString(),
      idCard: json['id_card']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
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
    type,
    createdAt,
  ];
}
