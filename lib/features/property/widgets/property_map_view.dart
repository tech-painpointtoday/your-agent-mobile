import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/domain/entities/property.dart';
import 'package:youragent/utils/map_marker_utils.dart';

/// Google Maps view widget for displaying properties on a map
class PropertyMapView extends StatefulWidget {
  final List<Property> properties;
  final double height;
  final VoidCallback? onMaximizeTapped;
  final ValueChanged<LatLng>? onCameraIdle;
  final ValueChanged<CameraPosition>? onCameraMove;
  final bool showCenterMarker;
  final LatLng? initialLocation;
  final LatLng? cameraTarget;
  final bool animateToTarget;

  const PropertyMapView({
    super.key,
    required this.properties,
    this.height = 248,
    this.onMaximizeTapped,
    this.onCameraIdle,
    this.onCameraMove,
    this.showCenterMarker = false,
    this.initialLocation,
    this.cameraTarget,
    this.animateToTarget = true,
  });

  @override
  State<PropertyMapView> createState() => _PropertyMapViewState();
}

class _PropertyMapViewState extends State<PropertyMapView> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  BitmapDescriptor? _customMarkerIcon;
  bool _mapError = false;
  bool _isMapReady = false;
  LatLng? _lastTrackedPosition;
  // Set to true when Google Maps API key is configured in Info.plist
  static const bool _mapsEnabled = true;

  // Bangkok center coordinates
  static const LatLng _center = LatLng(13.7563, 100.5018);

  @override
  void initState() {
    super.initState();
    if (!_mapsEnabled) {
      // Don't initialize map if not enabled
      _mapError = true;
      return;
    }
    // Delay map initialization significantly to ensure Google Maps SDK is fully initialized
    // The SDK needs time to initialize after AppDelegate setup
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _initializeMap();
      }
    });
  }

  Future<void> _initializeMap() async {
    try {
      await _loadCustomMarker();
      if (mounted) {
        setState(() {
          _isMapReady = true;
          _lastTrackedPosition = widget.initialLocation ?? _center;
        });
      }
    } catch (e) {
      debugPrint('Error initializing map: $e');
      if (mounted) {
        setState(() {
          _mapError = true;
        });
      }
    }
  }

  Future<void> _loadCustomMarker() async {
    _customMarkerIcon = await MapMarkerUtils.createCustomMarkerIcon();
    _createMarkers();
  }

  void _createMarkers() {
    _markers.clear();
    for (final property in widget.properties) {
      _markers.add(
        Marker(
          markerId: MarkerId(property.id),
          position: LatLng(property.latitude, property.longitude),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: property.title,
            snippet: property.location,
          ),
        ),
      );
    }
  }

  @override
  void didUpdateWidget(PropertyMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.properties != widget.properties && _isMapReady) {
      _createMarkers();
      setState(() {});
    }

    final newTarget = widget.cameraTarget;
    if (newTarget != null &&
        oldWidget.cameraTarget != newTarget &&
        _isMapReady &&
        _mapController != null &&
        widget.animateToTarget) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(newTarget));
    }
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.basePaleGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.baseLightGrey, width: 2),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 48, color: AppColors.baseGrey),
            const SizedBox(height: 8),
            Text(
              'Map unavailable',
              style: TextStyle(
                color: AppColors.baseDarkGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map Container
        Container(
          height: widget.height,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0xFFF5F8FF),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Builder(
            builder: (context) {
              // Only create GoogleMap widget when absolutely ready to prevent crashes
              if (_mapError || !_mapsEnabled) {
                return _buildMapPlaceholder();
              }
              if (!_isMapReady) {
                return Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: AppColors.basePaleGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
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
              return Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: widget.initialLocation ?? _center,
                      zoom: 12,
                    ),
                    markers: _markers,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    onCameraMove: (position) {
                      _lastTrackedPosition = position.target;
                      widget.onCameraMove?.call(position);
                    },
                    onCameraIdle: () {
                      if (widget.onCameraIdle != null &&
                          _lastTrackedPosition != null) {
                        widget.onCameraIdle!(_lastTrackedPosition!);
                      }
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    mapToolbarEnabled: false,
                  ),
                  if (widget.showCenterMarker)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 35),
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.supportRedDeep,
                          size: 40,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        // Maximize Button Overlay
        if (widget.onMaximizeTapped != null)
          Positioned(
            top: 12,
            right: 12,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              elevation: 2,
              child: InkWell(
                onTap: widget.onMaximizeTapped,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    'assets/icons/maximize.svg',
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
