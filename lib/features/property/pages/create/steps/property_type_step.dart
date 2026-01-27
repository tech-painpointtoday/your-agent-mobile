import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/property/bloc/create_property/create_property_bloc.dart';

class PropertyTypeStep extends StatelessWidget {
  const PropertyTypeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'ประเภททรัพย์',
                  style: GoogleFonts.anuphan(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '1/5',
                style: GoogleFonts.anuphan(
                  color: AppColors.baseGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const _PropertyTypeGrid(),
        ],
      ),
    );
  }
}

class _PropertyTypeGrid extends StatelessWidget {
  const _PropertyTypeGrid();

  static const List<Map<String, String>> _propertyTypes = [
    {'name': 'บ้าน', 'image': 'assets/images/property_types/house.jpg'},
    {'name': 'คอนโดมิเนียม', 'image': 'assets/images/property_types/condo.jpg'},
    {
      'name': 'ทาวน์เฮาส์/ทาวน์โฮม',
      'image': 'assets/images/property_types/townhome.jpg',
    },
    {
      'name': 'อพาร์ตเมนต์',
      'image': 'assets/images/property_types/apartment.jpg',
    },
    {
      'name': 'โฮมออฟฟิศ',
      'image': 'assets/images/property_types/home_office.jpg',
    },
    {
      'name': 'พูลวิลล่า',
      'image': 'assets/images/property_types/pool_villa.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreatePropertyBloc, CreatePropertyState>(
      buildWhen: (previous, current) =>
          previous.selectedPropertyType != current.selectedPropertyType,
      builder: (context, state) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _propertyTypes.length,
          itemBuilder: (context, index) {
            final type = _propertyTypes[index];
            final isSelected = state.selectedPropertyType == type['name'];

            return _PropertyTypeCard(
              name: type['name']!,
              imagePath: type['image']!,
              isSelected: isSelected,
              onTap: () {
                context.read<CreatePropertyBloc>().add(
                  CreatePropertyTypeSelected(type['name']!),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PropertyTypeCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _PropertyTypeCard({
    required this.name,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.baseLightGrey,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            else
              const BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                child: Image.network(
                  "https://placehold.co/300x200", // Using placeholder for now
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.anuphan(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.baseDarkGrey,
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
