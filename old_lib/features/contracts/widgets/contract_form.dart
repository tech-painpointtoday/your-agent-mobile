import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/models/contract_model.dart';
import 'package:youragent/data/models/contract_create_data_model.dart';
import 'package:youragent/data/models/property_model.dart';
import 'package:youragent/domain/entities/contract_type.dart';
import 'package:youragent/features/contracts/bloc/form/contract_form_bloc.dart';
import 'package:youragent/features/contracts/bloc/form/contract_form_event.dart';
import 'package:youragent/features/contracts/bloc/form/contract_form_state.dart';
import 'package:youragent/features/contracts/widgets/contract_date_picker.dart';
import 'package:youragent/features/contracts/widgets/contract_form_components.dart';
import 'package:youragent/features/contracts/widgets/sections/asset_info_section.dart';
import 'package:youragent/widgets/form_fields/app_form_text_field.dart';
import 'package:youragent/widgets/form_fields/app_form_number_field.dart';
import 'package:youragent/widgets/form_fields/app_form_dropdown_field.dart';
import 'package:youragent/widgets/form_fields/app_form_section.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/dialogs/status_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Contract Form Widget - Supports Create, Edit, and View modes
///
/// Modes:
/// - Create: widget.contract == null, may have widget.property
/// - Edit: widget.contract != null, widget.isReadOnly == false
/// - View: widget.contract != null, widget.isReadOnly == true
class ContractForm extends StatefulWidget {
  final ContractModel? contract; // For edit/view mode
  final Map<String, dynamic>?
  contractJson; // Full contract JSON from API (optional, for full data)
  final PropertyModel? property; // For create mode with property pre-fill
  final ContractCreateData?
  contractCreateData; // For create mode with owner/bank data
  /// BLoC-provided ready-to-use form state (preferred source)
  final ContractFormData? initialData;
  final bool isReadOnly;
  final Function(Map<String, dynamic>)? onSubmit; // Callback with form data
  final Function(VoidCallback)? onFormReady; // Expose submitForm method

  const ContractForm({
    super.key,
    this.contract,
    this.contractJson,
    this.property,
    this.contractCreateData,
    this.initialData,
    this.isReadOnly = false,
    this.onSubmit,
    this.onFormReady,
  });

  @override
  State<ContractForm> createState() => _ContractFormState();
}

class _ContractFormState extends State<ContractForm> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // General Info Controllers
  late final TextEditingController _contractNumberController;
  ContractType? _selectedContractType;
  late final TextEditingController _contractDateController;
  late final TextEditingController _signingPlaceController =
      TextEditingController();

  // Lessor (Owner) Controllers
  String? _selectedLessorType; // 'person' or 'company'
  late final TextEditingController _lessorNameController;
  late final TextEditingController _lessorIdCardController;
  late final TextEditingController _lessorAddressController;
  late final TextEditingController _lessorPhoneController;
  late final TextEditingController _lessorEmailController;
  late final TextEditingController _lessorAuthorizedSignatoryController;

  // Lessee (Buyer) Controllers
  String? _selectedLesseeType; // 'person' or 'company'
  late final TextEditingController _lesseeNameController;
  late final TextEditingController _lesseeIdCardController;
  late final TextEditingController _lesseeAddressController;
  late final TextEditingController _lesseePhoneController;
  late final TextEditingController _lesseeEmailController;
  late final TextEditingController _lesseeAuthorizedSignatoryController;

  // Asset (Property) Controllers
  String? _selectedPropertyType;
  late final TextEditingController _projectNameController;
  late final TextEditingController _houseNumberController;
  late final TextEditingController _floorController;
  late final TextEditingController _soiController;
  late final TextEditingController _roadController;
  String? _selectedCountry;
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedSubdistrict;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;
  late final TextEditingController _parkingController;
  late final TextEditingController _landSizeController;
  late final TextEditingController _usableAreaController;
  late final TextEditingController _buildingController =
      TextEditingController();

  // Contract Duration Controllers
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController
  _leasePeriodController; // Auto-calculated, read-only
  String? _selectedRenewalFormat;
  late final TextEditingController _renewalConditionsController;

  // Payment Terms Controllers
  late final TextEditingController _rentalFeeController;
  late final TextEditingController _commonFeeController;
  late final TextEditingController _serviceFeeController;
  late final TextEditingController _totalMonthlyPaymentController;
  late final TextEditingController _advanceRentalController;
  late final TextEditingController _damageDepositController;
  late final TextEditingController _totalPaymentController; // Auto-calculated
  late final TextEditingController _paymentDueDateController;
  late final TextEditingController _waterFeeController;
  late final TextEditingController _paymentChannelController;
  late final TextEditingController _branchController;
  late final TextEditingController _accountNameController;
  late final TextEditingController _accountNumberController;

  // Terms Controller
  late final TextEditingController _additionalConditionsController;
  late final TextEditingController _flexibleTermsController =
      TextEditingController();

  // Date pickers state
  DateTime? _contractDate;
  DateTime? _startDate;
  DateTime? _endDate;

  // Appliances & Furniture state (structured items)
  final List<Map<String, dynamic>> _appliances =
      []; // [{name, description, photos: List<XFile>}]
  final List<Map<String, dynamic>> _furniture =
      []; // [{name, description, photos: List<XFile>}]

  @override
  void initState() {
    super.initState();
    // Initialize controllers WITH initial data immediately
    _initializeControllersWithData();

    // Expose submit method to parent - defer to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFormReady?.call(submitForm);
    });
  }

  /// Extract data from widget.contract, widget.contractJson, or widget.property
  /// and populate controllers with initial values
  void _initializeControllersWithData() {
    // Preferred: use BLoC-provided ready-to-use data from parent
    final initial = widget.initialData;
    if (initial != null) {
      // General Info
      _contractNumberController = TextEditingController(
        text: initial.contractNumber ?? '',
      );
      _contractDate = initial.contractDate;
      _contractDateController = TextEditingController(
        text: initial.contractDate != null
            ? _formatThaiDate(initial.contractDate!)
            : '',
      );
      _signingPlaceController.text = initial.signingPlace ?? '';

      // Lessor
      _lessorNameController = TextEditingController(
        text: initial.lessorName ?? '',
      );
      _lessorIdCardController = TextEditingController(
        text: initial.lessorIdCard ?? '',
      );
      _lessorAddressController = TextEditingController(
        text: initial.lessorAddress ?? '',
      );
      _lessorPhoneController = TextEditingController(
        text: initial.lessorPhone ?? '',
      );
      _lessorEmailController = TextEditingController(
        text: initial.lessorEmail ?? '',
      );
      _lessorAuthorizedSignatoryController = TextEditingController(
        text: initial.lessorAuthorizedSignatory ?? '',
      );

      // Lessee
      _lesseeNameController = TextEditingController(
        text: initial.lesseeName ?? '',
      );
      _lesseeIdCardController = TextEditingController(
        text: initial.lesseeIdCard ?? '',
      );
      _lesseeAddressController = TextEditingController(
        text: initial.lesseeAddress ?? '',
      );
      _lesseePhoneController = TextEditingController(
        text: initial.lesseePhone ?? '',
      );
      _lesseeEmailController = TextEditingController(
        text: initial.lesseeEmail ?? '',
      );
      _lesseeAuthorizedSignatoryController = TextEditingController(
        text: initial.lesseeAuthorizedSignatory ?? '',
      );

      // Asset
      _projectNameController = TextEditingController(
        text: initial.projectName ?? '',
      );
      _houseNumberController = TextEditingController(
        text: initial.houseNumber ?? '',
      );
      _floorController = TextEditingController(text: initial.floor ?? '');
      _buildingController.text = initial.building ?? '';
      _soiController = TextEditingController(text: initial.soi ?? '');
      _roadController = TextEditingController(text: initial.road ?? '');
      _postalCodeController = TextEditingController(
        text: initial.postalCode ?? '',
      );
      _bedroomsController = TextEditingController(text: initial.bedrooms ?? '');
      _bathroomsController = TextEditingController(
        text: initial.bathrooms ?? '',
      );
      _parkingController = TextEditingController(text: initial.parking ?? '');
      _landSizeController = TextEditingController(text: initial.landSize ?? '');
      _usableAreaController = TextEditingController(
        text: initial.usableArea ?? '',
      );

      // Contract Duration
      _startDate = initial.startDate;
      _endDate = initial.endDate;
      _startDateController = TextEditingController(
        text: initial.startDate != null
            ? _formatThaiDate(initial.startDate!)
            : '',
      );
      _endDateController = TextEditingController(
        text: initial.endDate != null ? _formatThaiDate(initial.endDate!) : '',
      );
      _leasePeriodController = TextEditingController(
        text: initial.leasePeriod ?? '',
      );
      _renewalConditionsController = TextEditingController(
        text: initial.renewalConditions ?? '',
      );
      _selectedRenewalFormat = initial.renewalFormat;

      // Payment Terms
      _rentalFeeController = TextEditingController(
        text: initial.rentalFee ?? '',
      );
      _commonFeeController = TextEditingController(
        text: initial.commonFee ?? '',
      );
      _serviceFeeController = TextEditingController(
        text: initial.serviceFee ?? '',
      );
      _totalMonthlyPaymentController = TextEditingController(
        text: initial.totalMonthlyPayment ?? '',
      );
      _advanceRentalController = TextEditingController(
        text: initial.advanceRental ?? '',
      );
      _damageDepositController = TextEditingController(
        text: initial.damageDeposit ?? '',
      );
      _totalPaymentController = TextEditingController(
        text: initial.totalPayment ?? '',
      );
      _paymentDueDateController = TextEditingController(
        text: initial.paymentDueDate ?? '',
      );
      _waterFeeController = TextEditingController(text: initial.waterFee ?? '');

      _paymentChannelController = TextEditingController(
        text: initial.paymentChannel ?? '',
      );
      _branchController = TextEditingController(text: initial.branch ?? '');
      _accountNameController = TextEditingController(
        text: initial.accountName ?? '',
      );
      _accountNumberController = TextEditingController(
        text: initial.accountNumber ?? '',
      );

      // Terms
      _additionalConditionsController = TextEditingController(
        text: initial.additionalConditions ?? '',
      );
      _flexibleTermsController.text = initial.flexibleTerms ?? '';

      // Dropdown selections
      _selectedContractType = initial.contractType;
      _selectedLessorType = initial.lessorType ?? 'person';
      _selectedLesseeType = initial.lesseeType ?? 'person';
      _selectedPropertyType = initial.propertyType;
      _selectedCountry = initial.country;
      _selectedProvince = initial.province;
      _selectedDistrict = initial.district;
      _selectedSubdistrict = initial.subdistrict;

      return;
    }

    // Extract contract JSON if available
    Map<String, dynamic>? contractJson = widget.contractJson;
    if (contractJson != null && contractJson.containsKey('data')) {
      final data = contractJson['data'];
      if (data is Map<String, dynamic> && data.containsKey('contract')) {
        contractJson = data['contract'] as Map<String, dynamic>?;
      }
    }
    final json = contractJson ?? {};

    // Extract nested objects
    final property = json['property'] ?? {};
    final specs = property['specs'] ?? {};
    final location = property['location'] ?? {};
    final buyer = json['buyer'] ?? {};
    final owner = json['owner'] ?? {};
    final bankAccounts = json['bank_accounts'] as List<dynamic>? ?? [];

    // Helper to format currency
    String? formatCurrency(String? value) {
      if (value == null || value.isEmpty) return null;
      final clean = value.replaceAll(',', '').replaceAll(' ', '');
      final num = double.tryParse(clean);
      if (num == null) return value;
      return NumberFormat('#,###').format(num.round());
    }

    // General Info
    String? contractNumber;
    if (widget.contract != null) {
      contractNumber = widget.contract!.contractNumber;
    } else if (json['id'] != null) {
      final idInt = int.tryParse(json['id'].toString());
      if (idInt != null) {
        contractNumber = idInt.toString().padLeft(11, '0');
      }
    }
    _contractNumberController = TextEditingController(
      text: contractNumber ?? '',
    );

    DateTime? contractDate;
    if (widget.contract != null) {
      contractDate = widget.contract!.createdAt;
    } else if (json['contract_date'] != null) {
      try {
        contractDate = DateTime.parse(json['contract_date']);
      } catch (e) {
        // Ignore parse errors
      }
    } else if (json['created_at'] != null) {
      try {
        contractDate = DateTime.parse(json['created_at']);
      } catch (e) {
        // Ignore parse errors
      }
    }
    _contractDateController = TextEditingController(
      text: contractDate != null ? _formatThaiDate(contractDate) : '',
    );
    _contractDate = contractDate;

    // Lessor - from owner JSON
    String? lessorName = owner['name']?.toString();
    String? lessorIdCard =
        owner['id_card']?.toString() ?? owner['national_id']?.toString();
    String? lessorAddress = owner['address']?.toString();
    String? lessorPhone =
        owner['mobile_number']?.toString() ?? owner['phone']?.toString();
    String? lessorEmail = owner['email']?.toString();
    String? lessorAuthorizedSignatory = owner['authorized_signatory']
        ?.toString();

    _lessorNameController = TextEditingController(text: lessorName ?? '');
    _lessorIdCardController = TextEditingController(text: lessorIdCard ?? '');
    _lessorAddressController = TextEditingController(text: lessorAddress ?? '');
    _lessorPhoneController = TextEditingController(text: lessorPhone ?? '');
    _lessorEmailController = TextEditingController(text: lessorEmail ?? '');
    _lessorAuthorizedSignatoryController = TextEditingController(
      text: lessorAuthorizedSignatory ?? '',
    );

    // Lessee - from buyer JSON
    String? lesseeName = buyer['name']?.toString();
    String? lesseeIdCard =
        buyer['id_card']?.toString() ?? buyer['national_id']?.toString();
    String? lesseeAddress = buyer['address']?.toString();
    String? lesseePhone =
        buyer['mobile_number']?.toString() ?? buyer['phone']?.toString();
    String? lesseeEmail = buyer['email']?.toString();
    String? lesseeAuthorizedSignatory = buyer['authorized_signatory']
        ?.toString();

    _lesseeNameController = TextEditingController(text: lesseeName ?? '');
    _lesseeIdCardController = TextEditingController(text: lesseeIdCard ?? '');
    _lesseeAddressController = TextEditingController(text: lesseeAddress ?? '');
    _lesseePhoneController = TextEditingController(text: lesseePhone ?? '');
    _lesseeEmailController = TextEditingController(text: lesseeEmail ?? '');
    _lesseeAuthorizedSignatoryController = TextEditingController(
      text: lesseeAuthorizedSignatory ?? '',
    );

    // Asset - from contract JSON or property
    String? projectName =
        json['property_project_name']?.toString() ??
        property['property_project_name']?.toString() ??
        specs['name']?.toString() ??
        widget.property?.specs?.name ??
        widget.property?.name;
    String? houseNumber = json['property_unit_no']?.toString();
    if (houseNumber == null || houseNumber.isEmpty) {
      if (location['number'] != null) {
        if (location['number'] is Map<String, dynamic>) {
          final numberObj = location['number'] as Map<String, dynamic>;
          houseNumber =
              numberObj['original']?.toString() ??
              numberObj['number']?.toString();
        } else {
          houseNumber = location['number']?.toString();
        }
      }
      houseNumber ??= location['computed_house_number']?.toString();
      houseNumber ??= widget.property?.propertyLocation?.number;
    }
    String? floor =
        json['property_floor']?.toString() ?? location['floor']?.toString();
    String? soi =
        location['soi']?.toString() ?? widget.property?.propertyLocation?.soi;
    String? road =
        location['road']?.toString() ?? widget.property?.propertyLocation?.road;
    String? postalCode =
        location['postal_code']?.toString() ??
        widget.property?.propertyLocation?.postalCode;
    String? bedrooms =
        specs['bedrooms']?.toString() ??
        widget.property?.specs?.bedrooms.toString();
    String? bathrooms =
        specs['bathrooms']?.toString() ??
        widget.property?.specs?.bathrooms.toString();
    String? parking =
        specs['garage']?.toString() ??
        widget.property?.specs?.garage.toString();
    String? landSize =
        specs['land_size']?.toString() ??
        widget.property?.specs?.landSize?.toString();
    String? usableArea =
        json['property_area_sqm']?.toString() ??
        specs['building_size']?.toString() ??
        widget.property?.specs?.buildingSize?.toString();

    _projectNameController = TextEditingController(text: projectName ?? '');
    _houseNumberController = TextEditingController(text: houseNumber ?? '');
    _floorController = TextEditingController(text: floor ?? '');
    _soiController = TextEditingController(text: soi ?? '');
    _roadController = TextEditingController(text: road ?? '');
    _postalCodeController = TextEditingController(text: postalCode ?? '');
    _bedroomsController = TextEditingController(text: bedrooms ?? '');
    _bathroomsController = TextEditingController(text: bathrooms ?? '');
    _parkingController = TextEditingController(text: parking ?? '');
    _landSizeController = TextEditingController(text: landSize ?? '');
    _usableAreaController = TextEditingController(text: usableArea ?? '');

    // Contract Duration
    DateTime? startDate;
    if (json['start_date'] != null) {
      try {
        startDate = DateTime.parse(json['start_date']);
      } catch (e) {
        // Ignore parse errors
      }
    }
    DateTime? endDate;
    if (json['end_date'] != null) {
      try {
        endDate = DateTime.parse(json['end_date']);
      } catch (e) {
        // Ignore parse errors
      }
    }
    _startDate = startDate;
    _endDate = endDate;
    _startDateController = TextEditingController(
      text: startDate != null ? _formatThaiDate(startDate) : '',
    );
    _endDateController = TextEditingController(
      text: endDate != null ? _formatThaiDate(endDate) : '',
    );
    _leasePeriodController = TextEditingController(); // Calculated field
    _renewalConditionsController = TextEditingController(
      text: json['renewal_conditions']?.toString() ?? '',
    );

    // Payment Terms
    _rentalFeeController = TextEditingController(
      text: formatCurrency(json['monthly_rental_cost']?.toString()) ?? '',
    );
    _commonFeeController = TextEditingController(
      text: formatCurrency(json['common_fee']?.toString()) ?? '',
    );
    _serviceFeeController = TextEditingController(
      text: formatCurrency(json['service_fee']?.toString()) ?? '',
    );
    _totalMonthlyPaymentController =
        TextEditingController(); // Calculated field
    _advanceRentalController = TextEditingController(
      text: formatCurrency(json['upfront_fee']?.toString()) ?? '',
    );
    final securityDepositRaw =
        json['security_deposit'] ?? json['damage_deposit'];
    _damageDepositController = TextEditingController(
      text: formatCurrency(securityDepositRaw?.toString()) ?? '',
    );
    _totalPaymentController = TextEditingController(); // Calculated field
    _paymentDueDateController = TextEditingController(
      text: json['rental_payment_date']?.toString() ?? '',
    );
    _waterFeeController = TextEditingController(
      text: json['water_fee']?.toString() ?? '',
    );

    // Bank accounts
    String? paymentChannel;
    String? branch;
    String? accountName;
    String? accountNumber;
    if (bankAccounts.isNotEmpty) {
      final bankAccount = bankAccounts
          .whereType<Map<String, dynamic>>()
          .firstWhere(
            (account) =>
                account['bank_name'] != null ||
                account['account_number'] != null,
            orElse: () => <String, dynamic>{},
          );
      if (bankAccount.isNotEmpty) {
        paymentChannel = bankAccount['bank_name']?.toString();
        branch = bankAccount['branch']?.toString();
        accountName =
            bankAccount['account_name']?.toString() ??
            bankAccount['account_holder_name']?.toString();
        accountNumber = bankAccount['account_number']?.toString();
      }
    }
    paymentChannel ??= json['payment_method']?.toString();
    _paymentChannelController = TextEditingController(
      text: paymentChannel ?? '',
    );
    _branchController = TextEditingController(text: branch ?? '');
    _accountNameController = TextEditingController(text: accountName ?? '');
    _accountNumberController = TextEditingController(text: accountNumber ?? '');

    // Terms
    _additionalConditionsController = TextEditingController(
      text: json['common_terms']?.toString() ?? '',
    );

    // Initialize dropdown selections
    if (widget.contract != null) {
      _selectedContractType = widget.contract!.contractType;
    } else if (json['contract_type'] != null) {
      _selectedContractType = ContractType.fromApiValue(
        json['contract_type'].toString(),
      );
    }

    // Lessor type
    if (lessorIdCard != null) {
      _selectedLessorType = 'person';
    } else if (json['lessor_tax_id'] != null || owner['company_name'] != null) {
      _selectedLessorType = 'company';
    }

    // Lessee type
    if (lesseeIdCard != null) {
      _selectedLesseeType = 'person';
    } else if (json['lessee_tax_id'] != null || buyer['company_name'] != null) {
      _selectedLesseeType = 'company';
    }

    // Property type
    _selectedPropertyType =
        specs['type']?.toString() ?? widget.property?.specs?.type;

    // Address dropdowns
    String? countryRaw =
        location['country']?.toString() ??
        widget.property?.propertyLocation?.country;
    if (countryRaw != null) {
      final trimmed = countryRaw.trim();
      if (trimmed == 'ประเทศไทย' || trimmed == 'Thailand') {
        _selectedCountry = 'ไทย';
      } else {
        _selectedCountry = trimmed;
      }
    } else {
      _selectedCountry = 'ไทย'; // Default
    }
    _selectedProvince =
        location['state']?.toString() ??
        widget.property?.propertyLocation?.state;
    _selectedDistrict =
        location['city']?.toString() ?? widget.property?.propertyLocation?.city;
    _selectedSubdistrict =
        location['subdistrict']?.toString() ??
        location['district']?.toString() ??
        widget.property?.propertyLocation?.subdistrict;

    // Renewal format
    _selectedRenewalFormat = json['renewal_format']?.toString();
  }

  // Sync BLoC state to controllers (called from BlocListener)
  // Only syncs dropdowns, dates, and calculated/read-only fields
  // Manual input fields are NOT synced to prevent data loss during typing
  void _syncStateFromBloc(ContractFormData state) {
    // Dropdowns / enum selections
    if (state.contractType != _selectedContractType) {
      _selectedContractType = state.contractType;
    }
    if (state.lessorType != _selectedLessorType) {
      _selectedLessorType = state.lessorType;
    }
    if (state.lesseeType != _selectedLesseeType) {
      _selectedLesseeType = state.lesseeType;
    }
    if (state.propertyType != _selectedPropertyType) {
      _selectedPropertyType = state.propertyType;
    }
    // Normalize country value to match dropdown items
    String? normalizedCountry = state.country;
    if (normalizedCountry != null) {
      final trimmed = normalizedCountry.trim();
      if (trimmed == 'ประเทศไทย' || trimmed == 'Thailand') {
        normalizedCountry = 'ไทย';
      }
    }
    if (normalizedCountry != _selectedCountry) {
      _selectedCountry = normalizedCountry;
    }
    if (state.province != _selectedProvince) {
      _selectedProvince = state.province;
    }
    if (state.district != _selectedDistrict) {
      _selectedDistrict = state.district;
    }
    if (state.subdistrict != _selectedSubdistrict) {
      _selectedSubdistrict = state.subdistrict;
    }
    if (state.renewalFormat != _selectedRenewalFormat) {
      _selectedRenewalFormat = state.renewalFormat;
    }

    // Dates (keep in sync)
    if (state.contractDate != _contractDate) {
      _contractDate = state.contractDate;
      if (state.contractDate != null) {
        _contractDateController.text = _formatThaiDate(state.contractDate!);
      }
    }
    if (state.startDate != _startDate) {
      _startDate = state.startDate;
      if (state.startDate != null) {
        _startDateController.text = _formatThaiDate(state.startDate!);
      } else {
        _startDateController.clear();
      }
    }
    if (state.endDate != _endDate) {
      _endDate = state.endDate;
      if (state.endDate != null) {
        _endDateController.text = _formatThaiDate(state.endDate!);
      } else {
        _endDateController.clear();
      }
    }

    // Calculated / read-only fields
    if (state.leasePeriod != _leasePeriodController.text) {
      _leasePeriodController.text = state.leasePeriod ?? '';
    }
    if (state.totalMonthlyPayment != _totalMonthlyPaymentController.text) {
      _totalMonthlyPaymentController.text = state.totalMonthlyPayment ?? '';
    }
    if (state.totalPayment != _totalPaymentController.text) {
      _totalPaymentController.text = state.totalPayment ?? '';
    }

    // Payment channel (prefill only if empty to avoid overwriting user typing)
    if (_paymentChannelController.text.isEmpty &&
        (state.paymentChannel?.isNotEmpty ?? false)) {
      _paymentChannelController.text = state.paymentChannel ?? '';
    }
  }

  // Calculation methods removed - now handled by BLoC

  @override
  void dispose() {
    // General Info
    _contractNumberController.dispose();
    _contractDateController.dispose();

    // Lessor
    _lessorNameController.dispose();
    _lessorIdCardController.dispose();
    _lessorAddressController.dispose();
    _lessorPhoneController.dispose();
    _lessorEmailController.dispose();
    _lessorAuthorizedSignatoryController.dispose();

    // Lessee
    _lesseeNameController.dispose();
    _lesseeIdCardController.dispose();
    _lesseeAddressController.dispose();
    _lesseePhoneController.dispose();
    _lesseeEmailController.dispose();
    _lesseeAuthorizedSignatoryController.dispose();

    // Asset
    _projectNameController.dispose();
    _houseNumberController.dispose();
    _floorController.dispose();
    _soiController.dispose();
    _roadController.dispose();
    _postalCodeController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _parkingController.dispose();
    _landSizeController.dispose();
    _usableAreaController.dispose();

    // Contract Duration
    _startDateController.dispose();
    _endDateController.dispose();
    _leasePeriodController.dispose();
    _renewalConditionsController.dispose();

    // Payment Terms
    _rentalFeeController.dispose();
    _commonFeeController.dispose();
    _serviceFeeController.dispose();
    _totalMonthlyPaymentController.dispose();
    _advanceRentalController.dispose();
    _damageDepositController.dispose();
    _totalPaymentController.dispose();
    _paymentDueDateController.dispose();
    _waterFeeController.dispose();
    _paymentChannelController.dispose();
    _branchController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();

    // Terms
    _additionalConditionsController.dispose();
    _flexibleTermsController.dispose();
    _signingPlaceController.dispose();
    _buildingController.dispose();

    _scrollController.dispose();
    super.dispose();
  }

  // Helper Methods
  String _formatThaiDate(DateTime date) {
    final thaiMonths = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];
    final thaiYear = date.year + 543;
    return '${date.day} ${thaiMonths[date.month - 1]} $thaiYear';
  }

  DateTime? _parseThaiDate(String dateStr) {
    if (dateStr.isEmpty) return null;

    final thaiMonths = [
      'ม.ค.',
      'ก.พ.',
      'มี.ค.',
      'เม.ย.',
      'พ.ค.',
      'มิ.ย.',
      'ก.ค.',
      'ส.ค.',
      'ก.ย.',
      'ต.ค.',
      'พ.ย.',
      'ธ.ค.',
    ];

    // Parse format: "25 ธ.ค. 2568"
    final match = RegExp(r'(\d+)\s+([ก-ฮ.]+)\s+(\d+)').firstMatch(dateStr);
    if (match == null) return null;

    final day = int.tryParse(match.group(1) ?? '');
    final monthName = match.group(2) ?? '';
    final yearStr = match.group(3) ?? '';

    if (day == null || yearStr.isEmpty) return null;

    final monthIndex = thaiMonths.indexWhere((m) => monthName.contains(m));
    if (monthIndex == -1) return null;

    final year = int.tryParse(yearStr);
    if (year == null) return null;

    // Convert Buddhist year to Gregorian
    final gregorianYear = year - 543;

    try {
      return DateTime(gregorianYear, monthIndex + 1, day);
    } catch (e) {
      return null;
    }
  }

  double? _parseCurrency(String value) {
    if (value.isEmpty) return null;
    final clean = value.replaceAll(',', '').replaceAll(' ', '');
    return double.tryParse(clean);
  }

  double? _parseDouble(String value) {
    if (value.isEmpty) return null;
    final clean = value.replaceAll(',', '').replaceAll(' ', '');
    return double.tryParse(clean);
  }

  int? _parseInt(String value) {
    if (value.isEmpty) return null;
    return int.tryParse(value.trim());
  }

  // Note: AppFormTextField and AppFormNumberField have built-in validators
  // Custom validation is handled in _buildDateField for date-specific logic

  // Date Picker Methods
  Future<void> _selectDate({
    required TextEditingController controller,
    required DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    required Function(DateTime) onDateSelected,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      locale: const Locale('th', 'TH'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.buttonPrimary,
              onPrimary: Colors.white,
              onSurface: AppColors.baseDarkGrey,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = _formatThaiDate(picked);
      onDateSelected(picked);
    }
  }

  // Submission Method
  void submitForm() {
    if (!_formKey.currentState!.validate()) {
      // Scroll to first error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      return;
    }

    final state = context.read<ContractFormBloc>().state;
    if (state is! ContractFormData) return;

    // Parse dates from controllers (fallback to tracked DateTimes)
    final contractDateParsed =
        _parseThaiDate(_contractDateController.text.trim()) ?? _contractDate;
    final startDateParsed =
        _parseThaiDate(_startDateController.text.trim()) ?? _startDate;
    final endDateParsed =
        _parseThaiDate(_endDateController.text.trim()) ?? _endDate;

    // Build form data map from Controllers (source of truth for manual fields)
    final formData = <String, dynamic>{
      // General
      'contract_type': _selectedContractType?.apiValue,
      'contract_date': contractDateParsed != null
          ? DateFormat('yyyy-MM-dd').format(contractDateParsed)
          : null,
      'signing_place': _signingPlaceController.text.trim(),

      // Lessor - Read from controllers (use state for fields without controllers)
      'lessor_type': _selectedLessorType,
      'lessor_name': _lessorNameController.text.trim(),
      'lessor_id_card': _lessorIdCardController.text.trim(),
      'lessor_tax_id': state.lessorTaxId?.trim(),
      'lessor_license_number': state.lessorLicenseNumber?.trim(),
      'lessor_address': _lessorAddressController.text.trim(),
      'lessor_phone': _lessorPhoneController.text.trim(),
      'lessor_email': _lessorEmailController.text.trim(),
      'lessor_authorized_signatory': _lessorAuthorizedSignatoryController.text
          .trim(),

      // Lessee - Read from controllers (use state for fields without controllers)
      'lessee_type': _selectedLesseeType,
      'lessee_name': _lesseeNameController.text.trim(),
      'lessee_id_card': _lesseeIdCardController.text.trim(),
      'lessee_tax_id': state.lesseeTaxId?.trim(),
      'lessee_address': _lesseeAddressController.text.trim(),
      'lessee_phone': _lesseePhoneController.text.trim(),
      'lessee_email': _lesseeEmailController.text.trim(),
      'lessee_authorized_signatory': _lesseeAuthorizedSignatoryController.text
          .trim(),

      // Asset - Read from controllers
      'property_type': _selectedPropertyType,
      'property_project_name': _projectNameController.text.trim(),
      'property_unit_no': _houseNumberController.text.trim(),
      'property_floor': _floorController.text.trim(),
      'property_building': _buildingController.text.trim(),
      'soi': _soiController.text.trim(),
      'road': _roadController.text.trim(),
      'country': _selectedCountry,
      'province': _selectedProvince,
      'district': _selectedDistrict,
      'subdistrict': _selectedSubdistrict,
      'postal_code': _postalCodeController.text.trim(),
      'bedrooms': _parseInt(_bedroomsController.text),
      'bathrooms': _parseInt(_bathroomsController.text),
      'parking': _parseInt(_parkingController.text),
      'land_size': _parseCurrency(_landSizeController.text),
      'property_area_sqm': _parseDouble(_usableAreaController.text),

      // Contract Duration - Read from controllers
      'start_date': startDateParsed != null
          ? DateFormat('yyyy-MM-dd').format(startDateParsed)
          : null,
      'end_date': endDateParsed != null
          ? DateFormat('yyyy-MM-dd').format(endDateParsed)
          : null,
      'renewal_format': _selectedRenewalFormat,
      'renewal_conditions': _renewalConditionsController.text.trim(),

      // Payment Terms - Read from controllers and parse currency
      'monthly_rental_cost': _parseCurrency(_rentalFeeController.text),
      'common_fee': _parseCurrency(_commonFeeController.text),
      'service_fee': _parseCurrency(_serviceFeeController.text),
      'advance_rent': _parseCurrency(_advanceRentalController.text),
      'security_deposit': _parseCurrency(_damageDepositController.text),
      'rental_payment_date': _parseInt(_paymentDueDateController.text),
      'water_fee': _waterFeeController.text.trim(),
      'late_fee': _parseCurrency(state.lateFee ?? ''),
      'payment_method': _paymentChannelController.text.trim(),

      // Bank Accounts - Read from controllers
      'bank_accounts': [
        {
          'account_holder_name': _accountNameController.text.trim(),
          'bank_name': _paymentChannelController.text.trim(),
          'account_number': _accountNumberController.text.trim(),
          'branch': _branchController.text.trim(),
          'account_type': 'Savings', // Default account type
        },
      ],

      // Appliances & Furniture - Structured items
      'appliances': _appliances.map((item) {
        final Map<String, dynamic> applianceData = {
          'name': item['name']?.toString().trim() ?? '',
          'description': item['description']?.toString().trim() ?? '',
        };
        final photos =
            (item['photos'] as List<dynamic>?)?.whereType<XFile>().toList() ??
            (item['photo'] != null ? [item['photo'] as XFile] : <XFile>[]);
        if (photos.isNotEmpty) {
          applianceData['photo_paths'] = photos
              .map((photo) => photo.path)
              .toList();
        }
        return applianceData;
      }).toList(),

      'furniture': _furniture.map((item) {
        final Map<String, dynamic> furnitureData = {
          'name': item['name']?.toString().trim() ?? '',
          'description': item['description']?.toString().trim() ?? '',
        };
        final photos =
            (item['photos'] as List<dynamic>?)?.whereType<XFile>().toList() ??
            (item['photo'] != null ? [item['photo'] as XFile] : <XFile>[]);
        if (photos.isNotEmpty) {
          furnitureData['photo_paths'] = photos
              .map((photo) => photo.path)
              .toList();
        }
        return furnitureData;
      }).toList(),

      // Terms - Read from controllers
      'common_terms': _additionalConditionsController.text.trim(),
      'flexible_terms': _flexibleTermsController.text.trim(),
    };

    // Preserve identifiers from state (not in controllers)
    if (state.contractIdInt != null) {
      formData['contract_id'] = state.contractIdInt;
    }
    if (state.propertyId != null) {
      formData['property_id'] = state.propertyId;
    }
    if (state.bookingId != null) {
      formData['booking_id'] = state.bookingId;
    }

    widget.onSubmit?.call(formData);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<ContractFormBloc, ContractFormState>(
      listenWhen: (previous, current) {
        if (previous is! ContractFormData || current is! ContractFormData) {
          return true;
        }
        return previous.submitSuccess != current.submitSuccess ||
            previous.submitErrorMessage != current.submitErrorMessage ||
            previous.lessorRegistrationStatus !=
                current.lessorRegistrationStatus ||
            previous.lesseeRegistrationStatus !=
                current.lesseeRegistrationStatus;
      },
      listener: (context, state) {
        if (state is ContractFormData) {
          _syncStateFromBloc(state);

          // Handle registration success/error feedback
          if (state.lessorRegistrationStatus == RegistrationStatus.success) {
            StatusDialog.showSuccess(
              context: context,
              title: l10n.success,
              message: 'Seller account registered successfully',
            );
          } else if (state.lessorRegistrationStatus ==
              RegistrationStatus.failure) {
            StatusDialog.showError(
              context: context,
              title: l10n.error,
              message:
                  state.registrationErrorMessage ?? 'Failed to register seller',
            );
          }

          if (state.lesseeRegistrationStatus == RegistrationStatus.success) {
            StatusDialog.showSuccess(
              context: context,
              title: l10n.success,
              message: 'Buyer account registered successfully',
            );
          } else if (state.lesseeRegistrationStatus ==
              RegistrationStatus.failure) {
            StatusDialog.showError(
              context: context,
              title: l10n.error,
              message:
                  state.registrationErrorMessage ?? 'Failed to register buyer',
            );
          }

          // Handle submit success/error feedback
          if (state.submitSuccess) {
            StatusDialog.showSuccess(
              context: context,
              title: l10n.success,
              message: l10n.success,
            );
          } else if ((state.submitErrorMessage ?? '').isNotEmpty) {
            StatusDialog.showError(
              context: context,
              title: l10n.error,
              message: state.submitErrorMessage,
            );
          }
        }
      },
      child: BlocBuilder<ContractFormBloc, ContractFormState>(
        builder: (context, state) {
          final formState = state is ContractFormData ? state : null;
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. General Info (ข้อมูลทั่วไป)
                  _buildGeneralInfoSection(l10n),

                  // 2. Lessor Info (ข้อมูลผู้ให้เช่า)
                  _buildLessorInfoSection(l10n),

                  // 3. Lessee Info (ข้อมูลผู้เช่า)
                  _buildLesseeInfoSection(l10n),

                  // 4. Asset Info (ข้อมูลทรัพย์ที่ให้เช่า)
                  AssetInfoSection(
                    l10n: l10n,
                    selectedPropertyType: _selectedPropertyType,
                    selectedCountry: _selectedCountry,
                    selectedProvince: _selectedProvince,
                    selectedDistrict: _selectedDistrict,
                    selectedSubdistrict: _selectedSubdistrict,
                    projectNameController: _projectNameController,
                    houseNumberController: _houseNumberController,
                    floorController: _floorController,
                    soiController: _soiController,
                    roadController: _roadController,
                    postalCodeController: _postalCodeController,
                    bedroomsController: _bedroomsController,
                    bathroomsController: _bathroomsController,
                    parkingController: _parkingController,
                    landSizeController: _landSizeController,
                    usableAreaController: _usableAreaController,
                  ),

                  // 5. Photos (รูปภาพเครื่องใช้ไฟฟ้า, เฟอร์นิเจอร์)
                  if (!widget.isReadOnly || _appliances.isNotEmpty) ...[
                    _buildPhotosSection(
                      l10n: l10n,
                      title: l10n.electrical_appliances_photos,
                      items: _appliances,
                    ),
                  ],
                  if (!widget.isReadOnly || _furniture.isNotEmpty) ...[
                    _buildPhotosSection(
                      l10n: l10n,
                      title: l10n.furniture_photos,
                      items: _furniture,
                    ),
                  ],

                  // 6. Contract Duration (ระยะเวลาเช่า)
                  _buildContractDurationSection(l10n),
                  const SizedBox(height: 24),

                  // 7. Payment Terms (ค่าเช่าและการชำระเงิน)
                  _buildPaymentTermsSection(l10n, formState),

                  // 8. Terms of Use (เงื่อนไขการใช้งาน)
                  _buildTermsOfUseSection(l10n),

                  if (formState?.isReadOnly ?? widget.isReadOnly) ...[
                    const SizedBox(height: 24),
                    // 9. Signature (ลายเซ็น - View Only)
                    _buildSignatureSection(l10n),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGeneralInfoSection(AppLocalizations l10n) {
    return AppFormSection(
      title: l10n.general_information,
      icon: 'assets/icons/form/info.svg',
      iconColor: const Color(0xFF1743C7),
      l10n: l10n,
      child: Row(
        children: [
          Expanded(
            child: AppFormTextField(
              controller: _contractNumberController,
              label: l10n.contract_number,
              l10n: l10n,
              isReadOnly: widget.isReadOnly,
              isRequired: false,
              enable: false,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppFormDropdownField<ContractType>(
              label: l10n.contract_type,
              value: _selectedContractType,
              l10n: l10n,
              isReadOnly: widget.isReadOnly,
              items: [
                DropdownMenuItem(
                  value: ContractType.rent,
                  child: Text(l10n.general_rental_contract),
                ),
                DropdownMenuItem(
                  value: ContractType.buy,
                  child: Text(l10n.purchase_sale_contract),
                ),
              ],
              onChanged: (ContractType? value) {
                if (!widget.isReadOnly) {
                  context.read<ContractFormBloc>().add(
                    ContractFormTypeChanged(value),
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ContractDatePicker(
              controller: _contractDateController,
              label: l10n.contract_date,
              l10n: l10n,
              isReadOnly: widget.isReadOnly,
              initialDate: _contractDate,
              parseThaiDate: _parseThaiDate,
              onDateSelected: (DateTime date) {
                if (!widget.isReadOnly) {
                  context.read<ContractFormBloc>().add(
                    ContractFormContractDateChanged(date),
                  );
                }
              },
              onTapPick: widget.isReadOnly
                  ? () {}
                  : () => _selectDate(
                      controller: _contractDateController,
                      initialDate: _contractDate,
                      onDateSelected: (date) {
                        if (!widget.isReadOnly) {
                          context.read<ContractFormBloc>().add(
                            ContractFormContractDateChanged(date),
                          );
                        }
                      },
                    ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: AppFormTextField(
              controller: _signingPlaceController,
              label: 'สถานที่ลงนาม',
              l10n: l10n,
              isReadOnly: widget.isReadOnly,
              isRequired: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessorInfoSection(AppLocalizations l10n) {
    return _buildPartyInfoSection(
      l10n: l10n,
      title: l10n.lessor_information,
      iconPath: 'assets/icons/form/user-2.svg',
      selectedType: _selectedLessorType,
      nameController: _lessorNameController,
      idCardController: _lessorIdCardController,
      addressController: _lessorAddressController,
      phoneController: _lessorPhoneController,
      emailController: _lessorEmailController,
      authorizedSignatoryController: _lessorAuthorizedSignatoryController,
      isLessor: true,
      onTypeChanged: (value) {
        context.read<ContractFormBloc>().add(
          ContractFormLessorTypeChanged(value),
        );
      },
    );
  }

  Widget _buildLesseeInfoSection(AppLocalizations l10n) {
    return _buildPartyInfoSection(
      l10n: l10n,
      title: l10n.lessee_information,
      iconPath: 'assets/icons/form/user-2.svg',
      selectedType: _selectedLesseeType,
      nameController: _lesseeNameController,
      idCardController: _lesseeIdCardController,
      addressController: _lesseeAddressController,
      phoneController: _lesseePhoneController,
      emailController: _lesseeEmailController,
      authorizedSignatoryController: _lesseeAuthorizedSignatoryController,
      isLessor: false,
      onTypeChanged: (value) {
        context.read<ContractFormBloc>().add(
          ContractFormLesseeTypeChanged(value),
        );
      },
    );
  }

  Widget _buildPartyInfoSection({
    required AppLocalizations l10n,
    required String title,
    required String iconPath,
    required String? selectedType,
    required TextEditingController nameController,
    required TextEditingController idCardController,
    required TextEditingController addressController,
    required TextEditingController phoneController,
    required TextEditingController emailController,
    required TextEditingController authorizedSignatoryController,
    required bool isLessor,
    required Function(String?) onTypeChanged,
  }) {
    return AppFormSection(
      title: title,
      icon: iconPath,
      iconColor: const Color(0xFF1743C7),
      l10n: l10n,
      rightWidget: !widget.isReadOnly
          ? BlocBuilder<ContractFormBloc, ContractFormState>(
              builder: (context, state) {
                if (state is! ContractFormData) {
                  return const SizedBox.shrink();
                }

                final registrationStatus = isLessor
                    ? state.lessorRegistrationStatus
                    : state.lesseeRegistrationStatus;
                final clientType = isLessor ? 'lessor' : 'lessee';

                return Align(
                  alignment: Alignment.centerRight,
                  child: _buildRegistrationButton(
                    l10n: l10n,
                    registrationStatus: registrationStatus,
                    clientType: clientType,
                  ),
                );
              },
            )
          : null,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: AppFormDropdownField<String>(
                  label: l10n.type,
                  value: selectedType,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  items: [
                    DropdownMenuItem(
                      value: 'person',
                      child: Text(l10n.individual),
                    ),
                    DropdownMenuItem(
                      value: 'company',
                      child: Text(l10n.juristic_person),
                    ),
                  ],
                  onChanged: onTypeChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: AppFormTextField(
                  controller: nameController,
                  label: l10n.full_name_or_company,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) {
                          context.read<ContractFormBloc>().add(
                            ContractFormFieldUpdated(
                              field: isLessor ? 'lessorName' : 'lesseeName',
                              value: value,
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: AppFormTextField(
                  controller: idCardController,
                  label: l10n.id_card_or_tax_id,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) {
                          context.read<ContractFormBloc>().add(
                            ContractFormFieldUpdated(
                              field: isLessor ? 'lessorIdCard' : 'lesseeIdCard',
                              value: value,
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: AppFormTextField(
                  controller: addressController,
                  label: l10n.address,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) {
                          context.read<ContractFormBloc>().add(
                            ContractFormFieldUpdated(
                              field: isLessor
                                  ? 'lessorAddress'
                                  : 'lesseeAddress',
                              value: value,
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppFormTextField(
                  controller: phoneController,
                  label: l10n.phone_number,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormTextField(
                  controller: emailController,
                  label: l10n.email,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormTextField(
                  controller: authorizedSignatoryController,
                  label: l10n.authorized_signatory,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  isRequired: false,
                ),
              ),
              const SizedBox(width: 16),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationButton({
    required AppLocalizations l10n,
    required RegistrationStatus registrationStatus,
    required String clientType,
  }) {
    if (registrationStatus == RegistrationStatus.loading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    if (registrationStatus == RegistrationStatus.success) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.emerald500,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Registered ✓',
                  style: GoogleFonts.anuphan(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            color: AppColors.baseDarkGrey,
            onPressed: () {
              context.read<ContractFormBloc>().add(
                ContractFormClearRegistration(type: clientType),
              );
            },
            tooltip: 'Reset',
          ),
        ],
      );
    }

    // Initial or Failure state - show "Create New Account" button
    return ElevatedButton.icon(
      onPressed: () => _showRegistrationDialog(clientType),
      icon: const Icon(Icons.add, size: 16),
      label: Text(l10n.create_new_account),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.emerald500,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }

  Future<void> _showRegistrationDialog(String type) async {
    final l10n = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;

    // Determine title and subtitle based on type
    final title = type == 'lessor'
        ? 'สร้างบัญชีผู้ให้เช่า'
        : 'สร้างบัญชีผู้เช่า';
    final subtitle = type == 'lessor'
        ? 'ลงทะเบียนข้อมูลผู้ให้เช่าใหม่ เพื่อทําสัญญา'
        : 'ลงทะเบียนข้อมูลผู้เช่าใหม่ เพื่อทําสัญญา';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580),
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with close button
                  Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.anuphan(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.baseDarkGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: GoogleFonts.anuphan(
                              fontSize: 14,
                              color: AppColors.baseDarkGrey,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.baseGrey,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          hoverColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Name and Phone Number (Two columns)
                  Row(
                    children: [
                      Expanded(
                        child: AppFormTextField(
                          controller: nameController,
                          label: l10n.full_name_or_company,
                          l10n: l10n,
                          isReadOnly: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FormFieldLabel(
                              label: l10n.phone_number,
                              isRequired: true,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: l10n.phone_number,
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: const Color(0xFFA4A7AE)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.baseGrey,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.baseGrey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.this_field_required;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Email (Full width)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FormFieldLabel(label: l10n.email, isRequired: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: l10n.email,
                          hintStyle: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFFA4A7AE)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.baseGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.baseGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary),
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.this_field_required;
                          }
                          if (!value.contains('@')) {
                            return l10n.enter_valid_email;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Password and Confirm Password (Two columns)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FormFieldLabel(
                              label: l10n.password,
                              isRequired: true,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: l10n.password,
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: const Color(0xFFA4A7AE)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.baseGrey,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.baseGrey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: SvgPicture.asset(
                                    obscurePassword
                                        ? 'assets/icons/form/eye-off.svg'
                                        : 'assets/icons/form/eye.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.baseGrey,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.this_field_required;
                                }
                                if (value.length < 6) {
                                  return l10n.password_length_error;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FormFieldLabel(
                              label: l10n.confirm_password,
                              isRequired: true,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: obscureConfirmPassword,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: l10n.password,
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: const Color(0xFFA4A7AE)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.baseGrey,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.baseGrey,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: SvgPicture.asset(
                                    obscureConfirmPassword
                                        ? 'assets/icons/form/eye-off.svg'
                                        : 'assets/icons/form/eye.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.baseGrey,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      obscureConfirmPassword =
                                          !obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.this_field_required;
                                }
                                if (value != passwordController.text) {
                                  return l10n.passwords_do_not_match;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Create Account Button (Full width)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.of(context).pop();
                          context.read<ContractFormBloc>().add(
                            ContractFormRegisterClient(
                              type: type,
                              data: {
                                'name': nameController.text.trim(),
                                'email': emailController.text.trim(),
                                'phone': phoneController.text.trim(),
                                'password': passwordController.text,
                                'password_confirmation':
                                    confirmPasswordController.text,
                              },
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        'สร้างบัญชี',
                        style: GoogleFonts.anuphan(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  Widget _buildPhotosSection({
    required AppLocalizations l10n,
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    final titleBaseStyle = GoogleFonts.anuphan(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    );

    return AppFormSection(
      title: title,
      titleWidget: widget.isReadOnly
          ? Text(title, style: titleBaseStyle)
          : RichText(
              text: TextSpan(
                style: titleBaseStyle,
                children: [
                  TextSpan(text: title),
                  TextSpan(
                    text: ' (ไม่บังคับ)',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.baseGrey),
                  ),
                ],
              ),
            ),
      icon: 'assets/icons/form/image.svg',
      iconColor: const Color(0xFF1743C7),
      l10n: l10n,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < items.length - 1 ? 16 : 0,
              ),
              child: ContractItemInput(
                key: ValueKey('item_${title.hashCode}_$index'),
                itemIndex: index + 1,
                initialName: item['name'] ?? '',
                initialDescription: item['description'] ?? '',
                photos:
                    (item['photos'] as List<dynamic>?)
                        ?.whereType<XFile>()
                        .toList() ??
                    (item['photo'] != null
                        ? [item['photo'] as XFile]
                        : <XFile>[]),
                isReadOnly: widget.isReadOnly,
                l10n: l10n,
                onNameChanged: (value) {
                  setState(() {
                    items[index]['name'] = value;
                  });
                },
                onDescriptionChanged: (value) {
                  setState(() {
                    items[index]['description'] = value;
                  });
                },
                onPhotosChanged: (photos) {
                  setState(() {
                    items[index]['photos'] = photos;
                    // Remove old 'photo' key if it exists
                    items[index].remove('photo');
                  });
                },
                onRemove: widget.isReadOnly
                    ? null
                    : () {
                        setState(() {
                          items.removeAt(index);
                        });
                      },
              ),
            );
          }),
          if (!widget.isReadOnly) ...[
            if (items.isNotEmpty) const SizedBox(height: 16),
            DashedAddButton(
              onTap: () {
                setState(() {
                  items.add({
                    'name': '',
                    'description': '',
                    'photos': <XFile>[],
                  });
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContractDurationSection(AppLocalizations l10n) {
    return AppFormSection(
      title: l10n.lease_period,
      icon: 'assets/icons/form/coin-stack-1.svg',
      iconColor: const Color(0xFF1743C7),
      l10n: l10n,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ContractDatePicker(
                  controller: _startDateController,
                  label: l10n.contract_start_date,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  initialDate: _startDate,
                  lastDate: _endDate,
                  parseThaiDate: _parseThaiDate,
                  onDateSelected: (DateTime date) {
                    if (!widget.isReadOnly) {
                      context.read<ContractFormBloc>().add(
                        ContractFormStartDateChanged(date),
                      );
                    }
                  },
                  onTapPick: widget.isReadOnly
                      ? () {}
                      : () => _selectDate(
                          controller: _startDateController,
                          initialDate: _startDate,
                          lastDate: _endDate,
                          onDateSelected: (date) {
                            if (!widget.isReadOnly) {
                              context.read<ContractFormBloc>().add(
                                ContractFormStartDateChanged(date),
                              );
                            }
                          },
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ContractDatePicker(
                  controller: _endDateController,
                  label: l10n.contract_end_date,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  initialDate: _endDate ?? _startDate,
                  firstDate: _startDate,
                  parseThaiDate: _parseThaiDate,
                  onDateSelected: (DateTime date) {
                    if (!widget.isReadOnly) {
                      context.read<ContractFormBloc>().add(
                        ContractFormEndDateChanged(date),
                      );
                    }
                  },
                  onTapPick: widget.isReadOnly
                      ? () {}
                      : () => _selectDate(
                          controller: _endDateController,
                          initialDate: _endDate ?? _startDate,
                          firstDate: _startDate,
                          onDateSelected: (date) {
                            if (!widget.isReadOnly) {
                              context.read<ContractFormBloc>().add(
                                ContractFormEndDateChanged(date),
                              );
                            }
                          },
                        ),
                  customValidator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.this_field_required;
                    }
                    final date = _parseThaiDate(value);
                    if (date == null) {
                      return 'รูปแบบวันที่ไม่ถูกต้อง';
                    }
                    if (_startDate != null && date.isBefore(_startDate!)) {
                      return 'วันที่สิ้นสุดต้องอยู่หลังวันที่เริ่มต้น';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormTextField(
                  controller: _leasePeriodController,
                  label: l10n.lease_period,
                  l10n: l10n,
                  isReadOnly: true,
                  isRequired: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormDropdownField<String>(
                  label: l10n.lease_renewal_format,
                  value: _selectedRenewalFormat,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  isRequired: false,
                  items: const [],
                  onChanged: (value) {
                    setState(() {
                      _selectedRenewalFormat = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppFormTextField(
            controller: _renewalConditionsController,
            label: l10n.renewal_conditions,
            l10n: l10n,
            maxLines: 3,
            isReadOnly: widget.isReadOnly,
            isRequired: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTermsSection(
    AppLocalizations l10n,
    ContractFormData? formState,
  ) {
    final banks = formState?.banks ?? const <Bank>[];
    final sortedBanks = List<Bank>.from(banks)
      ..sort(
        (a, b) => (a.name ?? '').toLowerCase().compareTo(
          (b.name ?? '').toLowerCase(),
        ),
      );

    return AppFormSection(
      title: l10n.rental_fee_and_payment,
      icon: 'assets/icons/form/coin-stack-1.svg',
      iconColor: const Color(0xFF1743C7),
      l10n: l10n,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppFormNumberField(
                  controller: _rentalFeeController,
                  label: l10n.rental_fee,
                  isPrice: true,
                  suffixText: l10n.baht_per_month,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) {
                          context.read<ContractFormBloc>().add(
                            ContractFormFieldUpdated(
                              field: 'rentalFee',
                              value: value,
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormNumberField(
                  controller: _commonFeeController,
                  label: l10n.common_fee,
                  isPrice: true,
                  suffixText: l10n.baht_per_month,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) {
                          context.read<ContractFormBloc>().add(
                            ContractFormFieldUpdated(
                              field: 'commonFee',
                              value: value,
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormNumberField(
                  controller: _serviceFeeController,
                  label: l10n.other_service_fee,
                  isPrice: true,
                  suffixText: l10n.baht_per_month,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  isRequired: false,
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) {
                          context.read<ContractFormBloc>().add(
                            ContractFormFieldUpdated(
                              field: 'serviceFee',
                              value: value,
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormNumberField(
                  controller: _totalMonthlyPaymentController,
                  label: l10n.total_monthly_payment,
                  suffixText: l10n.baht_per_month,
                  l10n: l10n,
                  isReadOnly: true,
                  isRequired: false,
                  enable: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppFormNumberField(
                  controller: _advanceRentalController,
                  label: l10n.advance_rental,
                  isPrice: true,
                  suffixText: l10n.baht,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) {
                          context.read<ContractFormBloc>().add(
                            ContractFormFieldUpdated(
                              field: 'advanceRental',
                              value: value,
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormNumberField(
                  controller: _damageDepositController,
                  label: l10n.damage_deposit,
                  isPrice: true,
                  suffixText: l10n.baht,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  onChanged: widget.isReadOnly
                      ? null
                      : (value) {
                          context.read<ContractFormBloc>().add(
                            ContractFormFieldUpdated(
                              field: 'damageDeposit',
                              value: value,
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormNumberField(
                  controller: _totalPaymentController,
                  label: l10n.total_payment_before_move_in,
                  isPrice: true,
                  suffixText: l10n.baht,
                  l10n: l10n,
                  isReadOnly: true,
                  isRequired: false,
                  enable: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormNumberField(
                  controller: _paymentDueDateController,
                  label: l10n.payment_due_date,
                  suffixText: l10n.of_every_month,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppFormTextField(
                  controller: _waterFeeController,
                  label: l10n.water_fee,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  isRequired: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FormFieldLabel(label: l10n.payment_channel),
                    const SizedBox(height: 8),
                    TypeAheadField<Bank>(
                      controller: _paymentChannelController,
                      builder: (context, controller, focusNode) {
                        final theme = Theme.of(context);
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          enabled: !widget.isReadOnly,
                          style: theme.textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: l10n.payment_channel,
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFA4A7AE),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.baseGrey,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.baseGrey,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: widget.isReadOnly
                                    ? AppColors.baseGrey
                                    : AppColors.primary,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.baseGrey,
                              ),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            suffixIcon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: Color(0xFFA4A7AE),
                            ),
                            filled: widget.isReadOnly,
                            fillColor: widget.isReadOnly ? Colors.white : null,
                          ),
                          onChanged: widget.isReadOnly
                              ? null
                              : (value) => context.read<ContractFormBloc>().add(
                                  ContractFormPaymentChannelChanged(value),
                                ),
                        );
                      },
                      suggestionsCallback: (pattern) {
                        if (widget.isReadOnly) return const <Bank>[];

                        if (pattern.isEmpty) return sortedBanks;

                        final search = pattern.toLowerCase();
                        return sortedBanks
                            .where(
                              (bank) => (bank.name ?? '')
                                  .toLowerCase()
                                  .contains(search),
                            )
                            .toList();
                      },
                      itemBuilder: (context, bank) {
                        return ListTile(title: Text(bank.name ?? ''));
                      },
                      onSelected: (bank) {
                        _paymentChannelController.text = bank.name ?? '';
                        context.read<ContractFormBloc>().add(
                          ContractFormPaymentChannelChanged(bank.name),
                        );
                      },
                      emptyBuilder: (context) => ListTile(
                        title: Text(
                          l10n.no_data_found,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.baseGrey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormTextField(
                  controller: _branchController,
                  label: l10n.branch,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                  isRequired: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppFormTextField(
                  controller: _accountNameController,
                  label: l10n.account_name,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppFormTextField(
                  controller: _accountNumberController,
                  label: l10n.account_number,
                  l10n: l10n,
                  isReadOnly: widget.isReadOnly,
                ),
              ),
              // Mockup spaces 3 items
              const SizedBox(width: 16),
              const Spacer(),
              const SizedBox(width: 16),
              const Spacer(),
              const SizedBox(width: 16),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermsOfUseSection(AppLocalizations l10n) {
    return AppFormSection(
      title: l10n.terms_and_conditions_section,
      icon: 'assets/icons/form/feather-1.svg',
      iconColor: const Color(0xFF1743C7),
      l10n: l10n,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppFormTextField(
            controller: _additionalConditionsController,
            label: l10n.additional_conditions_optional,
            l10n: l10n,
            maxLines: 4,
            isReadOnly: widget.isReadOnly,
            isRequired: false,
          ),
          const SizedBox(height: 16),
          AppFormTextField(
            controller: _flexibleTermsController,
            label: 'เงื่อนไขยืดหยุ่น',
            l10n: l10n,
            maxLines: 4,
            isReadOnly: widget.isReadOnly,
            isRequired: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureSection(AppLocalizations l10n) {
    final contract = widget.initialData?.originalContract;

    // Hide section if both signed URLs and dates are null
    if (contract?.sellerSignedContractUrl == null &&
        contract?.buyerSignedContractUrl == null &&
        contract?.sellerSignedAt == null &&
        contract?.buyerSignedAt == null) {
      return const SizedBox.shrink();
    }

    final sellerSignedUrl = contract?.sellerSignedContractUrl;
    final buyerSignedUrl = contract?.buyerSignedContractUrl;
    final isSellerSigned =
        sellerSignedUrl != null || contract?.sellerSignedAt != null;
    final isBuyerSigned =
        buyerSignedUrl != null || contract?.buyerSignedAt != null;

    return AppFormSection(
      title: l10n.confirmation_and_signature,
      icon: 'assets/icons/form/menu-2.svg',
      iconColor: const Color(0xFF1743C7),
      l10n: l10n,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: InkWell(
              onTap: sellerSignedUrl != null
                  ? () async {
                      final uri = Uri.parse(sellerSignedUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ไม่สามารถเปิด URL ได้'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  : null,
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    constraints: const BoxConstraints(minHeight: 280),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.baseLightGrey),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.gesture,
                      size: 64,
                      color: isSellerSigned
                          ? AppColors.success600
                          : AppColors.gray800,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    '(${_lessorNameController.text.isNotEmpty ? _lessorNameController.text : l10n.test_system})',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.lessor,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contract?.sellerSignedAt != null
                        ? DateFormat(
                            'dd MMM yyyy',
                            'th_TH',
                          ).format(contract!.sellerSignedAt!)
                        : DateFormat(
                            'dd MMM yyyy',
                            'th_TH',
                          ).format(DateTime.now()),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.baseGrey),
                    textAlign: TextAlign.center,
                  ),
                  if (sellerSignedUrl != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'คลิกเพื่อดูสัญญาที่ลงนามแล้ว',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success600,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: buyerSignedUrl != null
                  ? () async {
                      final uri = Uri.parse(buyerSignedUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ไม่สามารถเปิด URL ได้'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  : null,
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    constraints: const BoxConstraints(minHeight: 280),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.baseLightGrey),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.gesture,
                      size: 64,
                      color: isBuyerSigned
                          ? AppColors.success600
                          : AppColors.gray800,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    '(${_lesseeNameController.text.isNotEmpty ? _lesseeNameController.text : l10n.test_system})',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.lessee,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    contract?.buyerSignedAt != null
                        ? DateFormat(
                            'dd MMM yyyy',
                            'th_TH',
                          ).format(contract!.buyerSignedAt!)
                        : DateFormat(
                            'dd MMM yyyy',
                            'th_TH',
                          ).format(DateTime.now()),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.baseGrey),
                    textAlign: TextAlign.center,
                  ),
                  if (buyerSignedUrl != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'คลิกเพื่อดูสัญญาที่ลงนามแล้ว',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success600,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
