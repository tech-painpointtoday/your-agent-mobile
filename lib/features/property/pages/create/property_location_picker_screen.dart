import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../widgets/buttons/app_button.dart';
import '../../../../widgets/dialogs/status_dialog.dart';
import '../../../../widgets/modals/app_confirmation_bottom_sheet.dart';
import '../../widgets/property_map_selection.dart';

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
  PropertyLocationResult? _currentResult;

  void _onLocationChanged(PropertyLocationResult result) {
    setState(() {
      _currentResult = result;
    });
  }

  Future<void> _onSave() async {
    if (_currentResult == null ||
        _currentResult!.formattedAddressTh.trim().isEmpty) {
      StatusDialog.showWarning(
        context: context,
        title: 'เลือกตำแหน่ง',
        message: 'กรุณาเลือกตำแหน่งบนแผนที่หรือค้นหาสถานที่',
      );
      return;
    }

    // Convert internal result to public picker result
    final pickerResult = PropertyLocationPickerResult(
      latLng: _currentResult!.latLng,
      formattedAddressTh: _currentResult!.formattedAddressTh,
      formattedAddressEn: _currentResult!.formattedAddressEn,
      components: _currentResult!.components,
    );

    await AppConfirmationBottomSheet.show(
      context: context,
      title: 'บันทึกตำแหน่งนี้?',
      description: 'ยืนยันการเลือกตำแหน่งนี้สำหรับประกาศทรัพย์',
      confirmLabel: 'บันทึก',
      cancelLabel: 'ยกเลิก',
      style: ConfirmationStyle.normal,
      onConfirm: () {
        if (mounted) Navigator.of(context).pop(pickerResult);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.baseWhite,
      body: Stack(
        children: [
          // Map Selection Widget
          Positioned.fill(
            child: PropertyMapSelection(
              initialLocation: widget.initialLocation,
              onLocationChanged: _onLocationChanged,
              onBackTapped: () => Navigator.of(context).pop(),
              showControls: true,
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
                16,
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
                    _currentResult?.formattedAddressTh.isNotEmpty == true
                        ? _currentResult!.formattedAddressTh
                        : 'กำลังค้นหาที่อยู่…',
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseDarkGrey,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currentResult != null
                        ? '(พิกัด: ${_currentResult!.latLng.latitude.toStringAsFixed(7)}, ${_currentResult!.latLng.longitude.toStringAsFixed(7)})'
                        : '...',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
