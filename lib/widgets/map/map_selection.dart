import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:youragent/core/di/dependency_injection.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/services/google_places_service.dart';
import 'package:youragent/utils/permission_helper.dart';
import 'package:youragent/widgets/form_fields/app_text_form_field.dart';

class LocationResult {
  final LatLng latLng;
  final String formattedAddressTh;
  final String formattedAddressEn;
  final Map<String, String> components;

  const LocationResult({
    required this.latLng,
    required this.formattedAddressTh,
    required this.formattedAddressEn,
    required this.components,
  });
}

class MapSelection extends StatefulWidget {
  final LatLng? initialLocation;
  final ValueChanged<LocationResult>? onLocationChanged;
  final double height;
  final bool showSearch;
  final bool showControls;
  final VoidCallback? onBackTapped;

  const MapSelection({
    super.key,
    this.initialLocation,
    this.onLocationChanged,
    this.height = double.infinity,
    this.showSearch = true,
    this.showControls = true,
    this.onBackTapped,
  });

  @override
  State<MapSelection> createState() => _MapSelectionState();
}

class _MapSelectionState extends State<MapSelection> {
  static const LatLng _bangkok = LatLng(13.7563, 100.5018);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  Timer? _debounce;
  bool _searchLoading = false;
  bool _isTyping = false;
  List<PlacePrediction> _predictions = const [];
  String _lastQuery = '';
  Object? _lastSearchError;

  late LatLng _selected;
  GoogleMapController? _mapController;
  LatLng? _lastTrackedPosition;
  MapType _currentMapType = MapType.normal;
  late final Key _mapKey;

  GooglePlacesService get _places => DependencyInjection.googlePlacesService;

  @override
  void initState() {
    super.initState();
    _mapKey = UniqueKey();
    _selected = widget.initialLocation ?? _bangkok;
    _lastTrackedPosition = _selected;

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus && mounted) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && !_searchFocus.hasFocus) {
            setState(() {
              _predictions = const [];
              _isTyping = _searchController.text.trim().isNotEmpty;
            });
          }
        });
      }
    });

    if (widget.initialLocation != null) {
      _reverseAll(_selected, updateSearchText: true);
    }
  }

  @override
  void didUpdateWidget(MapSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLocation != null &&
        widget.initialLocation != oldWidget.initialLocation) {
      _selected = widget.initialLocation!;
      _animateToTarget(_selected);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _animateToTarget(LatLng target) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(target));
  }

  Future<void> _reverseAll(
    LatLng latLng, {
    bool updateSearchText = false,
  }) async {
    try {
      String formattedTh = '';
      String formattedEn = '';
      Map<String, String> components = const {};

      if (_places.isConfigured) {
        // 1. Fetch Thai Address
        final resTh = await _places.reverseGeocode(
          lat: latLng.latitude,
          lng: latLng.longitude,
          language: 'th',
        );
        if (resTh != null) {
          formattedTh = resTh
              .formattedAddressEn; // This helper currently uses this field name for any language
          components = resTh.components;
        }

        // 2. Fetch English Address
        final resEn = await _places.reverseGeocode(
          lat: latLng.latitude,
          lng: latLng.longitude,
          language: 'en',
        );
        if (resEn != null) {
          formattedEn = resEn.formattedAddressEn;
          // Merge components if they differ, though usually they are the same keys
          if (components.isEmpty) {
            components = resEn.components;
          }
        }
      }

      // Fallback to geocoding package if Google API failed or not configured
      if (formattedTh.isEmpty) {
        final placemarks = await placemarkFromCoordinates(
          latLng.latitude,
          latLng.longitude,
        );
        final p = placemarks.isNotEmpty ? placemarks.first : null;
        formattedTh = p != null ? _formatPlacemarkTh(p) : '';
      }

      if (!mounted) return;

      final result = LocationResult(
        latLng: latLng,
        formattedAddressTh: formattedTh,
        formattedAddressEn: formattedEn.isNotEmpty ? formattedEn : formattedTh,
        components: components,
      );

      widget.onLocationChanged?.call(result);

      setState(() {
        if (updateSearchText && formattedTh.isNotEmpty && !_isTyping) {
          _searchController.text = formattedTh;
        }
      });
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
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
    setState(() {
      _isTyping = value.trim().isNotEmpty;
      _lastQuery = value.trim();
      _lastSearchError = null;
    });

    if (value.trim().isEmpty) {
      setState(() {
        _predictions = const [];
        _searchLoading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 250), () async {
      if (!_places.isConfigured) return;

      if (mounted) setState(() => _searchLoading = true);
      try {
        final items = await _places.autocomplete(input: value, language: 'th');
        if (!mounted) return;
        setState(() {
          _predictions = items;
          _lastSearchError = null;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _predictions = const [];
          _lastSearchError = e;
        });
      } finally {
        if (mounted) setState(() => _searchLoading = false);
      }
    });
  }

  Future<void> _selectPrediction(PlacePrediction p) async {
    if (!_places.isConfigured) return;
    setState(() => _searchLoading = false);
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
        _predictions = const [];
        _isTyping = false;
        _searchController.text = p.description;
      });

      _animateToTarget(latLng);
      await _reverseAll(latLng, updateSearchText: true);
      _searchFocus.unfocus();
    } catch (e) {
      debugPrint('Select prediction error: $e');
    }
  }

  Future<void> _useCurrentLocation() async {
    final pos = await PermissionHelper.getCurrentPosition(context);
    if (pos == null) return;
    final latLng = LatLng(pos.latitude, pos.longitude);

    setState(() {
      _selected = latLng;
      _predictions = const [];
      _isTyping = false;
    });

    _animateToTarget(latLng);
    await _reverseAll(latLng, updateSearchText: true);
  }

  void _onMapIdle() {
    if (_lastTrackedPosition != null) {
      _selected = _lastTrackedPosition!;
      _reverseAll(_selected, updateSearchText: false);
    }
  }

  Widget _buildControlButton({
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 44,
          height: 44,
          padding: const EdgeInsets.all(10),
          child: SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.baseBlack,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showTypeaheadPanel =
        _searchFocus.hasFocus &&
        _isTyping &&
        (_searchLoading ||
            _predictions.isNotEmpty ||
            _lastSearchError != null ||
            !_places.isConfigured ||
            _lastQuery.isNotEmpty);

    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Underlying Map
          GoogleMap(
            key: _mapKey,
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation ?? _bangkok,
              zoom: 15,
            ),
            mapType: _currentMapType,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: (latLng) {
              _animateToTarget(latLng);
            },
            onCameraMove: (position) {
              _lastTrackedPosition = position.target;
              if (_predictions.isNotEmpty) {
                setState(() => _predictions = const []);
              }
            },
            onCameraIdle: _onMapIdle,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          ),

          // แสดง marker เมื่อมีตำแหน่งเริ่มต้น หรือเมื่อผู้ใช้เปลี่ยนหมุด/ค้นหาแล้วเลือก
          if (_selected != _bangkok || widget.initialLocation != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: SvgPicture.asset(
                  'assets/icons/map-marker-filled.svg',
                  width: 36,
                  height: 36,
                  colorFilter: const ColorFilter.mode(
                    AppColors.supportRedDark,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

          // Map Controls
          if (widget.showControls) ...[
            Positioned(
              left: 16,
              top:
                  MediaQuery.of(context).padding.top +
                  (widget.showSearch ? 84 : 0),
              child: _buildControlButton(
                iconPath: 'assets/icons/chevron-left.svg',
                onTap: () => Navigator.pop(context),
              ),
            ),

            // Right Side Controls (Layers, Location, Zoom)
            Positioned(
              right: 16,
              top:
                  MediaQuery.of(context).padding.top +
                  (widget.showSearch ? 84 : 0),
              child: Column(
                children: [
                  // Maximize/Exit Fullscreen Button
                  _buildControlButton(
                    iconPath: 'assets/icons/minimize.svg',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 12),

                  // Layer Toggle Button
                  _buildControlButton(
                    iconPath: 'assets/icons/layer.svg',
                    onTap: _onLayersTapped,
                  ),
                  const SizedBox(height: 12),

                  // Location Button
                  _buildControlButton(
                    iconPath: 'assets/icons/direction-up-right.svg',
                    onTap: _onMyLocationTapped,
                  ),
                  const SizedBox(height: 12),

                  // Zoom In Button
                  _buildControlButton(
                    iconPath: 'assets/icons/plus.svg',
                    onTap: _zoomIn,
                  ),
                  const SizedBox(height: 12),

                  // Zoom Out Button
                  _buildControlButton(
                    iconPath: 'assets/icons/minus.svg',
                    onTap: _zoomOut,
                  ),
                ],
              ),
            ),
          ],
          // Search Bar
          if (widget.showSearch)
            Positioned(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).padding.top + 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextFormField(
                    label: '',
                    controller: _searchController,
                    focusNode: _searchFocus,
                    hintText: 'ค้นหา...',
                    prefix: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SvgPicture.asset(
                        'assets/icons/search.svg',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          AppColors.baseGrey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    suffix: _searchLoading
                        ? const SizedBox(
                            width: 40,
                            height: 40,
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        : null,
                    onChanged: _onSearchChanged,
                  ),
                  if (showTypeaheadPanel)
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
                      child: _buildTypeaheadBody(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeaheadBody() {
    if (!_places.isConfigured) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Google Maps API Key not configured',
          style: GoogleFonts.anuphan(
            fontSize: 12,
            color: AppColors.baseDarkGrey,
          ),
        ),
      );
    }

    if (_searchLoading && _predictions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('กำลังค้นหา…'),
          ],
        ),
      );
    }

    if (_lastSearchError != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'ค้นหาไม่สำเร็จ: $_lastSearchError',
          style: GoogleFonts.anuphan(
            fontSize: 12,
            color: AppColors.supportRedDark,
          ),
        ),
      );
    }

    if (_predictions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'ไม่พบผลลัพธ์',
          style: GoogleFonts.anuphan(
            fontSize: 12,
            color: AppColors.baseDarkGrey,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _predictions.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.baseLightGrey),
      itemBuilder: (context, i) {
        final item = _predictions[i];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _selectPrediction(item),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.anuphan(
                  fontSize: 13,
                  color: AppColors.baseBlack,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onMyLocationTapped() {
    _useCurrentLocation();
  }

  void _onLayersTapped() {
    setState(() {
      // Cycle through: Normal -> Hybrid -> Terrain -> Normal
      switch (_currentMapType) {
        case MapType.normal:
          _currentMapType = MapType.hybrid;
          break;
        case MapType.hybrid:
          _currentMapType = MapType.terrain;
          break;
        case MapType.terrain:
          _currentMapType = MapType.normal;
          break;
        case MapType.satellite:
          // If somehow we're in satellite mode, go to normal
          _currentMapType = MapType.normal;
          break;
        case MapType.none:
          _currentMapType = MapType.normal;
          break;
      }
    });
    debugPrint('Map type changed to: $_currentMapType');
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }
}
