import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/widgets/buttons/app_button.dart';
import 'package:yourhome/widgets/map/map_view.dart';
import 'package:yourhome/widgets/form_fields/app_text_form_field.dart';
import 'package:yourhome/l10n/app_localizations.dart';

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
  LatLng? _currentLocation;
  Placemark? _selectedPlacemark;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation;
    if (widget.initialLocation != null) {
      _fetchPlacemark(widget.initialLocation!);
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
                AppLocalizations.of(context).locationTitle,
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
            hintText: AppLocalizations.of(context).searchLocationHint,
            suffix: const Icon(Icons.search, color: AppColors.baseGrey),
            onChanged: (val) {
              setState(() {
                _isSearching = val.isNotEmpty;
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).locationDescription,
            style: GoogleFonts.anuphan(color: AppColors.baseGrey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MapView(
                properties: const [], // No properties needed for picker
                height: double.infinity,
                initialLocation: _currentLocation,
                showCenterMarker: _currentLocation != null,
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
            text: AppLocalizations.of(context).confirmLocationButton,
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
