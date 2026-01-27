import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/features/property/widgets/property_map_view.dart';
import 'package:youragent/widgets/form_fields/app_text_form_field.dart';

class LocationSearchBottomSheet extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationSearchBottomSheet({super.key, this.initialLocation});

  @override
  State<LocationSearchBottomSheet> createState() =>
      _LocationSearchBottomSheetState();

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    LatLng? initialLocation,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          LocationSearchBottomSheet(initialLocation: initialLocation),
    );
  }
}

class _LocationSearchBottomSheetState extends State<LocationSearchBottomSheet> {
  late LatLng _currentLocation;
  Placemark? _selectedPlacemark;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _currentLocation =
        widget.initialLocation ?? const LatLng(13.7563, 100.5018);
    if (widget.initialLocation != null) {
      _fetchPlacemark(_currentLocation);
    }
  }

  Future<void> _fetchPlacemark(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        setState(() {
          _selectedPlacemark = placemarks.first;
          if (!_isSearching) {
            _searchController.text = _formatPlacemark(placemarks.first);
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching placemark: $e');
    }
  }

  String _formatPlacemark(Placemark p) {
    return [
      p.street,
      p.subLocality,
      p.locality,
      p.administrativeArea,
    ].where((e) => e != null && e.isNotEmpty).join(' ');
  }

  void _onLocationChanged(LatLng location) {
    setState(() {
      _currentLocation = location;
    });
    _fetchPlacemark(location);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.baseLightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'ตำแหน่งที่ตั้ง',
                style: GoogleFonts.anuphan(
                  color: AppColors.baseBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: GoogleFonts.anuphan(
                  color: AppColors.supportRedDeep,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextFormField(
            label: '', // Label handled above
            controller: _searchController,
            hintText: 'ค้นหาตำแหน่งที่ตั้ง',
            suffix: const Icon(Icons.search, color: AppColors.baseGrey),
            onChanged: (val) {
              setState(() {
                _isSearching = val.isNotEmpty;
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            'เลือกตำแหน่งบนแผนที่หรือใช้ตำแหน่งปัจจุบันของคุณเพื่อกำหนดที่ตั้งอสังหาริมทรัพย์',
            style: GoogleFonts.anuphan(color: AppColors.baseGrey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PropertyMapView(
                properties: const [], // No properties needed for picker
                height: double.infinity,
                initialLocation: _currentLocation,
                showCenterMarker: true,
                onCameraIdle: _onLocationChanged,
                onCameraMove: (pos) {
                  setState(() {
                    _isSearching =
                        false; // User is moving map, stop "searching" state
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            text: 'ยืนยันตำแหน่งนี้',
            style: AppButtonStyle.primary,
            onPressed: () {
              Navigator.pop(context, {
                'latLng': _currentLocation,
                'placemark': _selectedPlacemark,
              });
            },
          ),
        ],
      ),
    );
  }
}
