import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:youragent/features/property/bloc/create_property/create_property_bloc.dart';

class PropertyConfirmationStep extends StatelessWidget {
  const PropertyConfirmationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreatePropertyBloc, CreatePropertyState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ตรวจสอบข้อมูล',
                style: GoogleFonts.anuphan(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('ประเภททรัพย์', state.selectedPropertyType ?? '-'),
              _buildInfoRow('ชื่ออสังหาฯ', state.name ?? '-'),
              _buildInfoRow('ราคา', '${state.price ?? 0} บาท'),
              _buildInfoRow('ที่อยู่', state.address ?? '-'),
              _buildInfoRow('ห้องนอน', state.bedrooms?.toString() ?? '-'),
              _buildInfoRow('ห้องน้ำ', state.bathrooms?.toString() ?? '-'),
              const SizedBox(height: 24),
              Text(
                'รูปภาพ (${state.images.length})',
                style: GoogleFonts.anuphan(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.anuphan(color: AppColors.baseGrey)),
          Text(value, style: GoogleFonts.anuphan(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
