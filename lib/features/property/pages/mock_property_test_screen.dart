import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/mock/mock_property_data.dart';
import 'package:youragent/features/property/pages/property_detail_screen.dart';
import 'package:youragent/widgets/buttons/app_button.dart';

class MockPropertyTestScreen extends StatelessWidget {
  const MockPropertyTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final properties = MockPropertyData.mockProperties;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Mock Property Test',
          style: GoogleFonts.anuphan(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.baseBlack,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.baseLightGrey),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ID: ${property.id}',
                          style: GoogleFonts.anuphan(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Code: ${property.code}',
                        style: GoogleFonts.anuphan(
                          color: AppColors.baseGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    property.title,
                    style: GoogleFonts.anuphan(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.baseBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.address ?? 'No address',
                    style: GoogleFonts.anuphan(
                      color: AppColors.baseDarkGrey,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'View Detail Preview',
                    style: AppButtonStyle.primary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PropertyDetailScreen(property: property),
                        ),
                      );
                    },
                    height: 48,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
