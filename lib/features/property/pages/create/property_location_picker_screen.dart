import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../services/google_places_service.dart';
import '../../../../utils/location_permission_helper.dart';
import '../../../../widgets/buttons/app_button.dart';
import '../../../../widgets/dialogs/status_dialog.dart';
import '../../../../widgets/form_fields/app_text_form_field.dart';
import '../../widgets/property_map_view.dart';

class PropertyLocationPickerResult {
  final LatLng latLng;
  final String formattedAddressTh;
  final String formattedAddressEn;
  final Map<String, String> components;

  const PropertyLocationPickerResult({
    required this.latLng,
    required this.formattedAddressTh,
    required this.formattedAddressEn,
    required this.components,
  });
}

class PropertyLocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const PropertyLocationPickerScreen({super.key, this.initialLocation});

  static Future<PropertyLocationPickerResult?> open(
    BuildContext context, {
    LatLng? initialLocation,
  }) {
    return Navigator.of(context).push<PropertyLocationPickerResult>(
      MaterialPageRoute(
        builder: (_) =>
            PropertyLocationPickerScreen(initialLocation: initialLocation),
      ),
    );
  }

  @override
  State<PropertyLocationPickerScreen> createState() =>
      _PropertyLocationPickerScreenState();
}

class _PropertyLocationPickerScreenState
    extends State<PropertyLocationPickerScreen> {
  static const LatLng _bangkok = LatLng(13.7563, 100.5018);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  Timer? _debounce;
  bool _loading = false;
  bool _isTyping = false;

  List<PlacePrediction> _predictions = const [];

  late LatLng _selected;
  LatLng? _cameraTarget;

  String _formattedTh = '';
  String _formattedEn = '';
  Map<String, String> _components = const {};

  late final GooglePlacesService _places;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation ?? _bangkok;
    _cameraTarget = widget.initialLocation;

    // Configure via --dart-define=GOOGLE_MAPS_API_KEY=...
    const apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    _places = GooglePlacesService(apiKey: apiKey);

    // Initial reverse so field shows a value if initialLocation provided
    if (widget.initialLocation != null) {
      _reverseAll(_selected, updateSearchText: true);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _reverseAll(
    LatLng latLng, {
    bool updateSearchText = false,
  }) async {
    setState(() => _loading = true);
    try {
      // Thai display (platform geocoder)
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      final p = placemarks.isNotEmpty ? placemarks.first : null;
      final formattedTh = p != null ? _formatPlacemarkTh(p) : '';

      // English + components (Google Geocoding)
      String formattedEn = '';
      Map<String, String> components = const {};
      if (_places.isConfigured) {
        final r = await _places.reverseGeocode(
          lat: latLng.latitude,
          lng: latLng.longitude,
          language: 'en',
        );
        if (r != null) {
          formattedEn = r.formattedAddressEn;
          components = r.components;
        }
      }

      if (!mounted) return;
      setState(() {
        _formattedTh = formattedTh;
        _formattedEn = formattedEn.isNotEmpty ? formattedEn : formattedTh;
        _components = components;
        if (updateSearchText && formattedTh.isNotEmpty && !_isTyping) {
          _searchController.text = formattedTh;
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatPlacemarkTh(Placemark p) {
    return [
      p.street,
      p.subLocality,
      p.subAdministrativeArea,
      p.administrativeArea,
      p.postalCode,
    ].where((e) => e != null && e.isNotEmpty).join(' ');
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    setState(() => _isTyping = value.trim().isNotEmpty);
    if (value.trim().isEmpty) {
      setState(() => _predictions = const []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      if (!_places.isConfigured) {
        if (!mounted) return;
        await StatusDialog.showWarning(
          context: context,
          title: 'ตั้งค่า API Key',
          message:
              'กรุณาใส่ Google Maps API key ด้วย --dart-define=GOOGLE_MAPS_API_KEY=...',
        );
        return;
      }

      final items = await _places.autocomplete(input: value, language: 'th');
      if (!mounted) return;
      setState(() => _predictions = items);
    });
  }

  Future<void> _selectPrediction(PlacePrediction p) async {
    if (!_places.isConfigured) return;
    setState(() => _loading = true);
    try {
      final details = await _places.placeDetails(
        placeId: p.placeId,
        language: 'en',
      );
      if (details == null) return;
      final latLng = LatLng(details.lat, details.lng);

      if (!mounted) return;
      setState(() {
        _selected = latLng;
        _cameraTarget = latLng;
        _formattedEn = details.formattedAddressEn;
        _components = details.components;
        _predictions = const [];
        _isTyping = false;
      });

      // Thai text (platform reverse)
      await _reverseAll(latLng, updateSearchText: true);
      if (!mounted) return;
      _searchFocus.unfocus();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    final pos = await LocationPermissionHelper.getCurrentPosition(context);
    if (pos == null) return;
    final latLng = LatLng(pos.latitude, pos.longitude);
    setState(() {
      _selected = latLng;
      _cameraTarget = latLng;
      _predictions = const [];
      _isTyping = false;
    });
    await _reverseAll(latLng, updateSearchText: true);
  }

  void _onMapIdle(LatLng center) {
    _selected = center;
    // when user drags the map, stop showing suggestions
    if (_predictions.isNotEmpty) {
      setState(() => _predictions = const []);
    }
    _reverseAll(center, updateSearchText: false);
  }

  Future<void> _onSave() async {
    if (_formattedTh.trim().isEmpty) {
      StatusDialog.showWarning(
        context: context,
        title: 'เลือกตำแหน่ง',
        message: 'กรุณาเลือกตำแหน่งบนแผนที่หรือค้นหาสถานที่',
      );
      return;
    }

    final confirmed = await StatusDialog.showConfirmation(
      context: context,
      title: 'บันทึกตำแหน่งนี้?',
      message: 'ยืนยันการเลือกตำแหน่งนี้สำหรับประกาศทรัพย์',
      confirmText: 'บันทึก',
      cancelText: 'ยกเลิก',
    );
    if (!confirmed || !mounted) return;

    Navigator.of(context).pop(
      PropertyLocationPickerResult(
        latLng: _selected,
        formattedAddressTh: _formattedTh,
        formattedAddressEn: _formattedEn,
        components: _components,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseWhite,
      body: Stack(
        children: [
          // Map full screen (draggable + center pin)
          Positioned.fill(
            child: PropertyMapView(
              properties: const [],
              height: double.infinity,
              initialLocation: widget.initialLocation ?? _bangkok,
              cameraTarget: _cameraTarget,
              showCenterMarker: true,
              onCameraIdle: _onMapIdle,
              onCameraMove: (_) {
                // user is dragging map
                if (_predictions.isNotEmpty) {
                  setState(() => _predictions = const []);
                }
              },
            ),
          ),

          // Top search bar + suggestions (like screenshot)
          Positioned(
            left: 16,
            right: 16,
            top: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextFormField(
                      label: '',
                      controller: _searchController,
                      hintText: 'ค้นหา...',
                      suffix: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : const Icon(Icons.search, color: AppColors.baseGrey),
                      onChanged: _onSearchChanged,
                    ),
                    if (_predictions.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: AppColors.baseWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.baseLightGrey),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(maxHeight: 240),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: _predictions.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: AppColors.baseLightGrey,
                          ),
                          itemBuilder: (context, i) {
                            final item = _predictions[i];
                            return ListTile(
                              dense: true,
                              title: Text(
                                item.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.anuphan(
                                  fontSize: 13,
                                  color: AppColors.baseBlack,
                                ),
                              ),
                              onTap: () => _selectPrediction(item),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Back button (top-left like screenshot)
          Positioned(
            left: 16,
            top: 64,
            child: SafeArea(
              child: Material(
                color: AppColors.baseWhite,
                borderRadius: BorderRadius.circular(12),
                elevation: 2,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(Icons.chevron_left, color: AppColors.baseBlack),
                  ),
                ),
              ),
            ),
          ),

          // Bottom panel (address + save button)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.baseWhite,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 24,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ที่อยู่ตามแผนที่',
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseBlack,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formattedTh.isNotEmpty ? _formattedTh : 'กำลังค้นหาที่อยู่…',
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseDarkGrey,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '(พิกัด: ${_selected.latitude.toStringAsFixed(7)}, ${_selected.longitude.toStringAsFixed(7)})',
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseGrey,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'บันทึก',
                    style: AppButtonStyle.primary,
                    onPressed: _onSave,
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    text: 'ใช้ตำแหน่งปัจจุบัน',
                    style: AppButtonStyle.outline,
                    onPressed: _useCurrentLocation,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
