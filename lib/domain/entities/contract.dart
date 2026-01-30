import 'package:equatable/equatable.dart';
import 'contract_status.dart';
import 'contract_type.dart';

class Contract extends Equatable {
  final String id;
  final String contractNumber;
  final String propertyName;
  final String lessor;
  final String lessee;
  final ContractStatus status;
  final ContractType? contractType;
  final String? propertyType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? sellerSignedContractUrl;
  final DateTime? sellerSignedAt;
  final String? buyerSignedContractUrl;
  final DateTime? buyerSignedAt;

  const Contract({
    required this.id,
    required this.contractNumber,
    required this.propertyName,
    required this.lessor,
    required this.lessee,
    required this.status,
    this.contractType,
    this.propertyType,
    this.createdAt,
    this.updatedAt,
    this.sellerSignedContractUrl,
    this.sellerSignedAt,
    this.buyerSignedContractUrl,
    this.buyerSignedAt,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    final property = json['property'] ?? {};
    final specs = property['specs'] ?? {};
    final buyer = json['buyer'] ?? {};
    final owner = json['owner'] ?? {};

    // Format contract number as 11-digit string with leading zeros
    String formatContractNumber(dynamic id) {
      if (id == null) return 'N/A';
      final idInt = id is int ? id : int.tryParse(id.toString());
      if (idInt == null) return id.toString();
      return idInt.toString().padLeft(11, '0');
    }

    // Construct property name from available data
    String pName = specs['name']?.toString() ?? '';
    if (pName.isEmpty) {
      if (specs['address'] != null) {
        pName = specs['address'].toString();
      } else {
        pName = 'Property #${property['id']}';
      }
    }

    // Get lessor name
    String? lessorName;
    if (owner['name'] != null) {
      lessorName = owner['name'].toString();
    } else if (json['agent_id'] != null) {
      lessorName = 'Agent #${json['agent_id']}';
    }

    return Contract(
      id: json['id']?.toString() ?? '',
      contractNumber: formatContractNumber(json['id']),
      propertyName: pName,
      lessor: lessorName ?? 'N/A',
      lessee: buyer['name']?.toString() ?? 'N/A',
      status: ContractStatus.fromApiValueOrDefault(json['status']?.toString()),
      contractType: ContractType.fromApiValue(
        json['contract_type']?.toString(),
      ),
      propertyType: _mapPropertyType(specs['type']?.toString()),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      sellerSignedContractUrl: json['seller_signed_contract_url']?.toString(),
      sellerSignedAt: json['seller_signed_at'] != null
          ? DateTime.parse(json['seller_signed_at'])
          : null,
      buyerSignedContractUrl: json['buyer_signed_contract_url']?.toString(),
      buyerSignedAt: json['buyer_signed_at'] != null
          ? DateTime.parse(json['buyer_signed_at'])
          : null,
    );
  }

  static String? _mapPropertyType(String? type) {
    if (type == null) return null;
    final t = type.toLowerCase();
    switch (t) {
      case 'house':
        return 'บ้าน';
      case 'condo':
      case 'condominium':
        return 'คอนโดมิเนียม';
      case 'townhome':
      case 'townhouse':
        return 'ทาวน์เฮ้าส์/ทาวน์โฮม';
      case 'apartment':
        return 'อพาร์ตเมนต์';
      case 'office':
      case 'home_office':
        return 'โฮมออฟฟิศ';
      case 'villa':
      case 'pool_villa':
        return 'พูลวิลล่า';
      case 'land':
        return 'ที่ดิน';
      case 'commercial':
        return 'เชิงพาณิชย์';
      default:
        return type;
    }
  }

  @override
  List<Object?> get props => [
    id,
    contractNumber,
    propertyName,
    lessor,
    lessee,
    status,
    contractType,
    propertyType,
    createdAt,
    updatedAt,
  ];
}
