import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../widgets/buttons/app_button.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _selectedLocation;
  Placemark? _selectedPlacemark;
  bool _isLoadingPlacemark = false;

  static const LatLng _center = LatLng(13.7563, 100.5018);

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? _center;
    if (widget.initialLocation != null) {
      _fetchPlacemark(_selectedLocation);
    }
  }

  Future<void> _fetchPlacemark(LatLng position) async {
    setState(() => _isLoadingPlacemark = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        setState(() => _selectedPlacemark = placemarks.first);
      }
    } catch (e) {
      debugPrint('Error fetching placemark: $e');
    } finally {
      setState(() => _isLoadingPlacemark = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'เลือกตําแหน่ง',
          style: GoogleFonts.anuphan(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.baseBlack,
        elevation: 0,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            onMapCreated: (controller) {},
            onCameraMove: (position) {
              setState(() => _selectedLocation = position.target);
            },
            onCameraIdle: () {
              _fetchPlacemark(_selectedLocation);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (widget.initialLocation != null)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 35),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoadingPlacemark)
                    const LinearProgressIndicator()
                  else if (_selectedPlacemark != null)
                    Text(
                      [
                        _selectedPlacemark!.street,
                        _selectedPlacemark!.subLocality,
                        _selectedPlacemark!.locality,
                        _selectedPlacemark!.administrativeArea,
                      ].where((e) => e != null && e.isNotEmpty).join(' '),
                      style: GoogleFonts.anuphan(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      '(${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)})',
                      style: GoogleFonts.anuphan(fontSize: 14),
                    ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'ยืนยันตําแหน่งนี้',
                    style: AppButtonStyle.primary,
                    onPressed: () {
                      Navigator.pop(context, {
                        'latLng': _selectedLocation,
                        'placemark': _selectedPlacemark,
                      });
                    },
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
