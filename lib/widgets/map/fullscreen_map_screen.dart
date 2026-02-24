import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/utils/map_marker_utils.dart';

/// Fullscreen map view for properties with all controls
class FullscreenMapScreen extends StatefulWidget {
  final List<Property> properties;
  final bool showSearch;
  final LatLng? initialLocation;
  final String? title;
  final String? snippet;

  const FullscreenMapScreen({
    super.key,
    this.properties = const [],
    this.showSearch = true,
    this.initialLocation,
    this.title,
    this.snippet,
  });

  @override
  State<FullscreenMapScreen> createState() => _FullscreenMapScreenState();
}

class _FullscreenMapScreenState extends State<FullscreenMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  BitmapDescriptor? _customMarkerIcon;
  final TextEditingController _searchController = TextEditingController();
  final SuggestionsController<Property> _suggestionsController =
      SuggestionsController();
  bool _mapError = false;
  bool _isMapReady = false;
  bool _focusListenerAdded = false;
  MapType _mapType = MapType.normal;
  // Set to true when Google Maps API key is configured in Info.plist
  static const bool _mapsEnabled = true;

  // Bangkok center coordinates
  static const LatLng _center = LatLng(13.7563, 100.5018);

  @override
  void initState() {
    super.initState();
    if (!_mapsEnabled) {
      _mapError = true;
      return;
    }
    // Delay map initialization to ensure Google Maps SDK is fully initialized
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _loadCustomMarker();
      }
    });
  }

  Future<void> _loadCustomMarker() async {
    try {
      _customMarkerIcon = await MapMarkerUtils.createCustomMarkerIcon();
      _createMarkers();
      if (mounted) {
        setState(() {
          _isMapReady = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading map markers: $e');
      if (mounted) {
        setState(() {
          _mapError = true;
        });
      }
    }
  }

  void _createMarkers() {
    _markers.clear();
    if (widget.initialLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('initialLocation'),
          position: widget.initialLocation!,
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: widget.title ?? 'Unknown Location',
            snippet: widget.snippet ?? 'Unknown Location address',
          ),
        ),
      );
    }

    for (final property in widget.properties) {
      if (property.latitude == null || property.longitude == null) {
        continue;
      }
      _markers.add(
        Marker(
          markerId: MarkerId(property.id?.toString() ?? property.code!),
          position: LatLng(property.latitude!, property.longitude!),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: property.title,
            snippet: property.address,
          ),
        ),
      );
    }
  }

  void _onMyLocationTapped() {
    if (_mapController == null || _markers.isEmpty) return;

    if (_markers.length == 1) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_markers.first.position, 15),
      );
      return;
    }

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final marker in _markers) {
      final pos = marker.position;
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude < minLng) minLng = pos.longitude;
      if (pos.longitude > maxLng) maxLng = pos.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _onLayersTapped() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.baseLightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'เลือกประเภทแผนที่',
              style: GoogleFonts.anuphan(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.baseBlack,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMapTypeItem(MapType.normal, 'ปกติ', Icons.map),
                _buildMapTypeItem(
                  MapType.satellite,
                  'ดาวเทียม',
                  Icons.satellite,
                ),
                _buildMapTypeItem(MapType.terrain, 'ภูมิประเทศ', Icons.terrain),
                _buildMapTypeItem(MapType.hybrid, 'ผสม', Icons.layers),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapTypeItem(MapType type, String label, IconData icon) {
    final isSelected = _mapType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _mapType = type;
        });
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.brandLightGreen
                  : AppColors.basePaleGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.brandGreen : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.brandGreen : AppColors.baseGrey,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.anuphan(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.brandGreen : AppColors.baseDarkGrey,
            ),
          ),
        ],
      ),
    );
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _suggestionsController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Widget _buildMapPlaceholder() {
    return Container(
      color: AppColors.basePaleGrey,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: AppColors.baseGrey),
            const SizedBox(height: 16),
            Text(
              'Map unavailable',
              style: TextStyle(
                color: AppColors.baseDarkGrey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please configure Google Maps API key',
              style: TextStyle(color: AppColors.baseGrey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            // Full screen Google Map or placeholder
            Builder(
              builder: (context) {
                if (_mapError || !_mapsEnabled) {
                  return _buildMapPlaceholder();
                }
                if (!_isMapReady) {
                  return Container(
                    color: AppColors.basePaleGrey,
                    child: const Center(
                      child: SpinKitFadingCircle(
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  );
                }
                // Only create GoogleMap when _isMapReady is true
                return GoogleMap(
                  key: const ValueKey('fullscreen_map'),
                  initialCameraPosition: CameraPosition(
                    target: widget.initialLocation ?? _center,
                    zoom: 12,
                  ),
                  markers: _markers,
                  mapType: _mapType,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    // Auto fit bounds when map is created if there are properties
                    if (widget.properties.isNotEmpty) {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        _onMyLocationTapped();
                      });
                    }
                  },
                  onTap: (_) => FocusScope.of(context).unfocus(),
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                );
              },
            ),

            // Top Controls (Back button, Search, Maximize)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Search Bar
                    if (widget.showSearch && widget.properties.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TypeAheadField<Property>(
                            constraints: BoxConstraints(maxHeight: 256),
                            controller: _searchController,
                            suggestionsController: _suggestionsController,
                            hideOnEmpty: false,
                            builder: (context, controller, focusNode) {
                              // Open suggestions on focus - only add listener once
                              if (!_focusListenerAdded) {
                                focusNode.addListener(() {
                                  if (focusNode.hasFocus &&
                                      _searchController.text.isEmpty) {
                                    _suggestionsController.refresh();
                                  }
                                });
                                _focusListenerAdded = true;
                              }
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                style: GoogleFonts.anuphan(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.baseBlack,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'ค้นหาอสังหาฯ...',
                                  hintStyle: GoogleFonts.anuphan(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.baseGrey,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.baseGrey,
                                    size: 20,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            size: 18,
                                            color: AppColors.baseGrey,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 11,
                                  ),
                                ),
                              );
                            },
                            suggestionsCallback: (pattern) {
                              final List<Property> filteredProperties;
                              if (pattern.trim().isEmpty) {
                                filteredProperties = List.from(
                                  widget.properties,
                                );
                              } else {
                                final searchPattern = pattern
                                    .toLowerCase()
                                    .trim();
                                filteredProperties = widget.properties.where((
                                  property,
                                ) {
                                  final title = property.title.toLowerCase();
                                  final address =
                                      property.address?.toLowerCase() ?? '';
                                  return title.contains(searchPattern) ||
                                      address.contains(searchPattern);
                                }).toList();
                              }

                              // Sort alphabetically by title
                              filteredProperties.sort(
                                (a, b) => a.title.compareTo(b.title),
                              );
                              return filteredProperties;
                            },

                            itemBuilder: (context, property) {
                              return ListTile(
                                visualDensity: VisualDensity.compact,
                                leading: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: AppColors.basePaleGrey,
                                  ),
                                  child: property.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: property.imageUrl!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                                  child: SpinKitFadingCircle(
                                                    color: AppColors.primary,
                                                    size: 20,
                                                  ),
                                                ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => SvgPicture.asset(
                                                  'assets/icons/building.svg',
                                                  width: 24,
                                                  height: 24,
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                        AppColors.baseGrey,
                                                        BlendMode.srcIn,
                                                      ),
                                                ),
                                          ),
                                        )
                                      : SvgPicture.asset(
                                          'assets/icons/building.svg',
                                          width: 24,
                                          height: 24,
                                          colorFilter: const ColorFilter.mode(
                                            AppColors.baseGrey,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                ),
                                title: Text(
                                  property.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.anuphan(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.baseBlack,
                                  ),
                                ),
                                subtitle: Text(
                                  property.address ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.anuphan(
                                    fontSize: 10,
                                    color: AppColors.baseDarkGrey,
                                  ),
                                ),
                              );
                            },
                            onSelected: (property) {
                              _searchController.text = property.title;
                              if (property.latitude != null &&
                                  property.longitude != null) {
                                _mapController?.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    LatLng(
                                      property.latitude!,
                                      property.longitude!,
                                    ),
                                    16,
                                  ),
                                );
                              }
                            },
                            decorationBuilder: (context, child) {
                              return Material(
                                type: MaterialType.canvas,
                                elevation: 4,
                                borderRadius: BorderRadius.circular(12),
                                child: child,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

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
        ),
      ),
    );
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
}
