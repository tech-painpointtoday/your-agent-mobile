// Request DTOs for Contract API endpoints

/// Request body for POST /agent/contracts (create from booking)
class CreateContractRequest {
  final int bookingId;
  final String startDate;
  final String endDate;
  final double? monthlyRentalCost;
  final double? upfrontFee;
  final int? rentalPaymentDate;
  final String? commonTerms;
  final String? flexibleTerms;

  CreateContractRequest({
    required this.bookingId,
    required this.startDate,
    required this.endDate,
    this.monthlyRentalCost,
    this.upfrontFee,
    this.rentalPaymentDate,
    this.commonTerms,
    this.flexibleTerms,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'booking_id': bookingId, 'start_date': startDate, 'end_date': endDate};
    if (monthlyRentalCost != null) data['monthly_rental_cost'] = monthlyRentalCost;
    if (upfrontFee != null) data['upfront_fee'] = upfrontFee;
    if (rentalPaymentDate != null) data['rental_payment_date'] = rentalPaymentDate;
    if (commonTerms != null) data['common_terms'] = commonTerms;
    if (flexibleTerms != null) data['flexible_terms'] = flexibleTerms;
    return data;
  }
}

/// Request body for POST /agent/contracts/from-property (create without booking)
class CreateContractFromPropertyRequest {
  final int propertyId;
  final String buyerEmail;
  final String buyerName;
  final String buyerPassword;
  final String? buyerMobileNumber;
  final String sellerEmail;
  final String sellerName;
  final String sellerPassword;
  final String? sellerMobileNumber;
  final String startDate;
  final String endDate;
  final double? monthlyRentalCost;
  final double? upfrontFee;
  final int? rentalPaymentDate;
  final String? commonTerms;
  final String? flexibleTerms;
  
  // Location fields
  final String? number;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? district;
  final String? province;
  final String? subdistrict;
  final String? road;
  final String? soi;

  CreateContractFromPropertyRequest({
    required this.propertyId,
    required this.buyerEmail,
    required this.buyerName,
    required this.buyerPassword,
    this.buyerMobileNumber,
    required this.sellerEmail,
    required this.sellerName,
    required this.sellerPassword,
    this.sellerMobileNumber,
    required this.startDate,
    required this.endDate,
    this.monthlyRentalCost,
    this.upfrontFee,
    this.rentalPaymentDate,
    this.commonTerms,
    this.flexibleTerms,
    this.number,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.district,
    this.province,
    this.subdistrict,
    this.road,
    this.soi,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'property_id': propertyId,
      'buyer_email': buyerEmail,
      'buyer_name': buyerName,
      'buyer_password': buyerPassword,
      'seller_email': sellerEmail,
      'seller_name': sellerName,
      'seller_password': sellerPassword,
      'start_date': startDate,
      'end_date': endDate,
    };
    if (buyerMobileNumber != null) data['buyer_mobile_number'] = buyerMobileNumber;
    if (sellerMobileNumber != null) data['seller_mobile_number'] = sellerMobileNumber;
    if (monthlyRentalCost != null) data['monthly_rental_cost'] = monthlyRentalCost;
    if (upfrontFee != null) data['upfront_fee'] = upfrontFee;
    if (rentalPaymentDate != null) data['rental_payment_date'] = rentalPaymentDate;
    if (commonTerms != null) data['common_terms'] = commonTerms;
    if (flexibleTerms != null) data['flexible_terms'] = flexibleTerms;
    
    // Location fields
    if (number != null) data['number'] = number;
    if (city != null) data['city'] = city;
    if (state != null) data['state'] = state;
    if (country != null) data['country'] = country;
    if (postalCode != null) data['postal_code'] = postalCode;
    if (district != null) data['district'] = district;
    if (province != null) data['province'] = province;
    if (subdistrict != null) data['subdistrict'] = subdistrict;
    if (road != null) data['road'] = road;
    if (soi != null) data['soi'] = soi;
    
    return data;
  }
}

/// Request body for PUT /agent/contracts/{id}
class UpdateContractRequest {
  final double? monthlyRentalCost;
  final double? upfrontFee;
  final int? rentalPaymentDate;
  final String? commonTerms;

  UpdateContractRequest({this.monthlyRentalCost, this.upfrontFee, this.rentalPaymentDate, this.commonTerms});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (monthlyRentalCost != null) data['monthly_rental_cost'] = monthlyRentalCost;
    if (upfrontFee != null) data['upfront_fee'] = upfrontFee;
    if (rentalPaymentDate != null) data['rental_payment_date'] = rentalPaymentDate;
    if (commonTerms != null) data['common_terms'] = commonTerms;
    return data;
  }

  bool get isEmpty => toJson().isEmpty;
}

/// Request body for POST /agent/contracts/{id}/assign-seller
class AssignSellerRequest {
  final String email;
  final bool createNew;
  final String? name;
  final String? mobileNumber;
  final String? password;
  final String? passwordConfirmation;

  AssignSellerRequest({
    required this.email,
    this.createNew = false,
    this.name,
    this.mobileNumber,
    this.password,
    this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'email': email, 'create_new': createNew};
    if (createNew) {
      if (name != null) data['name'] = name;
      if (mobileNumber != null) data['mobile_number'] = mobileNumber;
      if (password != null) data['password'] = password;
      if (passwordConfirmation != null) data['password_confirmation'] = passwordConfirmation;
    }
    return data;
  }
}
