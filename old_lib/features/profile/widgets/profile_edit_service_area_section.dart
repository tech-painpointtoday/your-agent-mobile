import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web/web.dart' as web;
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/form_fields/app_text_form_field.dart';
import 'package:youragent/widgets/profile/profile_section_header.dart';

/// Service Area Information Section with Map
class ProfileEditServiceAreaSection extends StatefulWidget {
  final TextEditingController radiusController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;

  const ProfileEditServiceAreaSection({
    super.key,
    required this.radiusController,
    required this.latitudeController,
    required this.longitudeController,
  });

  @override
  State<ProfileEditServiceAreaSection> createState() =>
      _ProfileEditServiceAreaSectionState();
}

class _ProfileEditServiceAreaSectionState
    extends State<ProfileEditServiceAreaSection> {
  LatLng? _selectedLocation;
  Marker? _locationMarker;
  final Completer<GoogleMapController> _mapControllerCompleter =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeader(
          iconAsset: 'assets/icons/profile/map-pin.svg',
          title: 'ข้อมูลพื้นที่บริการ',
        ),
        const SizedBox(height: 20),
        // Subtitle and buttons row (matching property form layout)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description text per design
            Expanded(
              child: Text(
                'คลิกบนแผนที่หรือใช้ตำแหน่งปัจจุบันของคุณเพื่อกำหนดจุดศูนย์กลางพื้นที่บริการของคุณ',
                style: GoogleFonts.anuphan(
                  fontSize: 13,
                  color: AppColors.shadyLady,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Buttons on the right
            Row(
              children: [
                ElevatedButton(
                  onPressed: _useCurrentLocation,
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(0),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered) ||
                          states.contains(WidgetState.pressed)) {
                        return const Color(0xFF32A792);
                      }
                      return const Color(0xFF7DE1CF).withValues(alpha: 0.16);
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered) ||
                          states.contains(WidgetState.pressed)) {
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
                      const Text('ใช้ตำแหน่งปัจจุบัน'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _clearLocation,
                  style: ButtonStyle(
                    elevation: WidgetStateProperty.all(0),
                    backgroundColor: WidgetStateProperty.all(Colors.white),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    side: WidgetStateProperty.all(
                      const BorderSide(color: Color(0xFFE9EAEB)),
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered) ||
                          states.contains(WidgetState.pressed)) {
                        return const Color(0xFF181D27);
                      }
                      return const Color(0xFF717680);
                    }),
                  ),
                  child: const Text('ล้างตำแหน่ง'),
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
            child: _buildMap(),
          ),
        ),
        const SizedBox(height: 16),
        // Row: รัศมีที่ให้บริการ - ละติจูด - ลองจิจูด (matching property form layout)
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AppTextFormField(
                label: 'รัศมีที่ให้บริการ',
                controller: widget.radiusController,
                keyboardType: TextInputType.number,
                isRequired: true,
                suffix: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    'ก.ม.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.cardLabelPrimary,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกรัศมีที่ให้บริการ';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextFormField(
                label: 'ละติจูด',
                controller: widget.latitudeController,
                hintText: 'กรุณาเลือกตำแหน่ง',
                isReadOnly: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTextFormField(
                label: 'ลองจิจูด',
                controller: widget.longitudeController,
                hintText: 'กรุณาเลือกตำแหน่ง',
                isReadOnly: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _selectedLocation ?? const LatLng(13.7563, 100.5018), // Bangkok
        zoom: _selectedLocation != null ? 15 : 12,
      ),
      onMapCreated: (GoogleMapController controller) {
        if (!_mapControllerCompleter.isCompleted) {
          _mapControllerCompleter.complete(controller);
        }
      },
      onTap: _onMapTap,
      markers: _locationMarker != null ? {_locationMarker!} : {},
      mapType: MapType.normal,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
    );
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
      widget.latitudeController.text = location.latitude.toStringAsFixed(8);
      widget.longitudeController.text = location.longitude.toStringAsFixed(8);
      _locationMarker = Marker(
        markerId: const MarkerId('service_area_location'),
        position: location,
        draggable: true,
        onDragEnd: (newPosition) {
          _updateLocationFromCoordinates(newPosition);
        },
      );
    });
    _mapControllerCompleter.future.then((controller) {
      controller.animateCamera(CameraUpdate.newLatLng(location));
    });
  }
  
  void _updateLocationFromCoordinates(LatLng newPosition) {
    setState(() {
      _selectedLocation = newPosition;
      widget.latitudeController.text = newPosition.latitude.toStringAsFixed(8);
      widget.longitudeController.text = newPosition.longitude.toStringAsFixed(8);
      _locationMarker = Marker(
        markerId: const MarkerId('service_area_location'),
        position: newPosition,
        draggable: true,
        onDragEnd: (position) {
          _updateLocationFromCoordinates(position);
        },
      );
    });
    _mapControllerCompleter.future.then((controller) {
      controller.animateCamera(CameraUpdate.newLatLng(newPosition));
    });
  }

  Future<void> _useCurrentLocation() async {
    if (!mounted) return;

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
              const Text('กำลังดึงตำแหน่งปัจจุบัน...'),
            ],
          ),
          duration: const Duration(seconds: 5),
        ),
      );

      LatLng? currentLocation;

      if (kIsWeb) {
        // For web, use browser geolocation API
        currentLocation = await _getCurrentLocationWeb();
      } else {
        // For mobile, use method channel
        currentLocation = await _getCurrentLocationMobile();
      }

      if (currentLocation != null && mounted) {
        // Update location using the same method as map tap
        _onMapTap(currentLocation);

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อัปเดตตำแหน่งเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ไม่สามารถดึงตำแหน่งปัจจุบันได้ กรุณาตรวจสอบการอนุญาตตำแหน่งหรือคลิกบนแผนที่เพื่อเลือกตำแหน่ง',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
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
                        'การอนุญาตตำแหน่งถูกปฏิเสธ กรุณาอนุญาตการเข้าถึงตำแหน่งหรือคลิกบนแผนที่เพื่อเลือกตำแหน่ง')
                  : 'ไม่สามารถดึงตำแหน่งปัจจุบันได้ กรุณาคลิกบนแผนที่เพื่อเลือกตำแหน่ง',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Get current location for web using browser's geolocation API
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

  void _clearLocation() {
    setState(() {
      _selectedLocation = null;
      _locationMarker = null;
      widget.latitudeController.clear();
      widget.longitudeController.clear();
    });
  }
}
