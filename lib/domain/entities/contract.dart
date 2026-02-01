import 'package:equatable/equatable.dart';
import 'contract_status.dart';
import 'contract_type.dart';
import 'appliance_item.dart';
import 'furniture_item.dart';
import 'bank_account.dart';
import 'property.dart';
import 'buyer.dart';
import 'property_owner.dart';

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

  // Additional fields for detail
  final String? monthlyRentalCost;
  final String? upfrontFee;
  final int? rentalPaymentDate;
  final String? signingPlace;
  final DateTime? contractDate;
  final String? propertyUnitNo;
  final String? propertyFloor;
  final String? propertyBuilding;
  final String? propertyProjectName;
  final String? propertyAreaSqm;
  final String? paymentMethod;
  final String? securityDeposit;
  final String? advanceRent;
  final String? commonFee;
  final String? commonTerms;
  final String? flexibleTerms;
  final List<ApplianceItem> appliances;
  final List<FurnitureItem> furniture;
  final List<BankAccount> bankAccounts;
  final Property? property;
  final Buyer? buyer;
  final PropertyOwner? owner;

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
    this.monthlyRentalCost,
    this.upfrontFee,
    this.rentalPaymentDate,
    this.signingPlace,
    this.contractDate,
    this.propertyUnitNo,
    this.propertyFloor,
    this.propertyBuilding,
    this.propertyProjectName,
    this.propertyAreaSqm,
    this.paymentMethod,
    this.securityDeposit,
    this.advanceRent,
    this.commonFee,
    this.commonTerms,
    this.flexibleTerms,
    this.appliances = const [],
    this.furniture = const [],
    this.bankAccounts = const [],
    this.property,
    this.buyer,
    this.owner,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    final propertyJson = json['property'] ?? {};
    final specs = propertyJson['specs'] ?? {};
    final buyerJson = json['buyer'] ?? {};
    final owner = json['owner'] ?? json['seller'] ?? {};

    // Format contract number as 11-digit string with leading zeros
    String formatContractNumber(dynamic id) {
      if (id == null) return 'N/A';
      final idInt = id is int ? id : int.tryParse(id.toString());
      if (idInt == null) return id.toString();
      return idInt.toString().padLeft(11, '0');
    }

    // Construct property name from available data
    String pName =
        json['property_project_name']?.toString() ??
        specs['name']?.toString() ??
        '';
    if (pName.isEmpty) {
      if (specs['address'] != null) {
        pName = specs['address'].toString();
      } else {
        pName = 'Property #${json['property_id'] ?? propertyJson['id']}';
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
      lessee: buyerJson['name']?.toString() ?? 'N/A',
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
      monthlyRentalCost: json['monthly_rental_cost']?.toString(),
      upfrontFee: json['upfront_fee']?.toString(),
      rentalPaymentDate: json['rental_payment_date'] is int
          ? json['rental_payment_date']
          : int.tryParse(json['rental_payment_date']?.toString() ?? ''),
      signingPlace: json['signing_place']?.toString(),
      contractDate: json['contract_date'] != null
          ? DateTime.parse(json['contract_date'])
          : null,
      propertyUnitNo: json['property_unit_no']?.toString(),
      propertyFloor: json['property_floor']?.toString(),
      propertyBuilding: json['property_building']?.toString(),
      propertyProjectName: json['property_project_name']?.toString(),
      propertyAreaSqm: json['property_area_sqm']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      securityDeposit: json['security_deposit']?.toString(),
      advanceRent: json['advance_rent']?.toString(),
      commonFee: json['common_fee']?.toString(),
      commonTerms: json['common_terms']?.toString(),
      flexibleTerms: json['flexible_terms']?.toString(),
      appliances: (json['appliances'] as List? ?? [])
          .map(
            (e) => ApplianceItem(
              id: e['id'].toString(),
              name: e['name'].toString(),
              description: e['description']?.toString(),
              existingPhotoUrl: e['photo_url']?.toString(),
            ),
          )
          .toList(),
      furniture: (json['furniture'] as List? ?? [])
          .map(
            (e) => FurnitureItem(
              id: e['id'].toString(),
              name: e['name'].toString(),
              description: e['description']?.toString(),
              existingPhotoUrl: e['photo_url']?.toString(),
            ),
          )
          .toList(),
      bankAccounts: (json['bank_accounts'] as List? ?? [])
          .map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
      property: json['property'] != null
          ? Property.fromJson(json['property'] as Map<String, dynamic>)
          : null,
      buyer: json['buyer'] != null
          ? Buyer.fromJson(json['buyer'] as Map<String, dynamic>)
          : null,
      owner: json['owner'] != null
          ? PropertyOwner.fromJson(json['owner'] as Map<String, dynamic>)
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
    sellerSignedContractUrl,
    sellerSignedAt,
    buyerSignedContractUrl,
    buyerSignedAt,
    owner,
  ];
}
