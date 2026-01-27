import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/widgets/forms/standard_text_field.dart';
import 'package:youragent/features/property/bloc/property_form_bloc.dart';
import 'package:youragent/features/property/bloc/property_form_event.dart';

/// Modular Address & Location Section Widget
/// Handles Thai address auto-completion and 2-way Google Maps synchronization
class AddressLocationSection extends StatefulWidget {
  final bool isReadOnly;
  final LatLng? initialLocation;
  final Marker? initialMarker;
  final Completer<GoogleMapController>? mapControllerCompleter;

  // Controllers (passed from parent)
  final TextEditingController houseNumberController;
  final TextEditingController soiController;
  final TextEditingController roadController;
  final TextEditingController? buildingVillageController; // Optional
  final TextEditingController subdistrictController;
  final TextEditingController districtController;
  final TextEditingController provinceController;
  final TextEditingController postalCodeController;
  final TextEditingController addressController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;

  const AddressLocationSection({
    super.key,
    required this.isReadOnly,
    this.initialLocation,
    this.initialMarker,
    this.mapControllerCompleter,
    required this.houseNumberController,
    required this.soiController,
    required this.roadController,
    this.buildingVillageController,
    required this.subdistrictController,
    required this.districtController,
    required this.provinceController,
    required this.postalCodeController,
    required this.addressController,
    required this.latitudeController,
    required this.longitudeController,
  });

  @override
  State<AddressLocationSection> createState() => _AddressLocationSectionState();
}

class _AddressLocationSectionState extends State<AddressLocationSection> {
  // Thai Address Data
  List<Map<String, dynamic>> _thaiAddresses = [];
  bool _isLoadingAddress = true;

  // Location state
  LatLng? _selectedLocation;
  Marker? _locationMarker;
  bool _isMapReady = false;

  // Flags for preventing circular updates
  bool _isUpdatingFromMap = false;
  bool _isManualAddressInput = false;

  // Debounce timer for address field changes
  Timer? _geocodeDebounceTimer;

  // Map controller completer (use provided or create new)
  late final Completer<GoogleMapController> _mapControllerCompleter;

  @override
  void initState() {
    super.initState();
    _mapControllerCompleter =
        widget.mapControllerCompleter ?? Completer<GoogleMapController>();
    _selectedLocation = widget.initialLocation;
    _locationMarker = widget.initialMarker;
    _loadThaiAddresses();
    _setupAddressFieldListeners();

    // Delay map initialization on web
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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

  @override
  void dispose() {
    _geocodeDebounceTimer?.cancel();
    super.dispose();
  }

  /// Load Thai address data from assets
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
    } catch (e) {
      debugPrint('Error loading thai address: $e');
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  /// Setup listeners for address field changes
  void _setupAddressFieldListeners() {
    if (widget.isReadOnly) return;

    // Group A (Manual Input)
    widget.houseNumberController.addListener(_onAddressFieldChanged);
    widget.soiController.addListener(_onAddressFieldChanged);
    widget.roadController.addListener(_onAddressFieldChanged);
    if (widget.buildingVillageController != null) {
      widget.buildingVillageController!.addListener(_onAddressFieldChanged);
    }

    // Group B (Thai Address)
    widget.subdistrictController.addListener(_onAddressFieldChanged);
    widget.districtController.addListener(_onAddressFieldChanged);
    widget.provinceController.addListener(_onAddressFieldChanged);
    widget.postalCodeController.addListener(_onAddressFieldChanged);
  }

  /// Handle address field changes (Form -> Map)
  /// Debounced to avoid too many geocoding calls
  void _onAddressFieldChanged() {
    // Skip if update is coming from map
    if (_isUpdatingFromMap) return;

    // Mark that user is manually typing
    _isManualAddressInput = true;

    // Cancel previous timer
    _geocodeDebounceTimer?.cancel();

    // Debounce geocoding by 800ms
    _geocodeDebounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted && _shouldAttemptGeocodeFromManualFields()) {
        _geocodeFromAddress();
      }
    });
  }

  /// Check if we should attempt geocoding from manual fields
  bool _shouldAttemptGeocodeFromManualFields() {
    // Manual fields (Group A)
    final hasHouseSoiRoad =
        widget.houseNumberController.text.trim().isNotEmpty ||
        widget.soiController.text.trim().isNotEmpty ||
        widget.roadController.text.trim().isNotEmpty;

    // Thai address fields (Group B)
    final hasProvince = widget.provinceController.text.trim().isNotEmpty;
    final hasDistrict = widget.districtController.text.trim().isNotEmpty;
    final hasSubdistrict = widget.subdistrictController.text.trim().isNotEmpty;
    final hasPostal = widget.postalCodeController.text.trim().isNotEmpty;

    final hasAnyThai =
        hasProvince || hasDistrict || hasSubdistrict || hasPostal;

    // If user fills Group A, only geocode when Group B is complete
    if (hasHouseSoiRoad) {
      return hasProvince && hasDistrict && hasSubdistrict && hasPostal;
    }

    // If user only fills Group B, geocode with what they have
    return hasAnyThai;
  }

  /// Build geocode candidates from current field values
  List<String> _buildGeocodeCandidates() {
    final house = widget.houseNumberController.text.trim();
    final soi = widget.soiController.text.trim();
    final road = widget.roadController.text.trim();
    final subdistrict = widget.subdistrictController.text.trim();
    final district = widget.districtController.text.trim();
    final province = widget.provinceController.text.trim();
    final postal = widget.postalCodeController.text.trim();

    final hasHouseSoiRoad =
        house.isNotEmpty || soi.isNotEmpty || road.isNotEmpty;
    final thaiCompleteForHouse =
        subdistrict.isNotEmpty &&
        district.isNotEmpty &&
        province.isNotEmpty &&
        postal.isNotEmpty;

    final candidates = <String>[];

    if (hasHouseSoiRoad && thaiCompleteForHouse) {
      // Most specific -> less specific
      candidates.addAll([
        _joinAddressParts([
          house,
          soi,
          road,
          subdistrict,
          district,
          province,
          postal,
        ]),
        _joinAddressParts([
          house,
          road,
          subdistrict,
          district,
          province,
          postal,
        ]),
        _joinAddressParts([house, subdistrict, district, province, postal]),
        _joinAddressParts([subdistrict, district, province, postal]),
        _joinAddressParts([district, province, postal]),
        _joinAddressParts([province, postal]),
      ]);
      return candidates.where((e) => e.isNotEmpty).toList();
    }

    // Thai-only: search with whatever exists
    candidates.addAll([
      _joinAddressParts([subdistrict, district, province, postal]),
      _joinAddressParts([district, province, postal]),
      _joinAddressParts([province, postal]),
      _joinAddressParts([province]),
    ]);

    return candidates.where((e) => e.isNotEmpty).toList();
  }

  String _joinAddressParts(List<String> parts) {
    final normalized = parts.where((p) => p.trim().isNotEmpty).toList();
    return normalized.join(', ');
  }

  /// Geocode from address text and update map location (Form -> Map)
  /// IMPORTANT: DO NOT overwrite text fields with geocoding results
  Future<void> _geocodeFromAddress() async {
    if (widget.isReadOnly) return;

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

        // Update BLoC state
        context.read<PropertyFormBloc>().add(
          PropertyFormLocationChanged(location),
        );

        setState(() {
          _selectedLocation = location;
          widget.latitudeController.text = lat.toStringAsFixed(8);
          widget.longitudeController.text = lng.toStringAsFixed(8);

          // Update formatted address (read-only field)
          if (formattedAddress != null && formattedAddress.isNotEmpty) {
            widget.addressController.text = formattedAddress;
          }

          _locationMarker = Marker(
            markerId: const MarkerId('property_location'),
            position: location,
            draggable: !widget.isReadOnly,
            onDragEnd: !widget.isReadOnly
                ? (newPosition) {
                    _onMapDragEnd(newPosition);
                  }
                : null,
          );
        });

        // Reset flag after delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _isManualAddressInput = false;
          }
        });

        // Stop at first successful match
        break;
      }
    } catch (_) {
      // Silently ignore geocoding errors
      if (mounted) {
        _isManualAddressInput = false;
      }
    }
  }

  /// Handle map tap (Map -> Form)
  void _onMapTap(LatLng location) {
    if (widget.isReadOnly) return;
    _updateLocationFromMap(location);
  }

  /// Handle map marker drag end (Map -> Form)
  void _onMapDragEnd(LatLng newPosition) {
    if (widget.isReadOnly) return;
    _updateLocationFromMap(newPosition);
  }

  /// Update all fields from map location (Map -> Form)
  /// This is the ONLY time Group A fields are auto-filled
  Future<void> _updateLocationFromMap(LatLng location) async {
    if (widget.isReadOnly) return;

    // Set flag to prevent circular updates
    _isUpdatingFromMap = true;

    // Update BLoC state
    context.read<PropertyFormBloc>().add(PropertyFormLocationChanged(location));

    setState(() {
      _selectedLocation = location;
      widget.latitudeController.text = location.latitude.toStringAsFixed(8);
      widget.longitudeController.text = location.longitude.toStringAsFixed(8);
      _locationMarker = Marker(
        markerId: const MarkerId('property_location'),
        position: location,
        draggable: !widget.isReadOnly,
        onDragEnd: !widget.isReadOnly
            ? (newPosition) {
                _onMapDragEnd(newPosition);
              }
            : null,
      );
    });

    // Reverse geocode to get address
    await _fetchAddressFromCoordinates(location.latitude, location.longitude);
  }

  /// Reverse geocode coordinates and update ALL fields (Map -> Form)
  Future<void> _fetchAddressFromCoordinates(double lat, double lng) async {
    if (widget.isReadOnly) return;

    try {
      final placesService = DependencyInjection.placesService;
      final result = await placesService.reverseGeocode(lat: lat, lng: lng);

      if (result.isNotEmpty && mounted) {
        final address = result['address'];
        if (address != null && address.toString().isNotEmpty) {
          // Update BLoC state
          context.read<PropertyFormBloc>().add(
            PropertyFormAddressUpdated(
              address: address.toString(),
              district: result['district']?.toString(),
              subdistrict: result['subdistrict']?.toString(),
              state: result['state']?.toString(),
              country: result['country']?.toString(),
              postalCode: result['postalCode']?.toString(),
              houseNumber: result['houseNumber']?.toString(),
              soi: result['soi']?.toString(),
              road: result['road']?.toString(),
            ),
          );
        }

        // Reset manual input flag to allow field updates
        _isManualAddressInput = false;

        setState(() {
          // Update address field
          widget.addressController.text = result['address'] ?? '';

          // Update Group A (Manual Input) - ONLY time these are auto-filled
          widget.houseNumberController.text = result['houseNumber'] ?? '';
          widget.soiController.text = result['soi'] ?? '';
          widget.roadController.text = result['road'] ?? '';

          // Update Group B (Thai Address)
          widget.districtController.text = result['district'] ?? '';
          widget.subdistrictController.text = result['subdistrict'] ?? '';
          widget.provinceController.text = result['state'] ?? '';
          widget.postalCodeController.text = result['postalCode'] ?? '';
        });
      }
    } catch (_) {
      // Silently ignore errors
    } finally {
      // Reset flag after delay to prevent sync issues
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _isUpdatingFromMap = false;
        }
      });
    }
  }

  /// Build Thai Address TypeAhead field (Group B)
  Widget _buildThaiAddressTypeAhead({
    required TextEditingController controller,
    required String label,
    required String searchKey,
    bool isRequired = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired),
        const SizedBox(height: 8),
        TypeAheadField<Map<String, dynamic>>(
          controller: controller,
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: !widget.isReadOnly,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: label,
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFA4A7AE),
                ),
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
                  borderSide: BorderSide(
                    color: widget.isReadOnly
                        ? AppColors.baseGrey
                        : AppColors.primary,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.baseGrey),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                filled: widget.isReadOnly,
                fillColor: widget.isReadOnly ? const Color(0xFFFFFFFF) : null,
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: widget.isReadOnly
                      ? AppColors.baseGrey
                      : AppColors.baseDarkGrey,
                ),
              ),
            );
          },
          suggestionsCallback: (pattern) {
            if (_isLoadingAddress) return const [];

            Iterable<Map<String, dynamic>> filtered;
            if (pattern.isEmpty) {
              if (searchKey == 'zipcode') {
                filtered = _thaiAddresses.where((address) {
                  final zip = num.tryParse(address['zipcode'].toString()) ?? 0;
                  return zip >= 11000;
                });
              } else {
                filtered = _thaiAddresses;
              }
            } else {
              final searchPattern = pattern.toLowerCase();
              final isNumeric = RegExp(r'^\d').hasMatch(pattern);

              filtered = _thaiAddresses.where((address) {
                final value = address[searchKey]?.toString() ?? '';
                final valueLower = value.toLowerCase();

                if (searchKey == 'zipcode' && isNumeric) {
                  return value.startsWith(pattern);
                } else if (isNumeric) {
                  return valueLower.startsWith(searchPattern);
                } else {
                  return valueLower.startsWith(searchPattern);
                }
              });
            }

            final resultList = filtered.toList();
            resultList.sort((a, b) {
              final aVal = a[searchKey];
              final bVal = b[searchKey];

              if (searchKey == 'zipcode') {
                final aNum = num.tryParse(aVal.toString()) ?? 0;
                final bNum = num.tryParse(bVal.toString()) ?? 0;
                return aNum.compareTo(bNum);
              }

              return aVal.toString().compareTo(bVal.toString());
            });

            // Group by postal code if available
            final currentPostal = widget.postalCodeController.text.trim();
            if (currentPostal.isNotEmpty && searchKey != 'zipcode') {
              final grouped = resultList.where((item) {
                final itemPostal = item['zipcode']?.toString().trim() ?? '';
                return itemPostal == currentPostal;
              }).toList();

              if (grouped.isNotEmpty) {
                return grouped
                    .where((item) => item[searchKey] != null)
                    .toList();
              }
            }

            return resultList.where((item) => item[searchKey] != null).toList();
          },
          itemBuilder: (context, suggestion) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.baseLightGrey,
                    width: 0.5,
                  ),
                ),
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                title: Text(
                  suggestion[searchKey].toString(),
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  '${suggestion['amphoe']} › ${suggestion['province']} › ${suggestion['zipcode']}',
                  style: TextStyle(fontSize: 11, color: AppColors.baseGrey),
                ),
              ),
            );
          },
          onSelected: (suggestion) {
            // Set flags to prevent listener from triggering geocode
            _isUpdatingFromMap = true;
            _isManualAddressInput = true;

            final selectedPostal =
                suggestion['zipcode']?.toString().trim() ?? '';

            setState(() {
              // Update the selected field
              if (searchKey == 'district') {
                widget.subdistrictController.text =
                    suggestion['district'] ?? '';
              } else if (searchKey == 'amphoe') {
                widget.districtController.text = suggestion['amphoe'] ?? '';
              } else if (searchKey == 'province') {
                widget.provinceController.text = suggestion['province'] ?? '';
              } else if (searchKey == 'zipcode') {
                widget.postalCodeController.text = selectedPostal;
              }

              // Auto-fill other 3 fields in Group B
              if (selectedPostal.isNotEmpty) {
                final sameGroupAddresses = _thaiAddresses.where((addr) {
                  final addrPostal = addr['zipcode']?.toString().trim() ?? '';
                  return addrPostal == selectedPostal;
                }).toList();

                if (sameGroupAddresses.isNotEmpty) {
                  final groupAddress = sameGroupAddresses.first;

                  if (searchKey != 'district') {
                    widget.subdistrictController.text =
                        groupAddress['district'] ??
                        widget.subdistrictController.text;
                  }
                  if (searchKey != 'amphoe') {
                    widget.districtController.text =
                        groupAddress['amphoe'] ??
                        widget.districtController.text;
                  }
                  if (searchKey != 'province') {
                    widget.provinceController.text =
                        groupAddress['province'] ??
                        widget.provinceController.text;
                  }
                  if (searchKey != 'zipcode') {
                    widget.postalCodeController.text = selectedPostal;
                  }
                }
              }
            });

            // Reset flags after delay
            Future.delayed(const Duration(milliseconds: 100), () {
              _isUpdatingFromMap = false;
            });

            // Trigger geocode to update map
            _geocodeFromAddress();
          },
          decorationBuilder: (context, child) {
            return Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: child,
              ),
            );
          },
        ),
      ],
    );
  }

  /// Build field label
  Widget _buildFieldLabel(String label, bool isRequired) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        if (isRequired)
          Text(
            ' *',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.ruby500),
          ),
      ],
    );
  }

  /// Build Google Maps widget
  Widget _buildMapWidget() {
    if (!_isMapReady) {
      return SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group A: Manual Input Fields
        Row(
          children: [
            Expanded(
              child: StandardTextField(
                label: 'เลขที่บ้าน/ห้อง',
                controller: widget.houseNumberController,
                isRequired: true,
                isReadOnly: widget.isReadOnly,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StandardTextField(
                label: 'ซอย/ตรอก/หมู่บ้าน',
                controller: widget.soiController,
                isRequired: false,
                isReadOnly: widget.isReadOnly,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StandardTextField(
                label: 'ถนน',
                controller: widget.roadController,
                isRequired: false,
                isReadOnly: widget.isReadOnly,
              ),
            ),
            if (widget.buildingVillageController != null) ...[
              const SizedBox(width: 16),
              Expanded(
                child: StandardTextField(
                  label: 'อาคาร/หมู่บ้าน',
                  controller: widget.buildingVillageController!,
                  isRequired: false,
                  isReadOnly: widget.isReadOnly,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // Group B: Thai Address Auto-complete
        Row(
          children: [
            Expanded(
              child: _buildThaiAddressTypeAhead(
                controller: widget.subdistrictController,
                label: 'แขวง/ตำบล',
                searchKey: 'district',
                isRequired: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildThaiAddressTypeAhead(
                controller: widget.districtController,
                label: 'เขต/อำเภอ',
                searchKey: 'amphoe',
                isRequired: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildThaiAddressTypeAhead(
                controller: widget.provinceController,
                label: 'จังหวัด',
                searchKey: 'province',
                isRequired: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildThaiAddressTypeAhead(
                controller: widget.postalCodeController,
                label: 'รหัสไปรษณีย์',
                searchKey: 'zipcode',
                isRequired: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Google Maps
        _buildMapWidget(),
      ],
    );
  }
}
