import 'package:equatable/equatable.dart';
import 'contract_status.dart';
import 'contract_type.dart';
import 'appliance_item.dart';
import 'furniture_item.dart';
import 'bank_account.dart';
import 'property.dart';
import 'buyer.dart';
import 'owner.dart';

class Contract extends Equatable {
  final int? id;
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
  final DateTime? startDate;
  final DateTime? endDate;

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
  final Owner? owner;

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
    this.startDate,
    this.endDate,
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
    final Map<String, dynamic>? propertyJson = json['property'] != null
        ? Map<String, dynamic>.from(json['property'] as Map)
        : null;
    final Map<String, dynamic> specs =
        propertyJson != null && propertyJson['specs'] != null
        ? Map<String, dynamic>.from(propertyJson['specs'] as Map)
        : {};
    final Map<String, dynamic>? buyerJson = json['buyer'] != null
        ? Map<String, dynamic>.from(json['buyer'] as Map)
        : null;
    final Map<String, dynamic>? ownerJson =
        (json['owner'] ?? json['seller']) != null
        ? Map<String, dynamic>.from((json['owner'] ?? json['seller']) as Map)
        : null;

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
        pName = 'Property #${json['property_id'] ?? propertyJson?['id']}';
      }
    }

    // Get lessor name
    String? lessorName;
    if (ownerJson != null && ownerJson['name'] != null) {
      lessorName = ownerJson['name'].toString();
    } else if (json['seller_id'] != null) {
      lessorName = 'Seller #${json['seller_id']}';
    }

    return Contract(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      contractNumber: formatContractNumber(json['id']),
      propertyName: pName,
      lessor: lessorName ?? 'N/A',
      lessee: buyerJson?['name']?.toString() ?? 'N/A',
      status: ContractStatus.fromApiValueOrDefault(json['status']?.toString()),
      contractType: ContractType.fromApiValue(
        json['contract_type']?.toString(),
      ),
      propertyType: _mapPropertyType(specs['type']?.toString()),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString()).toLocal()
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString()).toLocal()
          : null,
      sellerSignedContractUrl: json['seller_signed_contract_url']?.toString(),
      sellerSignedAt: json['seller_signed_at'] != null
          ? DateTime.parse(json['seller_signed_at'].toString()).toLocal()
          : null,
      buyerSignedContractUrl: json['buyer_signed_contract_url']?.toString(),
      buyerSignedAt: json['buyer_signed_at'] != null
          ? DateTime.parse(json['buyer_signed_at'].toString()).toLocal()
          : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'].toString()).toLocal()
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'].toString()).toLocal()
          : null,
      monthlyRentalCost: json['monthly_rental_cost']?.toString(),
      upfrontFee: json['upfront_fee']?.toString(),
      rentalPaymentDate: json['rental_payment_date'] is int
          ? json['rental_payment_date']
          : int.tryParse(json['rental_payment_date']?.toString() ?? ''),
      signingPlace: json['signing_place']?.toString(),
      contractDate: json['contract_date'] != null
          ? DateTime.parse(json['contract_date'].toString()).toLocal()
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
      appliances: (json['appliances'] as List? ?? []).map((e) {
        final photoUrl = e['photo_url']?.toString();
        final validatedPhotoUrls = (e['validated_photo_urls'] as List? ?? [])
            .map((url) => url.toString())
            .toList();

        // If plural list is empty but singular is present, add it to plural for display
        if (validatedPhotoUrls.isEmpty &&
            photoUrl != null &&
            photoUrl.isNotEmpty) {
          validatedPhotoUrls.add(photoUrl);
        }

        return ApplianceItem(
          id: e['id'].toString(),
          name: e['name'].toString(),
          description: e['description']?.toString(),
          existingPhotoUrl: photoUrl,
          validatedPhotoUrl: e['validated_photo_url']?.toString(),
          existingPhotoUrls: validatedPhotoUrls,
          photos: (e['photos'] as List? ?? [])
              .map((p) => Map<String, dynamic>.from(p as Map))
              .toList(),
        );
      }).toList(),
      furniture: (json['furniture'] as List? ?? []).map((e) {
        final photoUrl = e['photo_url']?.toString();
        final validatedPhotoUrls = (e['validated_photo_urls'] as List? ?? [])
            .map((url) => url.toString())
            .toList();

        // If plural list is empty but singular is present, add it to plural for display
        if (validatedPhotoUrls.isEmpty &&
            photoUrl != null &&
            photoUrl.isNotEmpty) {
          validatedPhotoUrls.add(photoUrl);
        }

        return FurnitureItem(
          id: e['id'].toString(),
          name: e['name'].toString(),
          description: e['description']?.toString(),
          existingPhotoUrl: photoUrl,
          validatedPhotoUrl: e['validated_photo_url']?.toString(),
          existingPhotoUrls: validatedPhotoUrls,
          photos: (e['photos'] as List? ?? [])
              .map((p) => Map<String, dynamic>.from(p as Map))
              .toList(),
        );
      }).toList(),
      bankAccounts: (json['bank_accounts'] as List? ?? [])
          .map((e) => BankAccount.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      property: propertyJson != null ? Property.fromJson(propertyJson) : null,
      buyer: buyerJson != null ? Buyer.fromJson(buyerJson) : null,
      owner: ownerJson != null ? Owner.fromJson(ownerJson) : null,
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
    startDate,
    endDate,
    owner,
  ];
}
