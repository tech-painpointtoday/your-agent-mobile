import 'package:equatable/equatable.dart';
import 'person_type.dart';

class PropertyOwner extends Equatable {
  final int? id;
  final String name;
  final String? idCard;
  final String? address;
  final String? phone;
  final String? email;
  final String? signatory;
  final PersonType type;
  final DateTime? createdAt;

  const PropertyOwner({
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

  factory PropertyOwner.fromJson(Map<String, dynamic> json) {
    return PropertyOwner(
      id: json['id'] as int?,
      name: (json['name'] ?? '').toString(),
      idCard: json['id_card']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      signatory: json['signatory']?.toString(),
      type: json['type'] == 'juristic'
          ? PersonType.juristic
          : PersonType.individual,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
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
