import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show rootBundle, PlatformException, MethodChannel;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/models/condo_project_model.dart';
import 'package:youragent/data/models/property_model.dart';
import 'package:youragent/domain/entities/property_enums.dart';
import 'package:youragent/domain/entities/property_image.dart';
import 'package:youragent/features/property/bloc/property_form_bloc.dart';
import 'package:youragent/features/property/bloc/property_form_event.dart';
import 'package:youragent/features/property/bloc/property_form_state.dart';
import 'package:youragent/features/property/widgets/property_form_inputs.dart';
import 'package:youragent/widgets/form_fields/app_form_text_field.dart';
import 'package:youragent/features/property/widgets/sections/property_additional_details_section.dart';
import 'package:youragent/features/property/widgets/sections/property_images_section.dart';
import 'package:youragent/features/property/widgets/sections/property_type_details_section.dart';
import 'package:youragent/features/property/widgets/thai_address_typeahead.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/badges/app_badge.dart';

/// Reusable Property Form Widget
/// Can be used for both create and edit modes
/// Uses BLoC for state management to improve performance and correctness
class PropertyForm extends StatefulWidget {
  final PropertyModel? property; // null for create, populated for edit
  final Function(Map<String, dynamic> formData, List<XFile> newPhotos) onSubmit;
  final bool isSubmitting;
  final Function(VoidCallback submitCallback)?
  onFormReady; // Callback to expose submit method
  final bool isReadOnly; // Read-only mode for view screen

  const PropertyForm({
    super.key,
    this.property,
    required this.onSubmit,
    this.isSubmitting = false,
    this.onFormReady,
    this.isReadOnly = false,
  });

  @override
  State<PropertyForm> createState() => _PropertyFormState();
}

class _PropertyFormState extends State<PropertyForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isMapReady = false;
  bool _hasScrolledToError = false;
  final Map<String, GlobalKey<FormFieldState<dynamic>>> _fieldKeys = {};

  // Thai Address Data
  List<Map<String, dynamic>> _thaiAddresses = [];
  bool _isLoadingAddress = true;

  // Form controllers
  late final TextEditingController _codeController; // Property code (รหัส)
  late final TextEditingController
  _builtYearController; // Renamed from _builtController
  late final TextEditingController _propertyNameController;
  late final TextEditingController _soiController;
  late final TextEditingController _roadController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;
  late final TextEditingController _garageController;
  late final TextEditingController _priceController;
  late final TextEditingController _landSizeController;
  late final TextEditingController _buildingSizeController;
  late final TextEditingController _availableFromController;
  late final TextEditingController
  _descriptionController; // Description / Details
  late final TextEditingController
  _additionalDetailsController; // New for "รายละเอียดเพิ่มเติม"
  late final TextEditingController _houseNumberController;
  late final TextEditingController _floorController;
  late final TextEditingController _districtController;
  late final TextEditingController _subdistrictController;
  late final TextEditingController _cityController;
  late final TextEditingController
  _provinceController; // New controller for Province
  late final TextEditingController _stateController;
  late final TextEditingController _countryController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _addressController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  // Condo-specific controllers
  late final TextEditingController _towerController;
  late final TextEditingController _condoFloorController;
  late final TextEditingController _unitNoController;
  late final TextEditingController
  _condoProjectController; // For TypeAhead search

  // House-specific controllers
  late final TextEditingController _villageNameController;
  late final TextEditingController _mooController;
  late final TextEditingController _houseNotesController;

  // Form values - using enums for type-safe handling
  PropertyType? _selectedType;
  PropertyStatus? _selectedStatus;
  SaleType? _selectedSaleType;
  PropertyStyle? _selectedPropertyStyle;
  PropertyColor? _selectedPropertyColor;
  Direction? _selectedDirection;
  Country? _selectedCountry;

  // Type-specific form values
  CondoProject? _selectedCondoProject;
  String? _houseSubtype;
  String? _parkingType;
  bool? _isCornerPlot;
  // String? _selectedProvince; // Removed
  // String? _selectedDistrict; // Removed
  // String? _selectedSubdistrict; // Removed
  DateTime? _builtDate;
  DateTime? _availableFromDate;

  // Options

  // Multi-select tags (per Figma PropertyImagesSection + /public/info)
  List<String> _selectedHighlights = [];
  List<String> _selectedCommonAreas = [];
  List<String> _selectedFurniture = [];
  List<String> _selectedAirConditioning = [];

  // Available options for multi-select (loaded from /public/info API)
  List<String> _highlightOptions = [];
  List<String> _commonAreaOptions = [];
  List<String> _furnitureOptions = [];
  List<String> _airConditioningOptions = [];

  // Single select options (loaded from /public/info API)
  List<String> _floorsOptions = [];
  List<String> _bedroomsOptions = [];
  List<String> _bathroomsOptions = [];
  List<String> _parkingSpacesOptions = [];

  // Track loading state for filter options
  bool _isLoadingFilterOptions = false;

  // Location
  // Use Completer as shown in official documentation: https://pub.dev/packages/google_maps_flutter
  final Completer<GoogleMapController> _mapControllerCompleter =
      Completer<GoogleMapController>();
  LatLng? _selectedLocation;
  Marker? _locationMarker;
  bool _locationLoadedFromApi =
      false; // Flag to track if location was loaded from API

  // Debounce timer for address field changes to avoid too many geocoding calls
  Timer? _geocodeDebounceTimer;
  bool _isUpdatingFromMap = false; // Flag to prevent circular updates
  bool _isManualAddressInput =
      false; // Flag to prevent BLoC from overwriting manual address fields
  bool _isInitializing =
      false; // Flag to silence listeners during data population
  bool _isSyncing = false; // Flag to silence listeners during BLoC state sync

  // Photos
  final List<XFile> _newPhotos = [];
  final List<PropertyImage> _existingPhotos = [];

  // House colors

  // Directions - now using Direction enum from domain/entities/direction.dart

  bool get _isEditMode => widget.property != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // FIX: Sync state on init to prevent data loss on window resize
    // When the browser window is resized, the widget is disposed and recreated.
    // New controllers are initialized empty, but BLoC still has the data.
    // BlocListener only fires on state changes, so we need to manually sync on init.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final bloc = context.read<PropertyFormBloc>();
        final state = bloc.state;
        if (state is PropertyFormData) {
          // BLoC already has data, sync it to controllers immediately
          _syncStateFromBloc(state);
        }
      }
    });

    // Detail/view mode: populate controllers directly from response data.
    // IMPORTANT: In read-only mode we must not auto-mutate/derive values
    // (no reverse-geocode, no district lookup overrides, no background services).
    if (_isEditMode && widget.isReadOnly) {
      _loadPropertyData();
      // STRICT: In read-only mode, ensure NO background services are triggered
      // All data should be displayed as-is from API
    }

    // BLoC Initialization Notes:
    // Parent screens are responsible for dispatching PropertyFormInitialized:
    // - Edit mode: PropertyEditScreen listener dispatches with flag to prevent duplicates
    // - Detail mode: PropertyDetailScreen handles initialization
    // - Create mode: PropertyCreateScreen handles initialization
    // DO NOT dispatch PropertyFormInitialized here to avoid race conditions.

    // Expose submit method to parent widget
    debugPrint('PropertyForm: Setting up form ready callback');
    widget.onFormReady?.call(submitForm);

    // Delay map initialization on web to prevent IntersectionObserver errors
    // The DOM element needs to be fully created before Google Maps can observe it
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Use a longer delay and multiple frame callbacks to ensure DOM is ready
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isMapReady = true;
                });
              }
            });
          }
        });
      });
    } else {
      _isMapReady = true;
    }
  }

  Future<void> _loadThaiAddresses() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/etc/thai_address.json',
      );
      final List<dynamic> data = json.decode(response);
      setState(() {
        _thaiAddresses = data.cast<Map<String, dynamic>>();
        _isLoadingAddress = false;
      });

      // After addresses are loaded, try to lookup district if we have location data
      if (_isEditMode && widget.property?.propertyLocation != null) {
        final location = widget.property!.propertyLocation!;
        final subdistrict = _getSubdistrictFromControllerOrCity(
          _subdistrictController.text,
          location.city,
        );
        _lookupDistrictFromThaiAddress(location.postalCode, subdistrict);
      }
    } catch (e) {
      debugPrint('Error loading thai address: $e');
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  /// Generic helper to extract value from controller or fallback field.
  /// Removes common Thai address prefixes if present.
  /// Common prefixes: ตำบล, อำเภอ, จังหวัด, เมือง, etc.
  String _extractValueWithPrefixRemoval(
    String controllerText,
    String? fallbackValue,
    List<String> prefixes,
  ) {
    if (controllerText.isNotEmpty) {
      return controllerText;
    }

    final value = fallbackValue?.trim();
    if (value == null || value.isEmpty) {
      return '';
    }

    // Try each prefix and remove the first matching one
    for (final prefix in prefixes) {
      if (value.startsWith(prefix)) {
        return value.substring(prefix.length).trim();
      }
    }

    // No prefix matched, return value as-is
    return value;
  }

  /// Extracts subdistrict from controller text or falls back to city field.
  /// Removes common subdistrict/district prefixes if present.
  String _getSubdistrictFromControllerOrCity(
    String controllerText,
    String? city,
  ) {
    return _extractValueWithPrefixRemoval(controllerText, city, [
      'ตำบล',
      'อำเภอ',
      'เมือง',
    ]);
  }

  /// Extracts province/state from controller text or falls back to state field.
  /// Removes common province prefixes if present.
  String _getProvinceFromControllerOrState(
    String controllerText,
    String? state,
  ) {
    return _extractValueWithPrefixRemoval(controllerText, state, [
      'จังหวัด',
      'อำเภอ',
      'เมือง',
    ]);
  }

  /// Look up district (amphoe) from Thai address data using postal code and subdistrict
  void _lookupDistrictFromThaiAddress(String? postalCode, String subdistrict) {
    if (postalCode == null ||
        postalCode.isEmpty ||
        _isLoadingAddress ||
        _thaiAddresses.isEmpty) {
      debugPrint(
        'District lookup skipped: postalCode=$postalCode, isLoading=$_isLoadingAddress, addresses=${_thaiAddresses.length}',
      );
      return;
    }

    try {
      debugPrint(
        'Looking up district: postalCode=$postalCode, subdistrict=$subdistrict',
      );

      // First, try to find exact match by postal code and subdistrict
      var matchingAddress = _thaiAddresses.firstWhere((address) {
        final addressZipcode = address['zipcode']?.toString();
        final addressDistrict = address['district']?.toString();
        return addressZipcode == postalCode &&
            (subdistrict.isEmpty || addressDistrict == subdistrict);
      }, orElse: () => <String, dynamic>{});

      // If no exact match and subdistrict is provided, try partial match
      if (matchingAddress.isEmpty && subdistrict.isNotEmpty) {
        matchingAddress = _thaiAddresses.firstWhere((address) {
          final addressZipcode = address['zipcode']?.toString();
          final addressDistrict = address['district']?.toString();
          return addressZipcode == postalCode &&
              addressDistrict != null &&
              addressDistrict.contains(subdistrict);
        }, orElse: () => <String, dynamic>{});
      }

      // If still no match, just get first address with matching postal code
      if (matchingAddress.isEmpty) {
        matchingAddress = _thaiAddresses.firstWhere((address) {
          final addressZipcode = address['zipcode']?.toString();
          return addressZipcode == postalCode;
        }, orElse: () => <String, dynamic>{});
      }

      if (matchingAddress.isNotEmpty && matchingAddress['amphoe'] != null) {
        final districtName = matchingAddress['amphoe'].toString();
        debugPrint('Found district: $districtName');
        setState(() {
          _districtController.text = districtName;
          // Also update city controller with district name if it's empty
          if (_cityController.text.isEmpty) {
            _cityController.text = districtName;
          }
        });
      } else {
        debugPrint(
          'No district found for postalCode=$postalCode, subdistrict=$subdistrict',
        );
      }
    } catch (e) {
      debugPrint('Error looking up district: $e');
    }
  }

  void _initializeControllers() {
    _codeController = TextEditingController();
    _builtYearController = TextEditingController();
    _propertyNameController = TextEditingController();
    _soiController = TextEditingController();
    _roadController = TextEditingController();
    _bedroomsController = TextEditingController();
    _bathroomsController = TextEditingController();
    _garageController = TextEditingController();
    _priceController = TextEditingController();
    _landSizeController = TextEditingController();
    _buildingSizeController = TextEditingController();
    _availableFromController = TextEditingController();
    _descriptionController = TextEditingController();
    _additionalDetailsController =
        TextEditingController(); // Init new controller
    _houseNumberController = TextEditingController();
    _floorController = TextEditingController();
    _districtController = TextEditingController();
    _subdistrictController = TextEditingController();
    _cityController =
        TextEditingController(); // Amper/District in some contexts or City
    _provinceController = TextEditingController(); // Province
    _stateController = TextEditingController();
    _countryController = TextEditingController();
    _postalCodeController = TextEditingController();
    _addressController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();

    // Condo-specific controllers
    _towerController = TextEditingController();
    _condoFloorController = TextEditingController();
    _unitNoController = TextEditingController();
    _condoProjectController = TextEditingController();

    // House-specific controllers
    _villageNameController = TextEditingController();
    _mooController = TextEditingController();
    _houseNotesController = TextEditingController();

    // Add listeners to address controllers to sync with map (edit mode only)
    if (!widget.isReadOnly) {
      _setupAddressFieldListeners();
    }
  }

  void _setupAddressFieldListeners() {
    // Listen to address field changes and geocode to update map
    // Use debouncing to avoid too many API calls
    // NOTE: _houseNumberController, _soiController, and _roadController
    // do NOT trigger map/address updates - they are manual input only
    // _houseNumberController.addListener(_onAddressFieldChanged); // Removed - manual input only
    // _soiController.addListener(_onAddressFieldChanged); // Removed - manual input only
    // _roadController.addListener(_onAddressFieldChanged); // Removed - manual input only
    _provinceController.addListener(_onAddressFieldChanged);
    _districtController.addListener(_onThaiAddressFieldChanged);
    _subdistrictController.addListener(_onThaiAddressFieldChanged);
    _postalCodeController.addListener(_onThaiAddressFieldChanged);

    // Add listeners to manual address fields to update full address composition
    _houseNumberController.addListener(_updateFullAddress);
    _soiController.addListener(_updateFullAddress);
    _roadController.addListener(_updateFullAddress);
    _subdistrictController.addListener(_updateFullAddress);
    _districtController.addListener(_updateFullAddress);
    _provinceController.addListener(_updateFullAddress);
    _postalCodeController.addListener(_updateFullAddress);
  }

  void _onThaiAddressSelected(Map<String, dynamic> suggestion) {
    // Set flags to prevent listener from triggering geocode and prevent rollback
    _isUpdatingFromMap = true;
    _isManualAddressInput = true;

    // FIXED: Update ALL 4 fields immediately using data from the specific selected item
    // This ensures consistency - all fields come from the same selected suggestion
    setState(() {
      // Extract all values from the selected suggestion
      final district = suggestion['district']?.toString().trim() ?? '';
      final amphoe = suggestion['amphoe']?.toString().trim() ?? '';
      final province = suggestion['province']?.toString().trim() ?? '';
      final zipcode = suggestion['zipcode']?.toString().trim() ?? '';

      // Update ALL 4 Thai address fields from the selected item
      _subdistrictController.text = district;
      _districtController.text = amphoe;
      _provinceController.text = province;
      _stateController.text = province; // Keep state in sync with province
      _postalCodeController.text = zipcode;
    });

    // Reset flags after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _isUpdatingFromMap = false;
      }
    });

    // Update map location based on selected address
    _geocodeFromAddress();
  }

  void _onThaiAddressFieldChanged() {
    // FIXED: Simplified to only trigger geocoding, NOT auto-fill fields
    // Auto-filling should ONLY happen in TypeAheadField.onSelected callback
    // This prevents infinite loops where manual edits get overwritten

    // 🛑 STOP if syncing from BLoC (prevent geocoding when setting controller values from BLoC state)
    if (_isSyncing) return;

    // SILENCE: Return immediately if initializing (prevent auto-calculations during data load)
    if (_isInitializing) return;

    // Skip if update is coming from map (to prevent circular updates)
    if (_isUpdatingFromMap) return;

    // Mark that user is manually typing address fields
    // This prevents BLoC sync from overwriting manual input
    _isManualAddressInput = true;

    // Update full address composition when Thai address fields change
    _updateFullAddress();

    // Cancel previous timer
    _geocodeDebounceTimer?.cancel();

    // Debounce geocoding by 800ms to avoid too many API calls
    _geocodeDebounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        if (_shouldAttemptGeocodeFromManualFields()) {
          _geocodeFromAddress();
        }
      }
    });
  }

  void _onAddressFieldChanged() {
    // 🛑 STOP if syncing from BLoC (prevent geocoding when setting controller values from BLoC state)
    if (_isSyncing) return;

    // SILENCE: Return immediately if initializing (prevent auto-calculations during data load)
    if (_isInitializing) return;

    // Skip if update is coming from map (to prevent circular updates)
    // เมื่อปักหมุดเอง - ไม่ควร trigger geocode เพราะ fields จะถูกอัปเดตจาก reverse geocode
    if (_isUpdatingFromMap) return;

    // Mark that user is manually typing address fields
    // This prevents BLoC sync from overwriting manual input
    // เมื่อพิมพ์ฟิลด์เอง - ตั้ง flag นี้เพื่อป้องกันไม่ให้ BLoC sync overwrite
    _isManualAddressInput = true;

    // Update full address composition when address fields change
    _updateFullAddress();

    // Cancel previous timer
    _geocodeDebounceTimer?.cancel();

    // Debounce geocoding by 800ms to avoid too many API calls
    _geocodeDebounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        if (_shouldAttemptGeocodeFromManualFields()) {
          _geocodeFromAddress();
        }
      }
    });
  }

  /// Helper method to add Thai label prefix if it doesn't exist
  /// Returns the text with label prefix if needed
  /// Add label prefix if not already present, preventing duplicate prefixes
  /// Handles both English (case-insensitive) and Thai (direct) labels
  String _addLabelIfNotExists(String text, String label) {
    if (text.isEmpty) return text;
    final trimmed = text.trim();
    
    // Check if text starts with label (case insensitive for English, direct for Thai)
    // This prevents double prefixes like "ซอย ซอย 3" or "Soi Soi 3"
    final textLower = trimmed.toLowerCase();
    final labelLower = label.toLowerCase();
    
    // For Thai labels, check direct match first (more reliable)
    if (trimmed.startsWith(label)) {
      return trimmed;
    }
    
    // For English labels, check case-insensitive match
    if (textLower.startsWith(labelLower)) {
      return trimmed;
    }
    
    return '$label $trimmed';
  }

  /// Update full address by composing individual address fields
  /// Format: "[HouseNo] [ซอย Alley] [ถนน Road] [ตำบล Subdistrict] [เขต District] [จังหวัด Province] [Zipcode]"
  ///
  /// This method is the source of truth for the full address field.
  /// It composes the address from individual field controllers, ensuring
  /// that manual edits to any field are reflected in the full address.
  /// Thai labels (ซอย, ถนน, จังหวัด, เขต, ตำบล) are automatically added if they don't exist.
  void _updateFullAddress() {
    // Skip if syncing from BLoC or initializing (to prevent overwriting during data load)
    if (_isSyncing || _isInitializing) return;

    // Collect all address components (filter out empty strings)
    final components = <String>[];

    // House Number (no label)
    final houseNumber = _houseNumberController.text.trim();
    if (houseNumber.isNotEmpty) {
      components.add(houseNumber);
    }

    // Alley (Soi) - add "ซอย" label if not exists
    final alley = _soiController.text.trim();
    if (alley.isNotEmpty) {
      components.add(_addLabelIfNotExists(alley, 'ซอย'));
    }

    // Road - add "ถนน" label if not exists
    final road = _roadController.text.trim();
    if (road.isNotEmpty) {
      components.add(_addLabelIfNotExists(road, 'ถนน'));
    }

    // Subdistrict (ตำบล) - add "ตำบล" label if not exists
    final subdistrict = _subdistrictController.text.trim();
    if (subdistrict.isNotEmpty) {
      components.add(_addLabelIfNotExists(subdistrict, 'ตำบล'));
    }

    // District (อำเภอ/เขต) - add "เขต" label if not exists
    final district = _districtController.text.trim();
    if (district.isNotEmpty) {
      components.add(_addLabelIfNotExists(district, 'เขต'));
    }

    // Province (จังหวัด) - add "จังหวัด" label if not exists
    final province = _provinceController.text.trim();
    if (province.isNotEmpty) {
      components.add(_addLabelIfNotExists(province, 'จังหวัด'));
    }

    // Zipcode (รหัสไปรษณีย์) - no label
    final zipcode = _postalCodeController.text.trim();
    if (zipcode.isNotEmpty) {
      components.add(zipcode);
    }

    // Join all components with spaces (smart filtering already done above)
    final fullAddress = components.join(' ');

    // Only update if the value has changed to prevent unnecessary updates
    // This also prevents potential infinite loops if addressController had a listener
    if (_addressController.text.trim() != fullAddress) {
      _addressController.text = fullAddress;
    }
  }

  bool _shouldAttemptGeocodeFromManualFields() {
    // NOTE: _houseNumberController, _soiController, and _roadController
    // are manual input only and do NOT trigger geocoding

    // Thai address fields only
    final hasProvince = _provinceController.text.trim().isNotEmpty;
    final hasDistrict = _districtController.text.trim().isNotEmpty;
    final hasSubdistrict = _subdistrictController.text.trim().isNotEmpty;
    final hasPostal = _postalCodeController.text.trim().isNotEmpty;

    final hasAnyThai =
        hasProvince || hasDistrict || hasSubdistrict || hasPostal;

    // Only geocode when Thai address fields are available
    // Manual fields (house number, soi, road) are not used for geocoding
    return hasAnyThai;
  }

  List<String> _buildGeocodeCandidates() {
    // NOTE: _houseNumberController, _soiController, and _roadController
    // are NOT included in geocoding candidates - they are manual input only
    final subdistrict = _subdistrictController.text.trim();
    final district = _districtController.text.trim();
    final province = _provinceController.text.trim();
    final postal = _postalCodeController.text.trim();
    final country = _countryController.text.trim().isNotEmpty
        ? _countryController.text.trim()
        : (_selectedCountry?.labelTh.trim() ?? '');

    // Thai-only: search with whatever exists (still do a gentle fallback chain).
    final candidates = <String>[
      _joinAddressParts([subdistrict, district, province, postal, country]),
      _joinAddressParts([district, province, postal, country]),
      _joinAddressParts([province, postal, country]),
      _joinAddressParts([province, country]),
    ];

    return candidates.where((e) => e.isNotEmpty).toList();
  }

  String _joinAddressParts(List<String> parts) {
    final normalized = parts.where((p) => p.trim().isNotEmpty).toList();
    return normalized.join(', ');
  }

  void _loadPropertyData() {
    // Set initialization flag to silence listeners during data population
    _isInitializing = true;

    try {
      if (!_isEditMode) {
        // Set default values for new property using enums (ONLY for create mode)
        _selectedType = PropertyType.house;
        _selectedStatus = PropertyStatus.available;
        _selectedPropertyColor = PropertyColor.white;
        _selectedDirection = Direction.north;
        _selectedCountry = Country.thailand;
        return;
      }

      final property = widget.property!;
      final specs = property.specs;
      final location = property.propertyLocation;

      // Load specs data
      // STRICT: In edit/view mode, DO NOT set default values - keep null if API returns null
      if (specs != null) {
        // Only set if API provided value (no fallback to 'Unknown')
        if (specs.name != null) {
          _propertyNameController.text = specs.name!;
        }
        // Only set if API provided value (no default enum)
        _selectedType = PropertyType.fromApiValue(specs.type);
        if (specs.status != null) {
          _selectedStatus = PropertyStatus.fromApiValue(specs.status);
        }
        // Load floors - convert int to string option if available
        if (property.floors != null && _floorsOptions.isNotEmpty) {
          final floorsOption = _intToOption(property.floors, _floorsOptions);
          if (floorsOption != null) {
            _floorController.text = floorsOption;
          } else {
            // Fallback to direct string conversion if no match found
            _floorController.text = property.floors.toString();
          }
        } else if (property.floors != null) {
          // If options not loaded yet, use direct conversion
          _floorController.text = property.floors.toString();
        }
        // Load bedrooms - convert int to string option if available
        if (_bedroomsOptions.isNotEmpty) {
          final bedroomsOption = _intToOption(specs.bedrooms, _bedroomsOptions);
          if (bedroomsOption != null) {
            _bedroomsController.text = bedroomsOption;
          } else {
            _bedroomsController.text = specs.bedrooms.toString();
          }
        } else {
          _bedroomsController.text = specs.bedrooms.toString();
        }
        // Load bathrooms - convert int to string option if available
        if (_bathroomsOptions.isNotEmpty) {
          final bathroomsOption = _intToOption(
            specs.bathrooms,
            _bathroomsOptions,
          );
          if (bathroomsOption != null) {
            _bathroomsController.text = bathroomsOption;
          } else {
            _bathroomsController.text = specs.bathrooms.toString();
          }
        } else {
          _bathroomsController.text = specs.bathrooms.toString();
        }
        // Load parking spaces - convert int to string option if available
        if (_parkingSpacesOptions.isNotEmpty) {
          final parkingOption = _intToOption(
            specs.garage,
            _parkingSpacesOptions,
          );
          if (parkingOption != null) {
            _garageController.text = parkingOption;
          } else {
            _garageController.text = specs.garage.toString();
          }
        } else {
          _garageController.text = specs.garage.toString();
        }
        _priceController.text = NumberFormat(
          '#,###',
        ).format(double.tryParse(specs.price)?.round() ?? 0);
        if (specs.landSize != null) {
          _landSizeController.text = NumberFormat(
            '#,##0.00',
          ).format(specs.landSize!);
        }
        if (specs.buildingSize != null) {
          _buildingSizeController.text = NumberFormat(
            '#,##0.00',
          ).format(specs.buildingSize!);
        }
        _selectedPropertyColor = PropertyColor.fromApiValue(specs.houseColor);
        if (specs.availableFrom != null) {
          try {
            _availableFromDate = DateTime.parse(specs.availableFrom!);
            _availableFromController.text = DateFormat(
              'yyyy-MM-dd',
            ).format(_availableFromDate!);
          } catch (e) {
            // Ignore parse errors
          }
        }
        _descriptionController.text = specs.description ?? '';
      }

      // Load location data
      if (location != null) {
        // STRICT: Only set if API provided value (no empty string fallback)
        if (location.number != null) {
          _houseNumberController.text = location.number!;
        }
        // STRICT: Only set if API provided value (no default enum)
        if (location.direction != null) {
          _selectedDirection = Direction.fromApiValue(location.direction);
        }
        if (location.city != null) {
          _cityController.text = location.city!; // District (Amphoe)
        }
        // STRICT: Only set if API provided value (no default Country.thailand)
        if (location.country != null) {
          _selectedCountry = Country.fromApiValue(location.country);
          _countryController.text = _selectedCountry != null
              ? _selectedCountry!.labelTh
              : location.country!;
        }
        if (location.postalCode != null) {
          _postalCodeController.text = location.postalCode!;
        }

        // STRICT: Display EXACTLY what API returns - no parsing, no derivation, no lookup
        // This applies to both edit and view modes
        // Load district from location.district (fallback to location.city)
        if (location.district != null) {
          _districtController.text = location.district!;
        } else if (location.city != null) {
          _districtController.text = location.city!;
        }
        // Load province from location.province (fallback to location.state)
        if (location.province != null) {
          _provinceController.text = location.province!;
          _stateController.text = location.province!;
        } else if (location.state != null) {
          _provinceController.text = location.state!;
          _stateController.text = location.state!;
        }
        // Load subdistrict from location.subdistrict directly
        if (location.subdistrict != null) {
          _subdistrictController.text = location.subdistrict!;
        }
        // Load soi and road from location object directly
        if (location.soi != null) {
          _soiController.text = location.soi!;
        }
        if (location.road != null) {
          _roadController.text = location.road!;
        }

        // STRICT: Set location marker and camera ONLY - NO reverse geocoding on load
        // Trust the address string provided by the API
        if (location.latitude != null && location.longitude != null) {
          // Only update location if it's not already set (preserve existing location in edit mode)
          if (_selectedLocation == null) {
            _selectedLocation = LatLng(location.latitude!, location.longitude!);
            _latitudeController.text = location.latitude!.toStringAsFixed(8);
            _longitudeController.text = location.longitude!.toStringAsFixed(8);
            _locationLoadedFromApi =
                true; // Mark that location was loaded from API
            _locationMarker = Marker(
              markerId: const MarkerId('property_location'),
              position: _selectedLocation!,
              draggable: !widget.isReadOnly,
              onDragEnd: !widget.isReadOnly
                  ? (newPosition) {
                      _updateLocationFromCoordinates(newPosition);
                    }
                  : null,
            );

            // STRICT: Display EXACTLY what API returns - NO reverse geocoding
            // Set address from API response only
            if (specs?.address != null) {
              _addressController.text = specs!.address!;
            }

            // Initialize map camera position (only if not read-only and map is ready)
            if (!widget.isReadOnly &&
                _selectedLocation != null &&
                !_isUpdatingFromMap) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _mapControllerCompleter.isCompleted) {
                  _mapControllerCompleter.future.then((controller) {
                    if (mounted && !_isUpdatingFromMap) {
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(_selectedLocation!, 15),
                      );
                    }
                  });
                }
              });
            }
          } else {
            // Location already set - preserve it and only update address text if needed
            if (specs?.address != null && _addressController.text.isEmpty) {
              _addressController.text = specs!.address!;
            }
          }
        }
      }

      // Load built date/year
      if (property.built != null) {
        final builtValue = property.built!.trim();
        // Handle year-only strings (e.g., "2077")
        if (builtValue.length == 4 && int.tryParse(builtValue) != null) {
          // It's a year, create a date from it (use January 1st)
          final year = int.parse(builtValue);
          _builtDate = DateTime(year, 1, 1);
          _builtYearController.text = _formatThaiDate(_builtDate!);
        } else {
          // Try to parse as full date
          try {
            _builtDate = DateTime.parse(builtValue);
            _builtYearController.text = _formatThaiDate(_builtDate!);
          } catch (e) {
            // If parsing fails, try to extract year
            final yearMatch = RegExp(r'\d{4}').firstMatch(builtValue);
            if (yearMatch != null) {
              final year = int.parse(yearMatch.group(0)!);
              _builtDate = DateTime(year, 1, 1);
              _builtYearController.text = _formatThaiDate(_builtDate!);
            } else {
              // If all parsing fails, clear the field
              _builtDate = null;
              _builtYearController.clear();
            }
          }
        }
      }

      // Load listing_type (maps to SaleType)
      if (property.listingType != null) {
        _selectedSaleType = SaleType.fromApiValue(property.listingType);
      }

      // Generate property code: YH + 2-digit year + 6-digit property ID
      if (property.id != null) {
        _codeController.text = _generatePropertyCode(
          propertyId: property.id!,
          createdAt: property.createdAt,
        );
      }

      // Load existing photos (reset first to avoid duplicates when reloading)
      _existingPhotos.clear();
      if (property.images != null) {
        _existingPhotos.addAll(property.images!);
      }

      // Load dynamic specifications (only as fallback for fields not in location)
      if (specs?.specifications != null) {
        final specMap = specs!.specifications!;
        if (specMap['sale_type'] != null) {
          _selectedSaleType = SaleType.fromApiValue(
            specMap['sale_type'].toString(),
          );
        }
        if (specMap['style'] != null) {
          _selectedPropertyStyle = PropertyStyle.fromApiValue(
            specMap['style'].toString(),
          );
        }
        // Only use specifications map if location values are null/empty
        if (_soiController.text.isEmpty && specMap['soi'] != null) {
          _soiController.text = specMap['soi'].toString();
        }
        if (_roadController.text.isEmpty && specMap['road'] != null) {
          _roadController.text = specMap['road'].toString();
        }
        if (_districtController.text.isEmpty && specMap['district'] != null) {
          _districtController.text = specMap['district'].toString();
        }
        if (_subdistrictController.text.isEmpty && specMap['subdistrict'] != null) {
          _subdistrictController.text = specMap['subdistrict'].toString();
        }
        if (specMap['additional_details'] != null) {
          _additionalDetailsController.text = specMap['additional_details']
              .toString();
        }
        if (specMap['name'] != null) {
          _propertyNameController.text = specMap['name'].toString();
        }
      }

      // Load dynamic specification values
      if (specs?.specificationValues != null) {
        final valuesMap = specs!.specificationValues!;
        debugPrint(
          'PropertyForm: Loading specification_values keys: ${valuesMap.keys.toList()}',
        );

        // Load good_points (API key) - also support 'highlight' for backward compatibility
        if (valuesMap['good_points'] is List) {
          _selectedHighlights = (valuesMap['good_points'] as List)
              .map((e) => e.toString())
              .toList();
          debugPrint('PropertyForm: Loaded good_points: $_selectedHighlights');
        } else if (valuesMap['highlight'] is List) {
          // Fallback for old format
          _selectedHighlights = (valuesMap['highlight'] as List)
              .map((e) => e.toString())
              .toList();
          debugPrint(
            'PropertyForm: Loaded highlight (legacy): $_selectedHighlights',
          );
        }

        // Load common_facilities (API key) - also support 'common_facility' for backward compatibility
        if (valuesMap['common_facilities'] is List) {
          _selectedCommonAreas = (valuesMap['common_facilities'] as List)
              .map((e) => e.toString())
              .toList();
          debugPrint(
            'PropertyForm: Loaded common_facilities: $_selectedCommonAreas',
          );
        } else if (valuesMap['common_facility'] is List) {
          // Fallback for old API format
          _selectedCommonAreas = (valuesMap['common_facility'] as List)
              .map((e) => e.toString())
              .toList();
          debugPrint(
            'PropertyForm: Loaded common_facility (legacy): $_selectedCommonAreas',
          );
        }

        // Load furniture
        if (valuesMap['furniture'] is List) {
          _selectedFurniture = (valuesMap['furniture'] as List)
              .map((e) => e.toString())
              .toList();
          debugPrint('PropertyForm: Loaded furniture: $_selectedFurniture');
        }

        // Load air_conditioning
        if (valuesMap['air_conditioning'] is List) {
          _selectedAirConditioning = (valuesMap['air_conditioning'] as List)
              .map((e) => e.toString())
              .toList();
          debugPrint(
            'PropertyForm: Loaded air_conditioning: $_selectedAirConditioning',
          );
        }

        debugPrint(
          'PropertyForm: All specification_values loaded - highlights: ${_selectedHighlights.length}, common_areas: ${_selectedCommonAreas.length}, furniture: ${_selectedFurniture.length}, air_conditioning: ${_selectedAirConditioning.length}',
        );
      } else {
        debugPrint('PropertyForm: No specification_values found in specs');
      }
    } finally {
      // Always reset initialization flag after data population completes
      _isInitializing = false;
    }
  }

  /// Load filter options from /public/info API for dropdowns and multi-selects
  Future<void> _loadFilterOptions() async {
    if (_isLoadingFilterOptions) return;

    setState(() {
      _isLoadingFilterOptions = true;
    });

    try {
      final filterInfo = await DependencyInjection.propertyApiService
          .getPublicFilterInfo();

      // Map single select filters
      for (final filter in filterInfo.singleSelect) {
        switch (filter.key) {
          case 'floors':
            _floorsOptions = filter.options;
            break;
          case 'bedrooms':
            _bedroomsOptions = filter.options;
            break;
          case 'bathrooms':
            _bathroomsOptions = filter.options;
            break;
          case 'parking_spaces':
            _parkingSpacesOptions = filter.options;
            break;
        }
      }

      // Map multi select filters
      for (final filter in filterInfo.multiSelect) {
        switch (filter.key) {
          case 'good_points':
            _highlightOptions = filter.options;
            break;
          case 'common_facilities':
            _commonAreaOptions = filter.options;
            break;
          case 'furniture':
            _furnitureOptions = filter.options;
            break;
          case 'air_conditioning':
            _airConditioningOptions = filter.options;
            break;
        }
      }

      if (mounted) {
        setState(() {
          _isLoadingFilterOptions = false;
        });
        // Reload property data to map int values to string options now that options are loaded
        if (_isEditMode) {
          _loadPropertyData();
        }
      }
    } catch (e) {
      debugPrint('Error loading filter options: $e');

      // Fallback to default options if API fails
      _highlightOptions = [
        'Pet friendly',
        'Elderly friendly',
        'Stunning views',
      ];
      _commonAreaOptions = [
        'Fitness',
        'Swimming Pool',
        'Lawn',
        'Co-working space',
        'Playground',
        'Sports Field',
        'Security Staff',
      ];

      if (mounted) {
        setState(() {
          _isLoadingFilterOptions = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _codeController.dispose();
    _builtYearController.dispose();
    _propertyNameController.dispose();
    _soiController.dispose();
    _roadController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _garageController.dispose();
    _priceController.dispose();
    _landSizeController.dispose();
    _buildingSizeController.dispose();
    _availableFromController.dispose();
    _descriptionController.dispose();
    _additionalDetailsController.dispose();
    _houseNumberController.dispose();
    _floorController.dispose();
    _districtController.dispose();
    _subdistrictController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();

    // Condo-specific controllers
    _towerController.dispose();
    _condoFloorController.dispose();
    _unitNoController.dispose();
    _condoProjectController.dispose();

    // House-specific controllers
    _villageNameController.dispose();
    _mooController.dispose();
    _houseNotesController.dispose();

    // Cancel debounce timer
    _geocodeDebounceTimer?.cancel();

    // NOTE: On web, disposing GoogleMapController can hit an assertion:
    // "Maps cannot be retrieved before calling buildView!" if the platform view
    // hasn't fully initialized yet. Let the GoogleMap widget handle disposal.
    // With Completer pattern, the controller is managed by the GoogleMap widget.
    super.dispose();
  }

  Future<void> _pickImages({bool fromCamera = false}) async {
    if (!mounted) return;

    try {
      final l10n = AppLocalizations.of(context)!;

      // Show loading dialog immediately
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(
                  fromCamera ? 'กำลังเปิดกล้อง...' : 'กำลังเลือกรูปภาพ...',
                  style: GoogleFonts.anuphan(
                    fontSize: 16,
                    color: AppColors.eerieBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Pick images based on source
      List<XFile> images = [];

      if (fromCamera) {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );
        if (image != null) {
          images = [image];
        }
      } else {
        images = await _imagePicker.pickMultiImage(imageQuality: 85);
      }

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Process images if any were selected
      if (images.isNotEmpty && mounted) {
        // Update BLoC state for each photo
        for (final image in images) {
          context.read<PropertyFormBloc>().add(PropertyFormPhotoAdded(image));
        }

        // Show brief success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.images_added(images.length)),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // User cancelled - just close the dialog (already closed above)
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        Navigator.of(context).pop();

        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.error_picking_images}: $e')),
        );
      }
    }
  }

  void _removeNewPhoto(int index) {
    context.read<PropertyFormBloc>().add(PropertyFormPhotoRemoved(index));
  }

  void _clearAllNewPhotos() {
    // Remove all photos from BLoC state
    final currentPhotos = _newPhotos.length;
    for (int i = currentPhotos - 1; i >= 0; i--) {
      context.read<PropertyFormBloc>().add(PropertyFormPhotoRemoved(i));
    }
  }

  Future<void> _useCurrentLocation() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              const Text('Getting current location...'),
            ],
          ),
          duration: const Duration(seconds: 5),
        ),
      );

      LatLng? currentLocation;

      if (kIsWeb) {
        // For web, use browser geolocation API via method channel
        currentLocation = await _getCurrentLocationWeb();
      } else {
        // For mobile, use method channel (requires platform implementation)
        currentLocation = await _getCurrentLocationMobile();
      }

      if (currentLocation != null && mounted) {
        final location = currentLocation; // Non-null local variable
        // Set flag to prevent listener from triggering geocode
        _isUpdatingFromMap = true;

        // Update location using the same method as map tap
        _onMapTap(location);

        // Animate camera to center on current location with zoom 15.0
        if (_mapControllerCompleter.isCompleted) {
          _mapControllerCompleter.future.then((controller) {
            if (mounted) {
              controller.animateCamera(
                CameraUpdate.newLatLngZoom(location, 15.0),
              );
            }
          });
        }

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location updated successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Failed to get current location. Please check your location permissions or tap on the map to select a location.',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is PlatformException
                  ? (e.message ??
                        'Location permission denied. Please allow location access or tap on the map to select a location.')
                  : 'Failed to get current location. Please tap on the map to select a location.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Get current location for web using browser's geolocation API
  /// This uses the same navigator.geolocation API that Google Maps uses
  /// Uses package:web to directly access the browser's geolocation API
  Future<LatLng?> _getCurrentLocationWeb() async {
    if (!kIsWeb) return null;

    try {
      // First try the method channel (if plugin is registered)
      const platform = MethodChannel('youragent/location');
      final result = await platform.invokeMethod('getCurrentLocation');

      if (result is Map) {
        final lat = result['latitude'] as double?;
        final lng = result['longitude'] as double?;
        if (lat != null && lng != null) {
          return LatLng(lat, lng);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Method channel failed, using direct geolocation API: $e');

      // Fallback: Use package:web geolocation API directly
      return await _getCurrentLocationDirect();
    }
  }

  /// Get current location using package:web geolocation API directly
  Future<LatLng?> _getCurrentLocationDirect() async {
    if (!kIsWeb) return null;

    final geolocation = web.window.navigator.geolocation;

    final completer = Completer<LatLng?>();

    final options = web.PositionOptions(
      enableHighAccuracy: true,
      timeout: 10000,
      maximumAge: 0,
    );

    geolocation.getCurrentPosition(
      ((web.GeolocationPosition position) {
        final coords = position.coords;
        completer.complete(LatLng(coords.latitude, coords.longitude));
      }).toJS,
      ((web.GeolocationPositionError error) {
        String message = 'Failed to get location';
        switch (error.code) {
          case 1: // PERMISSION_DENIED
            message =
                'Location permission denied. Please allow location access in your browser settings.';
            break;
          case 2: // POSITION_UNAVAILABLE
            message = 'Location information is unavailable.';
            break;
          case 3: // TIMEOUT
            message = 'Location request timed out.';
            break;
        }
        completer.completeError(
          PlatformException(code: 'LocationError', message: message),
        );
      }).toJS,
      options,
    );

    return completer.future;
  }

  /// Get current location for mobile platforms
  Future<LatLng?> _getCurrentLocationMobile() async {
    if (kIsWeb) return null;

    try {
      const platform = MethodChannel('youragent/location');
      final result = await platform.invokeMethod('getCurrentLocation');

      if (result is Map) {
        final lat = result['latitude'] as double?;
        final lng = result['longitude'] as double?;
        if (lat != null && lng != null) {
          return LatLng(lat, lng);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error in mobile geolocation: $e');
      return null;
    }
  }

  void _onMapTap(LatLng location) {
    // วิธีที่ 1: เมื่อเลือกหมุดที่แมพเอง
    // - ไม่ควรมีการเปลี่ยนแมพหรือ lat/lng auto หลังจากเลือกเอง
    // - ควรเป็นจุดที่เลือกเท่านั้น
    // - อัปเดตข้อมูลตามที่ Google Map หาให้กับ field manual (เลขที่บ้าน, ซอย, ถนน) หรือ thai address suggestion field

    // Clear the API-loaded flag since user is now changing the location
    _locationLoadedFromApi = false;

    // ตั้ง flag เพื่อป้องกันไม่ให้ animate camera เมื่อ user ปักหมุดเอง
    _isUpdatingFromMap = true;

    // Update BLoC state with the exact coordinates (ไม่เปลี่ยนแมพหรือ lat/lng auto)
    context.read<PropertyFormBloc>().add(PropertyFormLocationChanged(location));

    setState(() {
      // ใช้ exact coordinates จากจุดที่เลือก (ไม่ auto-change)
      _selectedLocation = location;
      _latitudeController.text = location.latitude.toStringAsFixed(8);
      _longitudeController.text = location.longitude.toStringAsFixed(8);
      _locationMarker = Marker(
        markerId: const MarkerId('property_location'),
        position: location,
        draggable: !widget.isReadOnly,
        onDragEnd: !widget.isReadOnly
            ? (newPosition) {
                _updateLocationFromCoordinates(newPosition);
              }
            : null,
      );
    });

    // FIXED: Center camera on the pin after tapping (maintain current zoom)
    if (_mapControllerCompleter.isCompleted) {
      _mapControllerCompleter.future.then((controller) {
        if (mounted) {
          controller.animateCamera(CameraUpdate.newLatLng(location));
        }
      });
    }

    // อัปเดตข้อมูลตามที่ Google Map หาให้กับ field manual และ thai address fields
    _fetchAddressFromCoordinates(location.latitude, location.longitude);
  }

  void _updateLocationFromCoordinates(LatLng newPosition) {
    // วิธีที่ 1: เมื่อลากหมุดที่แมพเอง
    // - ไม่ควรมีการเปลี่ยนแมพหรือ lat/lng auto หลังจากเลือกเอง
    // - ควรเป็นจุดที่เลือกเท่านั้น
    // - อัปเดตข้อมูลตามที่ Google Map หาให้กับ field manual (เลขที่บ้าน, ซอย, ถนน) หรือ thai address suggestion field

    // Clear the API-loaded flag since user is now changing the location
    _locationLoadedFromApi = false;

    // ตั้ง flag เพื่อป้องกันไม่ให้ animate camera เมื่อ user ลากหมุดเอง
    // flag นี้จะถูก reset ใน _fetchAddressFromCoordinates หลังจากอัปเดตข้อมูลเสร็จ
    _isUpdatingFromMap = true;

    // Update BLoC state with the exact coordinates (ไม่เปลี่ยนแมพหรือ lat/lng auto)
    context.read<PropertyFormBloc>().add(
      PropertyFormLocationChanged(newPosition),
    );

    setState(() {
      // ใช้ exact coordinates จากจุดที่ลาก (ไม่ auto-change)
      _selectedLocation = newPosition;
      _latitudeController.text = newPosition.latitude.toStringAsFixed(8);
      _longitudeController.text = newPosition.longitude.toStringAsFixed(8);
      // Update marker position to match
      _locationMarker = Marker(
        markerId: const MarkerId('property_location'),
        position: newPosition,
        draggable: !widget.isReadOnly,
        onDragEnd: !widget.isReadOnly
            ? (position) {
                _updateLocationFromCoordinates(position);
              }
            : null,
      );
    });

    // FIXED: Center camera on the pin after dragging (maintain current zoom)
    if (_mapControllerCompleter.isCompleted) {
      _mapControllerCompleter.future.then((controller) {
        if (mounted) {
          controller.animateCamera(CameraUpdate.newLatLng(newPosition));
        }
      });
    }

    // อัปเดตข้อมูลตามที่ Google Map หาให้กับ field manual และ thai address fields
    _fetchAddressFromCoordinates(newPosition.latitude, newPosition.longitude);
  }

  /// Check if a value is safe to auto-fill into address fields
  /// Prevents invalid administrative level names from polluting manual input fields
  /// 
  /// [value] - The address component value to validate
  /// [isSubdistrictLevel] - If true, allows subdistrict keywords but bans higher levels
  ///                       If false, bans all administrative level keywords (for Soi/Road)
  bool _isSafeToAutoFill(String? value, {required bool isSubdistrictLevel}) {
    if (value == null || value.trim().isEmpty) return false;

    // Define banned keywords by administrative level
    const provinceLevelKeywords = [
      'Province',
      'Changwat',
      'จังหวัด',
      'Bangkok',
      'Krung Thep',
    ];

    const districtLevelKeywords = [
      'District',
      'Amphoe',
      'Khet',
      'อำเภอ',
      'เขต',
    ];

    const subdistrictLevelKeywords = [
      'Subdistrict',
      'Tambon',
      'Khwaeng',
      'ตำบล',
      'แขวง',
    ];

    final valueLower = value.toLowerCase().trim();

    // Check for province level keywords (always banned)
    for (final keyword in provinceLevelKeywords) {
      if (valueLower.contains(keyword.toLowerCase())) {
        debugPrint(
          'PropertyForm: Rejected "$value" - contains province level keyword: "$keyword"',
        );
        return false;
      }
    }

    // Check for district level keywords (always banned)
    for (final keyword in districtLevelKeywords) {
      if (valueLower.contains(keyword.toLowerCase())) {
        debugPrint(
          'PropertyForm: Rejected "$value" - contains district level keyword: "$keyword"',
        );
        return false;
      }
    }

    // For Soi/Road fields: also ban subdistrict level keywords
    if (!isSubdistrictLevel) {
      for (final keyword in subdistrictLevelKeywords) {
        if (valueLower.contains(keyword.toLowerCase())) {
          debugPrint(
            'PropertyForm: Rejected "$value" - contains subdistrict level keyword: "$keyword" (not allowed for Soi/Road)',
          );
          return false;
        }
      }
    }
    // For Subdistrict field: allow subdistrict keywords, only ban higher levels

    return true;
  }

  Future<void> _fetchAddressFromCoordinates(double lat, double lng) async {
    if (widget.isReadOnly) return;

    debugPrint(
      'PropertyForm: Fetching address from coordinates lat: $lat, lng: $lng',
    );
    try {
      // Set flag to prevent circular updates และป้องกันไม่ให้ _syncStateFromBloc overwrite
      // flag นี้จะถูก reset หลังจาก delay เพื่อให้แน่ใจว่า BLoC state sync เสร็จก่อน
      _isUpdatingFromMap = true;

      final placesService = DependencyInjection.placesService;
      final result = await placesService.reverseGeocode(lat: lat, lng: lng);

      if (result.isNotEmpty && mounted) {
        debugPrint(
          'PropertyForm: Reverse geocode result: ${result.keys.toList()}',
        );
        
        // Extract raw address components from API result
        String? apiRoad = result['road']?.toString().trim();
        String? apiSoi = result['soi']?.toString().trim();
        String? apiHouseNumber = result['houseNumber']?.toString().trim();
        final rawSubdistrict = result['subdistrict']?.toString().trim();
        
        // 1. Smart Migration: Move Road to Soi if Road contains Soi/Village/Alley keywords
        // Google Maps often incorrectly puts Soi/Village/Alley names into the road field
        // Check for: "Soi", "ซอย" (soi), "หมู่บ้าน" (village), "ตรอก" (alley)
        final soiKeywords = ['Soi', 'ซอย', 'หมู่บ้าน', 'ตรอก'];
        final hasSoiKeyword = apiRoad != null &&
            apiRoad.isNotEmpty &&
            soiKeywords.any((keyword) => apiRoad!.contains(keyword));
        
        if (hasSoiKeyword) {
          debugPrint(
            'PropertyForm: Detected misplaced Soi/Village/Alley in road field: "$apiRoad" - moving to Soi field',
          );
          // Move road value to soi (prefer existing soi if it exists, otherwise use road)
          apiSoi = apiSoi?.isNotEmpty == true ? apiSoi : apiRoad;
          apiRoad = null; // Clear Road field
        }
        
        // 2. Validate address components (apply banned keyword validation)
        final isValidSoi = apiSoi != null &&
            apiSoi.isNotEmpty &&
            _isSafeToAutoFill(apiSoi, isSubdistrictLevel: false);
        final finalSoi = isValidSoi ? apiSoi : null;
        
        final isValidRoad = apiRoad != null &&
            apiRoad.isNotEmpty &&
            _isSafeToAutoFill(apiRoad, isSubdistrictLevel: false);
        final finalRoad = isValidRoad ? apiRoad : null;
        
        // Validate Subdistrict: allow subdistrict keywords, but reject province/district keywords
        final isValidSubdistrict = _isSafeToAutoFill(
          rawSubdistrict,
          isSubdistrictLevel: true,
        );
        final finalSubdistrict = isValidSubdistrict ? rawSubdistrict : null;
        
        // Update BLoC state with address information (only validated values)
        if (result['address'] != null && result['address']!.isNotEmpty) {
          context.read<PropertyFormBloc>().add(
            PropertyFormAddressUpdated(
              address: result['address']!,
              district: result['district'],
              subdistrict: finalSubdistrict, // Use validated subdistrict
              state: result['state'],
              country: result['country'],
              postalCode: result['postalCode'],
              houseNumber: result['houseNumber'],
              soi: finalSoi, // Use validated soi
              road: finalRoad, // Use validated road
            ),
          );

          // IMPORTANT: เมื่อปักหมุดเอง - fields ทั้งหมดต้องเปลี่ยนตามหมุด
          // Reset the manual input flag เพื่อให้สามารถอัปเดต fields ได้
          _isManualAddressInput = false;

          setState(() {
            // อัปเดต Thai address fields (จังหวัด, เขต, ตำบล, รหัสไปรษณีย์)
            _districtController.text = result['district'] ?? '';
            _cityController.text = result['district'] ?? '';
            // Only update subdistrict if validated
            if (finalSubdistrict != null) {
              _subdistrictController.text = finalSubdistrict;
            }
            _stateController.text = result['state'] ?? '';
            _provinceController.text = result['state'] ?? '';
            _postalCodeController.text = result['postalCode'] ?? '';

            // อัปเดต manual fields (เลขที่บ้าน, ซอย, ถนน)
            // Implement Clear-on-Empty rule: Clear controllers if API returns null/empty
            
            // House Number: Clear if empty, otherwise assign
            if (apiHouseNumber != null && apiHouseNumber.isNotEmpty) {
              _houseNumberController.text = apiHouseNumber;
            } else {
              _houseNumberController.clear(); // CLEAR if empty
            }
            
            // Soi: Apply validation and Clear-on-Empty rule
            if (finalSoi != null && finalSoi.isNotEmpty) {
              _soiController.text = finalSoi;
            } else {
              _soiController.clear(); // CLEAR if empty/invalid
            }
            
            // Road: Apply validation and Clear-on-Empty rule
            if (finalRoad != null && finalRoad.isNotEmpty) {
              _roadController.text = finalRoad;
            } else {
              _roadController.clear(); // CLEAR if empty/invalid
            }

            // อัปเดต country
            _countryController.text =
                result['country'] ?? _countryController.text;
            final parsedCountry = Country.fromApiValue(result['country']);
            if (parsedCountry != null) {
              _selectedCountry = parsedCountry;
            }
          });

          // Update full address composition after populating all individual controllers
          // This ensures the full address reflects the composed values, not the raw Google Maps string
          _updateFullAddress();

          debugPrint(
            'PropertyForm: Full address updated to: ${_addressController.text}',
          );

          debugPrint(
            'PropertyForm: All fields updated from reverse geocode - '
            'houseNumber: ${result['houseNumber']}, '
            'soi: $finalSoi (original: ${result['soi']}, validated: $isValidSoi), '
            'road: $finalRoad (original: ${result['road']}, validated: $isValidRoad), '
            'district: ${result['district']}, '
            'subdistrict: $finalSubdistrict (original: ${result['subdistrict']}, validated: $isValidSubdistrict), '
            'state: ${result['state']}, '
            'postalCode: ${result['postalCode']}',
          );

          // Update country in BLoC if changed
          if (result['country'] != null && result['country']!.isNotEmpty) {
            final country = Country.fromApiValue(result['country']);
            if (country != null) {
              context.read<PropertyFormBloc>().add(
                PropertyFormCountryChanged(country),
              );
            }
          }
        } else {
          debugPrint('PropertyForm: No address in reverse geocode result');
        }
      }
    } catch (_) {
      // Silently ignore geocoding errors
    } finally {
      // Reset flag after update completes
      // Delay reset เพื่อให้แน่ใจว่า BLoC state sync เสร็จก่อน
      // และป้องกันไม่ให้ _syncStateFromBloc overwrite ค่าที่ user ปักหมุดเอง
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _isUpdatingFromMap = false;
        }
      });
    }
  }

  /// Geocode from address text and update map location
  Future<void> _geocodeFromAddress() async {
    if (widget.isReadOnly) return;

    // SILENCE: Return immediately if initializing (prevent geocoding during data load)
    if (_isInitializing) return;

    final candidates = _buildGeocodeCandidates();
    if (candidates.isEmpty) return;

    try {
      final placesService = DependencyInjection.placesService;
      for (final query in candidates) {
        final result = await placesService.geocode(address: query);
        if (!mounted) return;
        if (result.isEmpty) continue;

        final lat = result['lat'] as double?;
        final lng = result['lng'] as double?;
        final formattedAddress = result['formattedAddress'] as String?;
        if (lat == null || lng == null) continue;

        final location = LatLng(lat, lng);

        // วิธีที่ 2: พิมพ์เอง
        // - เมื่อมีข้อมูลครบทั้ง thai address suggestion และฟิลด์อื่น ๆ
        // - เมื่อมีการ onChange เกิดขึ้นให้อัปเดตหมุดของ Google Map, lat/lng, address
        // - ห้ามเอาค่าจาก Google Map มา auto ใส่ manual field ใหม่

        // อัปเดตหมุดของ Google Map, lat/lng, address เท่านั้น
        // ห้ามเอาค่าจาก Google Map มาใส่ manual fields
        context.read<PropertyFormBloc>().add(
          PropertyFormLocationChanged(location),
        );

        setState(() {
          _selectedLocation = location;
          _latitudeController.text = lat.toStringAsFixed(8);
          _longitudeController.text = lng.toStringAsFixed(8);
          _locationMarker = Marker(
            markerId: const MarkerId('property_location'),
            position: location,
            draggable: !widget.isReadOnly,
            onDragEnd: !widget.isReadOnly
                ? (newPosition) {
                    _updateLocationFromCoordinates(newPosition);
                  }
                : null,
          );
        });

        // Update full address composition from individual fields
        // This ensures manual edits to individual fields are reflected in the full address
        _updateFullAddress();

        // Animate camera to focus on the found area with zoom 15.0
        if (_mapControllerCompleter.isCompleted) {
          _mapControllerCompleter.future.then((controller) {
            if (mounted) {
              controller.animateCamera(
                CameraUpdate.newLatLngZoom(location, 15.0),
              );
            }
          });
        }

        // After geocoding from manual input completes, reset flag after a delay
        // This allows BLoC sync to work normally for other fields, but prevents
        // address field rollback for a short period after manual input
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _isManualAddressInput = false;
          }
        });

        // Stop at the first successful match.
        break;
      }
    } catch (_) {
      // Silently ignore geocoding errors
      // Reset flag on error too
      if (mounted) {
        _isManualAddressInput = false;
      }
    }
  }

  void _clearLocation() {
    setState(() {
      _selectedLocation = null;
      _locationMarker = null;
      _latitudeController.clear();
      _longitudeController.clear();
      _addressController.clear();
      _cityController.clear();
      _stateController.clear();
      _countryController.clear();
      _postalCodeController.clear();
    });
  }

  void _submitForm() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final bloc = context.read<PropertyFormBloc>();
    final blocState = bloc.state;

    // Reset scroll-to-error flag before validation
    _hasScrolledToError = false;

    if (!_formKey.currentState!.validate()) {
      // Find and scroll to first error field
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasScrolledToError && _scrollController.hasClients) {
          // Find first field with error by checking all field keys
          for (final entry in _fieldKeys.entries) {
            final fieldState = entry.value.currentState;
            if (fieldState != null && !fieldState.isValid) {
              final fieldContext = fieldState.context;
              Scrollable.ensureVisible(
                fieldContext,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                alignment: 0.1, // Show field near top of viewport
              );
              _hasScrolledToError = true;
              break;
            }
          }
          // Fallback: if no field key found, scroll to top only if near top
          if (!_hasScrolledToError && _scrollController.hasClients) {
            final currentOffset = _scrollController.offset;
            if (currentOffset < 100) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
        }
      });
      return;
    }

    // Get photos from BLoC state if available
    final blocNewPhotos = blocState is PropertyFormData
        ? blocState.newPhotos
        : _newPhotos;
    final blocExistingPhotos = blocState is PropertyFormData
        ? blocState.existingPhotos
        : _existingPhotos;

    // Validate minimum 1 photo requirement (existing + new photos)
    final totalPhotos = blocExistingPhotos.length + blocNewPhotos.length;
    if (totalPhotos < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.upload_at_least_one_image),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final formData = <String, dynamic>{
      'built': () {
        // Get built date from BLoC state if available
        final blocBuiltDate = blocState is PropertyFormData
            ? blocState.builtDate
            : _builtDate;
        return blocBuiltDate != null
            ? DateFormat('yyyy-MM-dd').format(blocBuiltDate)
            : _builtYearController.text.isNotEmpty
            ? _builtYearController.text
            : null;
      }(),
      'type': blocState is PropertyFormData
          ? blocState.selectedType?.apiValue
          : _selectedType?.apiValue,
      'status': blocState is PropertyFormData
          ? blocState.selectedStatus?.apiValue
          : _selectedStatus?.apiValue,
      // Convert string options to int for API (handle "Studio", "8+", "10+" etc.)
      'floors': _parseOptionToInt(_floorController.text),
      'bedrooms': _parseOptionToInt(_bedroomsController.text),
      'bathrooms': _parseOptionToInt(_bathroomsController.text),
      'garage': _parseOptionToInt(_garageController.text),
      'price': double.tryParse(_priceController.text.replaceAll(',', '')),
      'land_size': double.tryParse(
        _landSizeController.text.replaceAll(',', ''),
      ),
      'building_size': double.tryParse(
        _buildingSizeController.text.replaceAll(',', ''),
      ),
      'house_color': () {
        // Get house color from BLoC state if available, otherwise use local state
        final blocColor = blocState is PropertyFormData
            ? blocState.selectedPropertyColor
            : null;
        final color = blocColor ?? _selectedPropertyColor;
        return color?.apiValue;
      }(),
      'available_from': () {
        // Use BLoC state date if available, otherwise parse from controller
        if (blocState is PropertyFormData && blocState.availableFromDate != null) {
          return DateFormat('yyyy-MM-dd').format(blocState.availableFromDate!);
        }
        if (_availableFromDate != null) {
          return DateFormat('yyyy-MM-dd').format(_availableFromDate!);
        }
        // Fallback to controller text if it's already in YYYY-MM-DD format
        final controllerText = _availableFromController.text.trim();
        if (controllerText.isNotEmpty) {
          // Try to parse and reformat to ensure YYYY-MM-DD
          try {
            final parsed = DateTime.parse(controllerText);
            return DateFormat('yyyy-MM-dd').format(parsed);
          } catch (_) {
            return controllerText; // Return as-is if parsing fails
          }
        }
        return null;
      }(),
      'description': _descriptionController.text,
      'name': _propertyNameController.text.isNotEmpty
          ? _propertyNameController.text
          : null,
      'number': _houseNumberController.text.isNotEmpty
          ? _houseNumberController.text
          : null,
      'direction': () {
        // Get direction from BLoC state if available, otherwise use local state
        final blocDirection = blocState is PropertyFormData
            ? blocState.selectedDirection
            : null;
        final direction = blocDirection ?? _selectedDirection;
        return direction?.apiValue;
      }(),
      'city': () {
        // Use city controller if available, otherwise fallback to district
        final city = _cityController.text.trim();
        if (city.isNotEmpty) {
          return city;
        }
        // Fallback to district if city is empty
        final district = _districtController.text.trim();
        return district.isNotEmpty ? district : null;
      }(),
      'state': _stateController.text.isNotEmpty ? _stateController.text : null,
      'country': () {
        final blocCountry = blocState is PropertyFormData
            ? blocState.selectedCountry
            : _selectedCountry;
        return blocCountry != null
            ? blocCountry.labelTh
            : (_countryController.text.isNotEmpty
                  ? _countryController.text
                  : null);
      }(),
      'postal_code':
          blocState is PropertyFormData && blocState.postalCode != null
          ? blocState.postalCode
          : (_postalCodeController.text.isNotEmpty
                ? _postalCodeController.text
                : null),
      'latitude': blocState is PropertyFormData
          ? blocState.selectedLocation?.latitude
          : _selectedLocation?.latitude,
      'longitude': blocState is PropertyFormData
          ? blocState.selectedLocation?.longitude
          : _selectedLocation?.longitude,
      'address': () {
        // Always use the composed address from _addressController
        // This ensures we use the address generated by _updateFullAddress()
        // which combines all individual fields, not the raw Google Maps Plus Code
        final composedAddress = _addressController.text.trim();
        return composedAddress.isNotEmpty ? composedAddress : null;
      }(),

      // Dynamic Specifications
      // These are sent as strings per API contract, e.g.
      // "specifications": { "floors": "2", "bedrooms": "3", ... }
      'specifications': {
        // Structural specs from dropdowns (string options like "2", "3", "8+")
        if (_floorController.text.isNotEmpty) 'floors': _floorController.text,
        if (_bedroomsController.text.isNotEmpty)
          'bedrooms': _bedroomsController.text,
        if (_bathroomsController.text.isNotEmpty)
          'bathrooms': _bathroomsController.text,
        if (_garageController.text.isNotEmpty)
          'parking_spaces': _garageController.text,

        // Additional free-form specs (legacy fields)
        if (_soiController.text.isNotEmpty) 'soi': _soiController.text,
        if (_roadController.text.isNotEmpty) 'road': _roadController.text,
        if (_districtController.text.isNotEmpty)
          'district': _districtController.text,
        if (_subdistrictController.text.isNotEmpty)
          'subdistrict': _subdistrictController.text,
        if ((blocState is PropertyFormData
                ? blocState.selectedSaleType
                : _selectedSaleType) !=
            null)
          'sale_type':
              (blocState is PropertyFormData
                      ? blocState.selectedSaleType
                      : _selectedSaleType)!
                  .apiValue,
        if ((blocState is PropertyFormData
                ? blocState.selectedPropertyStyle
                : _selectedPropertyStyle) !=
            null)
          'style':
              (blocState is PropertyFormData
                      ? blocState.selectedPropertyStyle
                      : _selectedPropertyStyle)!
                  .apiValue,
        if (_additionalDetailsController.text.isNotEmpty)
          'additional_details': _additionalDetailsController.text,
      },

      // Multi-select specification_values
      // Matches API keys: common_facilities, furniture, air_conditioning, good_points(highlight)
      'specification_values': () {
        final highlights = blocState is PropertyFormData
            ? blocState.selectedHighlights
            : _selectedHighlights;
        final commonAreas = blocState is PropertyFormData
            ? blocState.selectedCommonAreas
            : _selectedCommonAreas;
        final furniture = blocState is PropertyFormData
            ? blocState.selectedFurniture
            : _selectedFurniture;
        final airConditioning = blocState is PropertyFormData
            ? blocState.selectedAirConditioning
            : _selectedAirConditioning;

        return {
          if (highlights.isNotEmpty) 'good_points': highlights,
          if (commonAreas.isNotEmpty) 'common_facilities': commonAreas,
          if (furniture.isNotEmpty) 'furniture': furniture,
          if (airConditioning.isNotEmpty) 'air_conditioning': airConditioning,
        };
      }(),

      // Type-specific fields
      'property_type': blocState is PropertyFormData
          ? blocState.selectedType?.apiValue
          : _selectedType?.apiValue,
      // Condo fields
      'condo_project_id': blocState is PropertyFormData
          ? blocState.selectedCondoProject?.id
          : null,
      'tower': blocState is PropertyFormData ? blocState.tower : null,
      'condo_floor': blocState is PropertyFormData
          ? blocState.condoFloor
          : null,
      'unit_no': blocState is PropertyFormData ? blocState.unitNo : null,
      // House fields
      'village_name': blocState is PropertyFormData
          ? blocState.villageName
          : null,
      'moo': blocState is PropertyFormData ? blocState.moo : null,
      'house_subtype': blocState is PropertyFormData
          ? blocState.houseSubtype
          : null,
      'parking_type': blocState is PropertyFormData
          ? blocState.parkingType
          : null,
      'is_corner_plot': blocState is PropertyFormData
          ? blocState.isCornerPlot
          : null,
      'house_notes': blocState is PropertyFormData
          ? blocState.houseNotes
          : null,
    };

    // Get photos from BLoC state
    final photosToSubmit = blocState is PropertyFormData
        ? blocState.newPhotos
        : _newPhotos;

    // Pass XFile directly for cross-platform compatibility
    widget.onSubmit(formData, photosToSubmit);
  }

  /// Public method to programmatically submit the form
  /// Can be called from parent widgets via GlobalKey
  void submitForm() {
    debugPrint('PropertyForm: submitForm() called');
    _submitForm();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Wrap in RepaintBoundary to prevent unnecessary repaints on parent rebuilds
    return RepaintBoundary(
      child: BlocListener<PropertyFormBloc, PropertyFormState>(
        listenWhen: (previous, current) {
          // Only listen when state actually changes
          // Skip if both are initial state (no data to sync)
          if (previous is PropertyFormInitial &&
              current is PropertyFormInitial) {
            return false;
          }
          if (previous.runtimeType != current.runtimeType) {
            return true;
          }
          if (previous is PropertyFormData && current is PropertyFormData) {
            // Only sync if data actually changed
            return previous != current;
          }
          return false;
        },
        listener: (context, formState) {
          // Only sync when state actually changes, not on every build
          // Sync from BLoC state for both edit and read-only modes to ensure all data is loaded
          // In read-only mode, we sync but don't trigger listeners to prevent modifications
          if (formState is PropertyFormData) {
            _syncStateFromBloc(formState);
          }
        },
        child: BlocBuilder<PropertyFormBloc, PropertyFormState>(
          buildWhen: (previous, current) {
            // Only rebuild if state type changed or if it's PropertyFormData and data actually changed
            if (previous.runtimeType != current.runtimeType) {
              return true;
            }
            if (previous is PropertyFormData && current is PropertyFormData) {
              // Only rebuild if the state actually changed (not just a reference change)
              return previous != current;
            }
            return false;
          },
          builder: (context, formState) {
            return Form(
              key: _formKey,
              child: ListView(
                controller: _scrollController,
                padding:
                    EdgeInsets.zero, // Remove padding for full-width design
                children: [
                  PropertyFormSection(
                    title: l10n.general_information,
                    icon: 'assets/icons/form/info.svg',
                    iconColor: const Color(0xFF1743C7),
                    l10n: l10n,
                    statusBadge:
                        widget.isReadOnly &&
                            widget.property?.approvalStatus != null
                        ? _buildApprovalStatusBadge(
                            widget.property!.approvalStatus,
                          )
                        : null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: รหัส - ชื่ออสังหาฯ (expanded to take remaining space)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: AppFormTextField(
                                controller: _codeController,
                                label: 'รหัส',
                                l10n: l10n,
                                readOnly: true,
                                isRequired: false,
                                enable: false,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'text_${_codeController.hashCode}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 19,
                              child: AppFormTextField(
                                controller: _propertyNameController,
                                label: 'ชื่ออสังหาฯ',
                                l10n: l10n,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'text_${_propertyNameController.hashCode}',
                                ),
                                onChanged: widget.isReadOnly
                                    ? null
                                    : (value) {
                                        context.read<PropertyFormBloc>().add(
                                          PropertyFormFieldUpdated(
                                            field: 'name',
                                            value: value,
                                          ),
                                        );
                                      },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Row 2: เลขที่บ้าน/ห้อง - ซอย/ตรอก/หมู่บ้าน - ถนน - ประเทศ
                        Row(
                          children: [
                            Expanded(
                              child: AppFormTextField(
                                controller: _houseNumberController,
                                label: 'เลขที่บ้าน/ห้อง',
                                l10n: l10n,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'text_${_houseNumberController.hashCode}',
                                ),
                                onChanged: widget.isReadOnly
                                    ? null
                                    : (value) {
                                        context.read<PropertyFormBloc>().add(
                                          PropertyFormFieldUpdated(
                                            field: 'house_number',
                                            value: value,
                                          ),
                                        );
                                      },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppFormTextField(
                                controller: _soiController,
                                label: 'ซอย/ตรอก/หมู่บ้าน',
                                l10n: l10n,
                                isRequired: false,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'text_${_soiController.hashCode}',
                                ),
                                onChanged: widget.isReadOnly
                                    ? null
                                    : (value) {
                                        context.read<PropertyFormBloc>().add(
                                          PropertyFormFieldUpdated(
                                            field: 'soi',
                                            value: value,
                                          ),
                                        );
                                      },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppFormTextField(
                                controller: _roadController,
                                label: 'ถนน',
                                l10n: l10n,
                                isRequired: false,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'text_${_roadController.hashCode}',
                                ),
                                onChanged: widget.isReadOnly
                                    ? null
                                    : (value) {
                                        context.read<PropertyFormBloc>().add(
                                          PropertyFormFieldUpdated(
                                            field: 'road',
                                            value: value,
                                          ),
                                        );
                                      },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PropertyDropdownField<Country>(
                                label: 'ประเทศ',
                                value: _selectedCountry,
                                l10n: l10n,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'dropdown_ประเทศ_${_selectedCountry.hashCode}',
                                ),
                                items: [
                                  DropdownMenuItem<Country>(
                                    value: null,
                                    child: Text(
                                      'เลือกประเทศ',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                  ...Country.values.map((country) {
                                    return DropdownMenuItem<Country>(
                                      value: country,
                                      child: Text(
                                        country.getLabel(l10n),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCountry = value;
                                    if (value != null) {
                                      _countryController.text = value.labelTh;
                                    } else {
                                      _countryController.clear();
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Row 3: จังหวัด - เขต/อำเภอ - แขวง/ตำบล - รหัสไปรษณีย์
                        Row(
                          children: [
                            Expanded(
                              child: ThaiAddressTypeAhead(
                                controller: _provinceController,
                                label: 'จังหวัด',
                                searchKey: 'province',
                                thaiAddresses: _thaiAddresses,
                                isReadOnly: widget.isReadOnly,
                                isLoadingAddress: _isLoadingAddress,
                                currentPostalCode:
                                    _postalCodeController.text.trim().isNotEmpty
                                    ? _postalCodeController.text.trim()
                                    : null,
                                onSelected: _onThaiAddressSelected,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ThaiAddressTypeAhead(
                                controller: _districtController,
                                label: 'เขต/อำเภอ',
                                searchKey: 'amphoe',
                                thaiAddresses: _thaiAddresses,
                                isReadOnly: widget.isReadOnly,
                                isLoadingAddress: _isLoadingAddress,
                                currentPostalCode:
                                    _postalCodeController.text.trim().isNotEmpty
                                    ? _postalCodeController.text.trim()
                                    : null,
                                onSelected: _onThaiAddressSelected,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ThaiAddressTypeAhead(
                                controller: _subdistrictController,
                                label: 'แขวง/ตำบล',
                                searchKey: 'district',
                                thaiAddresses: _thaiAddresses,
                                isReadOnly: widget.isReadOnly,
                                isLoadingAddress: _isLoadingAddress,
                                currentPostalCode:
                                    _postalCodeController.text.trim().isNotEmpty
                                    ? _postalCodeController.text.trim()
                                    : null,
                                onSelected: _onThaiAddressSelected,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ThaiAddressTypeAhead(
                                controller: _postalCodeController,
                                label: 'รหัสไปรษณีย์',
                                searchKey: 'zipcode',
                                thaiAddresses: _thaiAddresses,
                                isReadOnly: widget.isReadOnly,
                                isLoadingAddress: _isLoadingAddress,
                                onSelected: _onThaiAddressSelected,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Row 4: ทิศบ้าน (left) + 3 empty slots to keep 4-column alignment
                        Row(
                          children: [
                            Expanded(
                              child: PropertyDropdownField<Direction>(
                                label: 'ทิศบ้าน',
                                value: _selectedDirection,
                                l10n: l10n,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'dropdown_ทิศบ้าน_${_selectedDirection.hashCode}',
                                ),
                                items: [
                                  DropdownMenuItem<Direction>(
                                    value: null,
                                    child: Text(
                                      'เลือกทิศ',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                  ...Direction.values.map((direction) {
                                    return DropdownMenuItem<Direction>(
                                      value: direction,
                                      child: Text(
                                        direction.getLabel(l10n),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedDirection = value;
                                  });
                                  // Dispatch to BLoC to keep state in sync
                                  context.read<PropertyFormBloc>().add(
                                    PropertyFormDirectionChanged(value),
                                  );
                                },
                                isRequired: false,
                              ),
                            ),
                            // Add 3 empty spacers to keep 4-column alignment (same width as others)
                            const SizedBox(width: 16),
                            const Expanded(child: SizedBox()),
                            const SizedBox(width: 16),
                            const Expanded(child: SizedBox()),
                            const SizedBox(width: 16),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const SizedBox(height: 24),

                  // Section 2: ตำแหน่งที่ตั้ง (per design - comes second)
                  PropertyFormSection(
                    title: l10n.property_location_section,
                    icon: 'assets/icons/form/map-pin.svg',
                    iconColor: const Color(0xFF1743C7),
                    l10n: l10n,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subtitle and buttons row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Description text per design
                            Expanded(
                              child: Text(
                                'คลิกบนแผนที่หรือใช้ตำแหน่งปัจจุบันของคุณเพื่อกำหนดตั้งอสังหาริมทรัพย์',
                                style: GoogleFonts.anuphan(
                                  fontSize: 13,
                                  color: AppColors.shadyLady,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Buttons on the right
                            if (!widget.isReadOnly)
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _useCurrentLocation,
                                    style: ButtonStyle(
                                      elevation: WidgetStateProperty.all(0),
                                      padding: WidgetStateProperty.all(
                                        const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                      ),
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      backgroundColor:
                                          WidgetStateProperty.resolveWith((
                                            states,
                                          ) {
                                            if (states.contains(
                                                  WidgetState.hovered,
                                                ) ||
                                                states.contains(
                                                  WidgetState.pressed,
                                                )) {
                                              return const Color(0xFF32A792);
                                            }
                                            return const Color(
                                              0xFF7DE1CF,
                                            ).withValues(alpha: 0.16);
                                          }),
                                      foregroundColor:
                                          WidgetStateProperty.resolveWith((
                                            states,
                                          ) {
                                            if (states.contains(
                                                  WidgetState.hovered,
                                                ) ||
                                                states.contains(
                                                  WidgetState.pressed,
                                                )) {
                                              return Colors.white;
                                            }
                                            return const Color(0xFF32A792);
                                          }),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            return SvgPicture.asset(
                                              'assets/icons/form/location.svg',
                                              width: 16,
                                              height: 16,
                                              colorFilter: ColorFilter.mode(
                                                IconTheme.of(context).color!,
                                                BlendMode.srcIn,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        Text(l10n.use_current_location),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton(
                                    onPressed: _clearLocation,
                                    style: ButtonStyle(
                                      elevation: WidgetStateProperty.all(0),
                                      backgroundColor: WidgetStateProperty.all(
                                        Colors.white,
                                      ),
                                      padding: WidgetStateProperty.all(
                                        const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                      ),
                                      shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      side: WidgetStateProperty.all(
                                        const BorderSide(
                                          color: Color(0xFFE9EAEB),
                                        ),
                                      ),
                                      foregroundColor:
                                          WidgetStateProperty.resolveWith((
                                            states,
                                          ) {
                                            if (states.contains(
                                                  WidgetState.hovered,
                                                ) ||
                                                states.contains(
                                                  WidgetState.pressed,
                                                )) {
                                              return const Color(0xFF181D27);
                                            }
                                            return const Color(0xFF717680);
                                          }),
                                    ),
                                    child: Text(l10n.clear_location),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Map container per design
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.bonJour),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildMapWidget(context),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Row: ที่อยู่ตามเลขที่ - ละติจูด - ลองจิจูด (per design)
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: AppFormTextField(
                                controller: _addressController,
                                label: 'ที่อยู่ตามเลขที่',
                                readOnly: true,
                                l10n: l10n,
                                isRequired: false,
                                enable: false,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'text_${_addressController.hashCode}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppFormTextField(
                                controller: _latitudeController,
                                label: 'ละติจูด',
                                readOnly: true,
                                l10n: l10n,
                                isRequired: false,
                                enable: false,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'text_${_latitudeController.hashCode}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppFormTextField(
                                controller: _longitudeController,
                                label: 'ลองจิจูด',
                                readOnly: true,
                                l10n: l10n,
                                isRequired: false,
                                enable: false,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'text_${_longitudeController.hashCode}',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Section 3: รายละเอียดทรัพย์ (per design - comes third)
                  PropertyFormSection(
                    title: l10n.property_details_section,
                    icon: 'assets/icons/form/menu-2.svg',
                    iconColor: const Color(0xFF1743C7),
                    l10n: l10n,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row 1: ประเภททรัพย์ - ประเภทประกาศ - สถานะ - ปีที่สร้าง
                        Row(
                          children: [
                            Expanded(
                              child: PropertyDropdownField<PropertyType>(
                                label: 'ประเภททรัพย์',
                                value: _selectedType,
                                l10n: l10n,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'dropdown_ประเภททรัพย์_${_selectedType.hashCode}',
                                ),
                                items: [
                                  DropdownMenuItem<PropertyType>(
                                    value: null,
                                    child: Text(l10n.select_type),
                                  ),
                                  ...PropertyType.values.map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type.getLabel(l10n)),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  context.read<PropertyFormBloc>().add(
                                    PropertyFormTypeChanged(value),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PropertyDropdownField<SaleType>(
                                label: 'ประเภทประกาศ',
                                value: _selectedSaleType,
                                l10n: l10n,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'dropdown_ประเภทประกาศ_${_selectedSaleType.hashCode}',
                                ),
                                items: [
                                  DropdownMenuItem<SaleType>(
                                    value: null,
                                    child: Text(l10n.select_type),
                                  ),
                                  ...SaleType.values.map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type.getLabel(l10n)),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  context.read<PropertyFormBloc>().add(
                                    PropertyFormSaleTypeChanged(value),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PropertyDropdownField<PropertyStatus>(
                                label: 'สถานะ',
                                value: _selectedStatus,
                                l10n: l10n,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'dropdown_สถานะ_${_selectedStatus.hashCode}',
                                ),
                                items: [
                                  DropdownMenuItem<PropertyStatus>(
                                    value: null,
                                    child: Text(l10n.select_status),
                                  ),
                                  ...PropertyStatus.values.map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status.getLabel(l10n)),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  context.read<PropertyFormBloc>().add(
                                    PropertyFormStatusChanged(value),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildBuiltDateField(
                                controller: _builtYearController,
                                label: 'วันที่สร้าง',
                                l10n: l10n,
                                isRequired: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Available From Date Field (after Built Year)
                        Row(
                          children: [
                            Expanded(
                              child: _buildAvailableFromDateField(
                                controller: _availableFromController,
                                label: 'พร้อมให้เช่าจากวันที่',
                                l10n: l10n,
                                isRequired: false,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(child: SizedBox()), // Spacer
                            const SizedBox(width: 16),
                            const Expanded(child: SizedBox()), // Spacer
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Row 2: สีทรัพย์ - ราคา - จำนวนชั้น - จำนวนห้องนอน
                        Row(
                          children: [
                            Expanded(
                              child: PropertyDropdownField<PropertyColor>(
                                label: 'สีทรัพย์',
                                value: _selectedPropertyColor,
                                l10n: l10n,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'dropdown_สีทรัพย์_${_selectedPropertyColor.hashCode}',
                                ),
                                items: [
                                  DropdownMenuItem<PropertyColor>(
                                    value: null,
                                    child: Text(l10n.select_color),
                                  ),
                                  ...PropertyColor.values.map(
                                    (color) => DropdownMenuItem(
                                      value: color,
                                      child: Text(color.getLabel(l10n)),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(
                                    () => _selectedPropertyColor = value,
                                  );
                                  context.read<PropertyFormBloc>().add(
                                    PropertyFormColorChanged(value),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PropertyNumberField(
                                controller: _priceController,
                                label: 'ราคา',
                                isPrice: true,
                                suffixText: 'บาท',
                                l10n: l10n,
                                isRequired: false,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'number_${_priceController.hashCode}',
                                ),
                                onChanged: widget.isReadOnly
                                    ? null
                                    : (value) {
                                        context.read<PropertyFormBloc>().add(
                                          PropertyFormFieldUpdated(
                                            field: 'price',
                                            value: value,
                                          ),
                                        );
                                      },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PropertyDropdownField<String>(
                                label: 'จำนวนชั้น',
                                value: _floorController.text.isEmpty
                                    ? null
                                    : _floorController.text,
                                l10n: l10n,
                                isRequired: false,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'dropdown_จำนวนชั้น_${_floorController.text.hashCode}',
                                ),
                                items: _floorsOptions.isEmpty
                                    ? []
                                    : _floorsOptions.map((option) {
                                        return DropdownMenuItem<String>(
                                          value: option,
                                          child: Text(option),
                                        );
                                      }).toList(),
                                onChanged: (value) => setState(
                                  () => _floorController.text = value ?? '',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PropertyDropdownField<String>(
                                label: 'จำนวนห้องนอน',
                                value: _bedroomsController.text.isEmpty
                                    ? null
                                    : _bedroomsController.text,
                                l10n: l10n,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'dropdown_จำนวนห้องนอน_${_bedroomsController.text.hashCode}',
                                ),
                                items: _bedroomsOptions.isEmpty
                                    ? []
                                    : _bedroomsOptions.map((option) {
                                        return DropdownMenuItem<String>(
                                          value: option,
                                          child: Text(option),
                                        );
                                      }).toList(),
                                onChanged: (value) => setState(
                                  () => _bedroomsController.text = value ?? '',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Row 3: จำนวนห้องน้ำ - จำนวนที่จอดรถ - ขนาดที่ดิน - ขนาดพื้นที่ใช้สอย
                        Row(
                          children: [
                            Expanded(
                              child: PropertyDropdownField<String>(
                                label: 'จำนวนห้องน้ำ',
                                value: _bathroomsController.text.isEmpty
                                    ? null
                                    : _bathroomsController.text,
                                l10n: l10n,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'dropdown_จำนวนห้องน้ำ_${_bathroomsController.text.hashCode}',
                                ),
                                items: _bathroomsOptions.isEmpty
                                    ? []
                                    : _bathroomsOptions.map((option) {
                                        return DropdownMenuItem<String>(
                                          value: option,
                                          child: Text(option),
                                        );
                                      }).toList(),
                                onChanged: (value) => setState(
                                  () => _bathroomsController.text = value ?? '',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PropertyDropdownField<String>(
                                label: 'จำนวนที่จอดรถ',
                                value: _garageController.text.isEmpty
                                    ? null
                                    : _garageController.text,
                                l10n: l10n,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'dropdown_จำนวนที่จอดรถ_${_garageController.text.hashCode}',
                                ),
                                items: _parkingSpacesOptions.isEmpty
                                    ? []
                                    : _parkingSpacesOptions.map((option) {
                                        return DropdownMenuItem<String>(
                                          value: option,
                                          child: Text(option),
                                        );
                                      }).toList(),
                                onChanged: (value) => setState(
                                  () => _garageController.text = value ?? '',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PropertyNumberField(
                                controller: _landSizeController,
                                label: 'ขนาดที่ดิน',
                                isDecimal: true,
                                suffixText: 'ตร.ว.',
                                l10n: l10n,
                                isRequired: false,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'number_${_landSizeController.hashCode}',
                                ),
                                onChanged: widget.isReadOnly
                                    ? null
                                    : (value) {
                                        context.read<PropertyFormBloc>().add(
                                          PropertyFormFieldUpdated(
                                            field: 'land_size',
                                            value: value,
                                          ),
                                        );
                                      },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PropertyNumberField(
                                controller: _buildingSizeController,
                                label: 'ขนาดพื้นที่ใช้สอย',
                                isDecimal: true,
                                suffixText: 'ตร.ม.',
                                l10n: l10n,
                                isRequired: false,
                                isReadOnly: widget.isReadOnly,
                                fieldKey: _getFieldKey(
                                  'number_${_buildingSizeController.hashCode}',
                                ),
                                onChanged: widget.isReadOnly
                                    ? null
                                    : (value) {
                                        context.read<PropertyFormBloc>().add(
                                          PropertyFormFieldUpdated(
                                            field: 'building_size',
                                            value: value,
                                          ),
                                        );
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Type-Specific Details Section (Condo/House)
                  PropertyTypeDetailsSection(
                    isReadOnly: widget.isReadOnly,
                    l10n: l10n,
                  ),

                  const SizedBox(height: 24),

                  // Section 4: รายละเอียดเพิ่มเติม (per design)
                  PropertyAdditionalDetailsSection(
                    descriptionController: _descriptionController,
                    selectedPropertyStyle: _selectedPropertyStyle,
                    selectedHighlights: _selectedHighlights,
                    selectedCommonAreas: _selectedCommonAreas,
                    selectedFurniture: _selectedFurniture,
                    selectedAirConditioning: _selectedAirConditioning,
                    highlightOptions: _highlightOptions,
                    commonAreaOptions: _commonAreaOptions,
                    furnitureOptions: _furnitureOptions,
                    airConditioningOptions: _airConditioningOptions,
                    isReadOnly: widget.isReadOnly,
                    l10n: l10n,
                    onPropertyStyleChanged: (value) {
                      setState(() => _selectedPropertyStyle = value);
                      context.read<PropertyFormBloc>().add(
                        PropertyFormStyleChanged(value),
                      );
                    },
                    onHighlightsChanged: (values) {
                      if (widget.isReadOnly) return;
                      context.read<PropertyFormBloc>().add(
                        PropertyFormHighlightsChanged(values),
                      );
                    },
                    onCommonAreasChanged: (values) {
                      if (widget.isReadOnly) return;
                      context.read<PropertyFormBloc>().add(
                        PropertyFormCommonAreasChanged(values),
                      );
                    },
                    onFurnitureChanged: (values) {
                      if (widget.isReadOnly) return;
                      context.read<PropertyFormBloc>().add(
                        PropertyFormFurnitureChanged(values),
                      );
                    },
                    onAirConditioningChanged: (values) {
                      if (widget.isReadOnly) return;
                      context.read<PropertyFormBloc>().add(
                        PropertyFormAirConditioningChanged(values),
                      );
                    },
                    descriptionFieldKey: _getFieldKey(
                      'text_${_descriptionController.hashCode}',
                    ),
                    onDescriptionChanged: widget.isReadOnly
                        ? null
                        : (value) {
                            context.read<PropertyFormBloc>().add(
                              PropertyFormFieldUpdated(
                                field: 'description',
                                value: value,
                              ),
                            );
                          },
                  ),

                  const SizedBox(height: 24),

                  // Section 5: รูปภาพทรัพย์ (per design)
                  PropertyImagesSection(
                    newPhotos: _newPhotos,
                    existingPhotos: _existingPhotos,
                    isReadOnly: widget.isReadOnly,
                    onPickImages: () => _pickImages(),
                    onPickImagesFromCamera: () => _pickImages(fromCamera: true),
                    onRemoveNewPhoto: _removeNewPhoto,
                    onClearAllNewPhotos: _clearAllNewPhotos,
                    l10n: l10n,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Helper method to get or create a field key for form validation
  GlobalKey<FormFieldState<dynamic>> _getFieldKey(String key) {
    if (!_fieldKeys.containsKey(key)) {
      _fieldKeys[key] = GlobalKey<FormFieldState<dynamic>>();
    }
    return _fieldKeys[key]!;
  }

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
    return '${date.day.toString().padLeft(2, '0')} ${thaiMonths[date.month - 1]} $thaiYear';
  }

  /// Parse option string to int (handles "Studio", "8+", "10+" etc.)
  int? _parseOptionToInt(String? value) {
    if (value == null || value.isEmpty) return null;

    // Handle "Studio" -> 0
    if (value.toLowerCase() == 'studio') return 0;

    // Handle "8+", "10+" etc. -> extract number
    final match = RegExp(r'^(\d+)').firstMatch(value);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    // Try direct parse
    return int.tryParse(value);
  }

  /// Convert int value to matching string option from available options.
  /// For floors: 1 -> "1", 10 -> "10+", etc.
  String? _intToOption(int? value, List<String> options) {
    if (value == null) return null;

    // First try exact match
    final exactMatch = options.firstWhere(
      (option) => option == value.toString(),
      orElse: () => '',
    );
    if (exactMatch.isNotEmpty) return exactMatch;

    // If no exact match, try to find the closest "X+" option
    // For example, 10 -> "10+", 11 -> "10+", etc.
    for (final option in options.reversed) {
      if (option.endsWith('+')) {
        final match = RegExp(r'^(\d+)').firstMatch(option);
        if (match != null) {
          final threshold = int.tryParse(match.group(1)!);
          if (threshold != null && value >= threshold) {
            return option;
          }
        }
      }
    }

    // If no match found, return null
    return null;
  }

  /// Generate property code in format: YH + 2-digit year + 6-digit property ID
  /// Example: YH26000001 (YH + 26 (year 2026) + 000001 (property ID))
  String _generatePropertyCode({required int propertyId, DateTime? createdAt}) {
    // Get year from createdAt or use current year
    final year = createdAt?.year ?? DateTime.now().year;
    // Get last 2 digits of year
    final yearSuffix = (year % 100).toString().padLeft(2, '0');
    // Format property ID to 6 digits with leading zeros
    final propertyIdFormatted = propertyId.toString().padLeft(6, '0');
    return 'YH$yearSuffix$propertyIdFormatted';
  }

  Future<void> _selectBuiltDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    // If _builtDate is after now (invalid), use now as initialDate
    final DateTime initialDate =
        (_builtDate != null && _builtDate!.isAfter(now))
        ? now
        : (_builtDate ?? now);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      locale: const Locale('th', 'TH'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.buttonPrimary,
              onPrimary: Colors.white,
              onSurface: AppColors.eerieBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _builtDate) {
      // Update BLoC state
      context.read<PropertyFormBloc>().add(
        PropertyFormBuiltDateChanged(picked),
      );
    }
  }

  Widget _buildBuiltDateField({
    required TextEditingController controller,
    required String label,
    required AppLocalizations l10n,
    bool isRequired = true,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 8),
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: widget.isReadOnly
                ? const TextSelectionThemeData(
                    selectionColor: AppColors.gray800,
                    cursorColor: AppColors.gray800,
                  )
                : null,
          ),
          child: Builder(
            builder: (fieldContext) {
              // Store field key for error scrolling
              final fieldKey = 'date_${controller.hashCode}';
              if (!_fieldKeys.containsKey(fieldKey)) {
                _fieldKeys[fieldKey] = GlobalKey<FormFieldState<dynamic>>();
              }
              return TextFormField(
                key: _fieldKeys[fieldKey],
                controller: controller,
                enabled: !widget.isReadOnly,
                readOnly: true,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: theme.textTheme.bodyMedium,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.isReadOnly
                          ? AppColors.grayBorder
                          : AppColors.primary,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayBorder),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  filled: widget.isReadOnly,
                  fillColor: widget.isReadOnly ? const Color(0xFFFFFFFF) : null,
                  suffixIcon: widget.isReadOnly
                      ? const Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: Color(0xFFA4A7AE),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                            color: AppColors.gray500,
                          ),
                          onPressed: () => _selectBuiltDate(context),
                        ),
                ),
                onTap: widget.isReadOnly
                    ? null
                    : () => _selectBuiltDate(context),
                validator: widget.isReadOnly
                    ? null
                    : (value) {
                        if (isRequired && (value == null || value.isEmpty)) {
                          return l10n.this_field_required;
                        }
                        if (_builtDate != null) {
                          final now = DateTime.now();
                          if (_builtDate!.isAfter(now)) {
                            return 'วันที่สร้างไม่สามารถมากกว่าวันที่ปัจจุบัน';
                          }
                        }
                        return null;
                      },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectAvailableFromDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _availableFromDate ?? now;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('th', 'TH'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.buttonPrimary,
              onPrimary: Colors.white,
              onSurface: AppColors.eerieBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _availableFromDate) {
      // Update local state and controller
      setState(() {
        _availableFromDate = picked;
        _availableFromController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      // Update BLoC state
      context.read<PropertyFormBloc>().add(
        PropertyFormAvailableFromDateChanged(picked),
      );
    }
  }

  Widget _buildAvailableFromDateField({
    required TextEditingController controller,
    required String label,
    required AppLocalizations l10n,
    bool isRequired = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label: label, isRequired: isRequired),
        const SizedBox(height: 8),
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: widget.isReadOnly
                ? const TextSelectionThemeData(
                    selectionColor: AppColors.gray800,
                    cursorColor: AppColors.gray800,
                  )
                : null,
          ),
          child: Builder(
            builder: (fieldContext) {
              // Store field key for error scrolling
              final fieldKey = 'date_available_from_${controller.hashCode}';
              if (!_fieldKeys.containsKey(fieldKey)) {
                _fieldKeys[fieldKey] = GlobalKey<FormFieldState<dynamic>>();
              }
              return TextFormField(
                key: _fieldKeys[fieldKey],
                controller: controller,
                enabled: !widget.isReadOnly,
                readOnly: true,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: theme.textTheme.bodyMedium,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.isReadOnly
                          ? AppColors.grayBorder
                          : AppColors.primary,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grayBorder),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  filled: widget.isReadOnly,
                  fillColor: widget.isReadOnly ? const Color(0xFFFFFFFF) : null,
                  suffixIcon: widget.isReadOnly
                      ? const Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: Color(0xFFA4A7AE),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                            color: AppColors.gray500,
                          ),
                          onPressed: () => _selectAvailableFromDate(context),
                        ),
                ),
                onTap: widget.isReadOnly
                    ? null
                    : () => _selectAvailableFromDate(context),
                validator: widget.isReadOnly
                    ? null
                    : (value) {
                        if (isRequired && (value == null || value.isEmpty)) {
                          return l10n.this_field_required;
                        }
                        return null;
                      },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build approval status badge with consistent styling (same as property list)
  Widget _buildApprovalStatusBadge(String? approvalStatus) {
    final status = (approvalStatus ?? 'pending').toLowerCase();

    if (status == 'approved' || status == 'อนุมัติแล้ว') {
      return AppBadge(
        label: 'อนุมัติแล้ว',
        style: BadgeStyle.dot,
        customBackgroundColor: AppColors.statusConfirmedBg,
        customTextColor: AppColors.statusConfirmedText,
        customDotColor: AppColors.statusConfirmedText,
      );
    } else if (status == 'rejected' || status == 'ไม่ผ่าน') {
      return AppBadge(
        label: 'ไม่ผ่าน',
        style: BadgeStyle.dismissibleLeading,
        customBackgroundColor: AppColors.statusCancelledBg,
        customTextColor: AppColors.statusCancelledText,
        customDotColor: AppColors.statusCancelledText,
      );
    } else {
      // pending or default
      return AppBadge(
        label: 'รอการอนุมัติ',
        style: BadgeStyle.dot,
        customBackgroundColor: AppColors.statusPendingBg,
        customTextColor: AppColors.statusPendingText,
        customDotColor: AppColors.statusPendingText,
      );
    }
  }

  Widget _buildMapWidget(BuildContext context) {
    // Use the same pattern as PropertyMapSection (yourhome app style)
    // Use Listener to capture scroll wheel events so that
    // zooming the map with the mouse wheel does NOT scroll the page.
    // For web, delay map rendering to prevent IntersectionObserver errors
    if (!_isMapReady) {
      return SizedBox(
        height: 300,
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            );
          },
        ),
      );
    }

    // Use fixed-size SizedBox instead of LayoutBuilder to ensure DOM element exists
    // This matches the approach in PropertyMapSection and prevents IntersectionObserver errors
    return SizedBox(
      height: 300,
      child: Listener(
        onPointerSignal: (PointerSignalEvent event) {
          if (event is PointerScrollEvent) {
            GestureBinding.instance.pointerSignalResolver.register(
              event,
              (PointerSignalEvent e) {},
            );
          }
        },
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target:
                _selectedLocation ?? const LatLng(13.7563, 100.5018), // Bangkok
            zoom: _selectedLocation != null ? 15 : 12,
          ),
          onMapCreated: (GoogleMapController controller) {
            if (!_mapControllerCompleter.isCompleted) {
              _mapControllerCompleter.complete(controller);
            }
          },
          onTap: widget.isReadOnly ? null : _onMapTap,
          markers: _locationMarker != null ? {_locationMarker!} : {},
          mapType: MapType.normal,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: !widget.isReadOnly,
          mapToolbarEnabled: !widget.isReadOnly,
          scrollGesturesEnabled: !widget.isReadOnly,
          zoomGesturesEnabled: !widget.isReadOnly,
          tiltGesturesEnabled: !widget.isReadOnly,
          rotateGesturesEnabled: !widget.isReadOnly,
        ),
      ),
    );
  }

  /// Sync local state variables with BLoC state to keep them in sync
  /// This ensures local state stays in sync with BLoC state
  void _syncStateFromBloc(PropertyFormData formData) {
    // 🔒 LOCK LISTENERS: Set sync flag to prevent listeners from triggering geocoding
    _isSyncing = true;
    // In read-only mode, also set initializing flag to prevent any side effects
    if (widget.isReadOnly) {
      _isInitializing = true;
    }

    try {
      // Sync enum values
      if (formData.selectedType != _selectedType) {
        _selectedType = formData.selectedType;
      }
      if (formData.selectedStatus != _selectedStatus) {
        _selectedStatus = formData.selectedStatus;
      }
      if (formData.selectedSaleType != _selectedSaleType) {
        _selectedSaleType = formData.selectedSaleType;
      }
      if (formData.selectedPropertyStyle != _selectedPropertyStyle) {
        _selectedPropertyStyle = formData.selectedPropertyStyle;
      }
      if (formData.selectedPropertyColor != _selectedPropertyColor) {
        _selectedPropertyColor = formData.selectedPropertyColor;
      }
      if (formData.selectedDirection != _selectedDirection) {
        _selectedDirection = formData.selectedDirection;
      }
      if (formData.selectedCountry != _selectedCountry) {
        _selectedCountry = formData.selectedCountry;
      }

      // Sync dates
      if (formData.builtDate != _builtDate) {
        _builtDate = formData.builtDate;
        if (_builtDate != null) {
          _builtYearController.text = _formatThaiDate(_builtDate!);
        } else {
          _builtYearController.clear();
        }
      }
      if (formData.availableFromDate != _availableFromDate) {
        _availableFromDate = formData.availableFromDate;
        if (_availableFromDate != null) {
          _availableFromController.text = DateFormat(
            'yyyy-MM-dd',
          ).format(_availableFromDate!);
        } else {
          _availableFromController.clear();
        }
      }

      // Sync text field values - only sync if BLoC has a non-empty value that's different
      // This prevents overwriting user input when BLoC state has old/empty values
      if (formData.propertyName != null &&
          formData.propertyName!.isNotEmpty &&
          formData.propertyName != _propertyNameController.text) {
        _propertyNameController.text = formData.propertyName!;
      }
      if (formData.propertyCode != null &&
          formData.propertyCode != _codeController.text) {
        _codeController.text = formData.propertyCode!;
      }
      // Sync numeric fields - convert to options if available
      // Only sync if BLoC has a non-empty value that's different
      if (formData.floors != null &&
          formData.floors!.isNotEmpty &&
          formData.floors != _floorController.text) {
        if (_floorsOptions.isNotEmpty) {
          final floorsInt = int.tryParse(formData.floors!);
          if (floorsInt != null) {
            final floorsOption = _intToOption(floorsInt, _floorsOptions);
            _floorController.text = floorsOption ?? formData.floors!;
          } else {
            _floorController.text = formData.floors!;
          }
        } else {
          _floorController.text = formData.floors!;
        }
      }
      if (formData.bedrooms != null &&
          formData.bedrooms!.isNotEmpty &&
          formData.bedrooms != _bedroomsController.text) {
        if (_bedroomsOptions.isNotEmpty) {
          final bedroomsInt = int.tryParse(formData.bedrooms!);
          if (bedroomsInt != null) {
            final bedroomsOption = _intToOption(bedroomsInt, _bedroomsOptions);
            _bedroomsController.text = bedroomsOption ?? formData.bedrooms!;
          } else {
            _bedroomsController.text = formData.bedrooms!;
          }
        } else {
          _bedroomsController.text = formData.bedrooms!;
        }
      }
      if (formData.bathrooms != null &&
          formData.bathrooms!.isNotEmpty &&
          formData.bathrooms != _bathroomsController.text) {
        if (_bathroomsOptions.isNotEmpty) {
          final bathroomsInt = int.tryParse(formData.bathrooms!);
          if (bathroomsInt != null) {
            final bathroomsOption = _intToOption(
              bathroomsInt,
              _bathroomsOptions,
            );
            _bathroomsController.text = bathroomsOption ?? formData.bathrooms!;
          } else {
            _bathroomsController.text = formData.bathrooms!;
          }
        } else {
          _bathroomsController.text = formData.bathrooms!;
        }
      }
      if (formData.garage != null &&
          formData.garage!.isNotEmpty &&
          formData.garage != _garageController.text) {
        if (_parkingSpacesOptions.isNotEmpty) {
          final garageInt = int.tryParse(formData.garage!);
          if (garageInt != null) {
            final garageOption = _intToOption(garageInt, _parkingSpacesOptions);
            _garageController.text = garageOption ?? formData.garage!;
          } else {
            _garageController.text = formData.garage!;
          }
        } else {
          _garageController.text = formData.garage!;
        }
      }
      if (formData.price != null &&
          formData.price!.isNotEmpty &&
          formData.price != _priceController.text) {
        // Format price with commas if it's a number
        final cleanPrice = formData.price!.replaceAll(',', '');
        final numPrice = double.tryParse(cleanPrice);
        if (numPrice != null) {
          _priceController.text = NumberFormat(
            '#,###',
          ).format(numPrice.round());
        } else {
          _priceController.text = formData.price!;
        }
      }
      if (formData.landSize != null &&
          formData.landSize!.isNotEmpty &&
          formData.landSize != _landSizeController.text) {
        _landSizeController.text = formData.landSize!;
      }
      if (formData.buildingSize != null &&
          formData.buildingSize!.isNotEmpty &&
          formData.buildingSize != _buildingSizeController.text) {
        _buildingSizeController.text = formData.buildingSize!;
      }
      if (formData.description != null &&
          formData.description!.isNotEmpty &&
          formData.description != _descriptionController.text) {
        _descriptionController.text = formData.description!;
      }
      if (formData.additionalDetails != null &&
          formData.additionalDetails!.isNotEmpty &&
          formData.additionalDetails != _additionalDetailsController.text) {
        _additionalDetailsController.text = formData.additionalDetails!;
      }
      if (formData.availableFrom != null &&
          formData.availableFrom != _availableFromController.text) {
        _availableFromController.text = formData.availableFrom!;
      }

      // Sync multi-select lists
      if (formData.selectedHighlights != _selectedHighlights) {
        _selectedHighlights = formData.selectedHighlights;
      }
      if (formData.selectedCommonAreas != _selectedCommonAreas) {
        _selectedCommonAreas = formData.selectedCommonAreas;
      }
      if (formData.selectedFurniture != _selectedFurniture) {
        _selectedFurniture = formData.selectedFurniture;
      }
      if (formData.selectedAirConditioning != _selectedAirConditioning) {
        _selectedAirConditioning = formData.selectedAirConditioning;
      }

      // Sync location
      // IMPORTANT:
      // - ไม่ sync location เมื่อกำลังอัปเดตจากแมพ (user ปักหมุดเอง) เพื่อป้องกันไม่ให้หมุดเด้งกลับ
      // - ไม่ sync location ระหว่าง initialization เพื่อป้องกันไม่ให้ location ที่โหลดจาก API ถูก overwrite
      // - ไม่ sync location ถ้า location ถูกโหลดจาก API แล้ว (preserve API data) เว้นแต่ user เปลี่ยนเอง
      if (!_isUpdatingFromMap &&
          !_isInitializing &&
          !_locationLoadedFromApi && // Don't overwrite location loaded from API
          formData.selectedLocation != _selectedLocation) {
        _selectedLocation = formData.selectedLocation;
        if (_selectedLocation != null) {
          final loc = _selectedLocation!;
          _latitudeController.text = loc.latitude.toStringAsFixed(8);
          _longitudeController.text = loc.longitude.toStringAsFixed(8);

          // FIXED: Create/update marker when syncing location from BLoC
          _locationMarker = Marker(
            markerId: const MarkerId('property_location'),
            position: loc,
            draggable: !widget.isReadOnly,
            onDragEnd: !widget.isReadOnly
                ? (newPosition) {
                    _updateLocationFromCoordinates(newPosition);
                  }
                : null,
          );

          // FIXED: Animate camera to center on the pin when syncing from BLoC
          if (_mapControllerCompleter.isCompleted) {
            _mapControllerCompleter.future.then((controller) {
              if (mounted) {
                controller.animateCamera(CameraUpdate.newLatLngZoom(loc, 15.0));
              }
            });
          }
        } else {
          // Clear marker if location is null
          _locationMarker = null;
        }
      }

      // Sync address fields
      // IMPORTANT:
      // - Only sync address fields if they come from reverse geocode (pin moved),
      //   NOT if user is manually typing. This prevents rollback of manual input.
      // - ไม่ sync เมื่อกำลังอัปเดตจากแมพ (user ปักหมุดเอง) เพื่อป้องกันไม่ให้ fields กลับไปเป็นข้อมูลเดิม
      if (!_isManualAddressInput && !_isUpdatingFromMap) {
        if (formData.address != null &&
            formData.address != _addressController.text) {
          _addressController.text = formData.address!;
        }
        if (formData.district != null &&
            formData.district != _districtController.text) {
          _districtController.text = formData.district!;
          _cityController.text = formData.district!;
        }
        if (formData.subdistrict != null &&
            formData.subdistrict != _subdistrictController.text) {
          _subdistrictController.text = formData.subdistrict!;
        }
        if (formData.state != null && formData.state != _stateController.text) {
          _stateController.text = formData.state!;
          _provinceController.text = formData.state!;
        }
        if (formData.country != null &&
            formData.country != _countryController.text) {
          _countryController.text = formData.country!;
        }
        if (formData.postalCode != null &&
            formData.postalCode != _postalCodeController.text) {
          _postalCodeController.text = formData.postalCode!;
        }
        // Only sync address fields if BLoC has non-empty values to prevent overwriting user input
        if (formData.houseNumber != null &&
            formData.houseNumber!.isNotEmpty &&
            formData.houseNumber != _houseNumberController.text) {
          _houseNumberController.text = formData.houseNumber!;
        }
        if (formData.soi != null &&
            formData.soi!.isNotEmpty &&
            formData.soi != _soiController.text) {
          _soiController.text = formData.soi!;
        }
        if (formData.road != null &&
            formData.road!.isNotEmpty &&
            formData.road != _roadController.text) {
          _roadController.text = formData.road!;
        }
      }

      // Sync photos
      if (formData.newPhotos.length != _newPhotos.length) {
        _newPhotos.clear();
        _newPhotos.addAll(formData.newPhotos);
      }
      if (formData.existingPhotos.length != _existingPhotos.length) {
        _existingPhotos.clear();
        _existingPhotos.addAll(formData.existingPhotos);
      }

      // Sync filter options
      if (formData.filterOptions.isNotEmpty) {
        _floorsOptions = formData.filterOptions['floors'] ?? [];
        _bedroomsOptions = formData.filterOptions['bedrooms'] ?? [];
        _bathroomsOptions = formData.filterOptions['bathrooms'] ?? [];
        _parkingSpacesOptions = formData.filterOptions['parking_spaces'] ?? [];
        _highlightOptions = formData.filterOptions['good_points'] ?? [];
        _commonAreaOptions = formData.filterOptions['common_facilities'] ?? [];
        _furnitureOptions = formData.filterOptions['furniture'] ?? [];
        _airConditioningOptions =
            formData.filterOptions['air_conditioning'] ?? [];
      }

      // Sync Thai addresses
      if (formData.thaiAddresses.isNotEmpty && _thaiAddresses.isEmpty) {
        _thaiAddresses = formData.thaiAddresses;
        _isLoadingAddress = formData.isLoadingAddress;
      }

      // Sync type-specific fields
      // Condo fields
      if (formData.selectedCondoProject != _selectedCondoProject) {
        _selectedCondoProject = formData.selectedCondoProject;
        if (_selectedCondoProject != null) {
          _condoProjectController.text = _selectedCondoProject!.name;
        } else {
          _condoProjectController.clear();
        }
      }
      if (formData.tower != null &&
          formData.tower!.isNotEmpty &&
          formData.tower != _towerController.text) {
        _towerController.text = formData.tower!;
      }
      if (formData.condoFloor != null &&
          formData.condoFloor!.isNotEmpty &&
          formData.condoFloor != _condoFloorController.text) {
        _condoFloorController.text = formData.condoFloor!;
      }
      if (formData.unitNo != null &&
          formData.unitNo!.isNotEmpty &&
          formData.unitNo != _unitNoController.text) {
        _unitNoController.text = formData.unitNo!;
      }

      // House fields
      if (formData.villageName != null &&
          formData.villageName!.isNotEmpty &&
          formData.villageName != _villageNameController.text) {
        _villageNameController.text = formData.villageName!;
      }
      if (formData.moo != null &&
          formData.moo!.isNotEmpty &&
          formData.moo != _mooController.text) {
        _mooController.text = formData.moo!;
      }
      if (formData.houseSubtype != _houseSubtype) {
        _houseSubtype = formData.houseSubtype;
      }
      if (formData.parkingType != _parkingType) {
        _parkingType = formData.parkingType;
      }
      if (formData.isCornerPlot != _isCornerPlot) {
        _isCornerPlot = formData.isCornerPlot;
      }
      if (formData.houseNotes != null &&
          formData.houseNotes!.isNotEmpty &&
          formData.houseNotes != _houseNotesController.text) {
        _houseNotesController.text = formData.houseNotes!;
      }
    } finally {
      // 🔓 UNLOCK LISTENERS: Always reset sync flag after sync completes
      _isSyncing = false;
      // In read-only mode, keep initializing flag set to prevent side effects
      // It will be reset when needed
    }
  }
}
