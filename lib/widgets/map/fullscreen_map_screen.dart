import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/widgets/app_search_bar.dart';
import 'package:youragent/utils/map_marker_utils.dart';

/// Fullscreen map view for properties with all controls
class FullscreenMapScreen extends StatefulWidget {
  final List<Property> properties;
  final bool showSearch;

  const FullscreenMapScreen({
    super.key,
    required this.properties,
    this.showSearch = true,
  });

  @override
  State<FullscreenMapScreen> createState() => _FullscreenMapScreenState();
}

class _FullscreenMapScreenState extends State<FullscreenMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  BitmapDescriptor? _customMarkerIcon;
  final TextEditingController _searchController = TextEditingController();
  bool _mapError = false;
  bool _isMapReady = false;
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
    for (final property in widget.properties) {
      _markers.add(
        Marker(
          markerId: MarkerId(property.id?.toString() ?? property.code!),
          position: LatLng(property.latitude, property.longitude),
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
    // TODO: Implement get current location and move camera
    debugPrint('My location tapped');
  }

  void _onLayersTapped() {
    // TODO: Implement map type selection (normal, satellite, terrain, hybrid)
    debugPrint('Layers tapped');
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
    return Scaffold(
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                );
              }
              // Only create GoogleMap when _isMapReady is true
              return GoogleMap(
                key: const ValueKey('fullscreen_map'),
                initialCameraPosition: const CameraPosition(
                  target: _center,
                  zoom: 12,
                ),
                markers: _markers,
                onMapCreated: (controller) {
                  _mapController = controller;
                },
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
                  if (widget.showSearch)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: const AppSearchBar(),
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
