import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/data/mock/mock_data_service.dart';
import 'package:youragent/widgets/custom_header.dart';
// import 'package:youragent/widgets/footer.dart';
import 'package:youragent/domain/entities/floor_plan.dart';

/// Property Floor Plans Screen - shows floor plans for a property
class PropertyFloorPlansScreen extends StatelessWidget {
  final Function(Locale) changeLocale;
  final int propertyId;

  const PropertyFloorPlansScreen({
    super.key,
    required this.changeLocale,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context) {
    final mockData = MockDataService();
    final floorPlans = mockData.getMockFloorPlans(propertyId: propertyId);

    return Scaffold(
      backgroundColor: AppColors.wildSand,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(changeLocale: changeLocale),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Floor Plans',
                          style: GoogleFonts.anuphan(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.baseDarkGrey,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Add floor plan
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Floor Plan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.jungleGreen,
                            foregroundColor: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ...floorPlans.map(
                      (floorPlan) => _buildFloorPlanCard(context, floorPlan),
                    ),
                  ],
                ),
              ),
            ),
            // const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorPlanCard(BuildContext context, FloorPlan floorPlan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bonJour, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Floor ${floorPlan.story ?? 'N/A'}',
                style: GoogleFonts.anuphan(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Edit floor plan
                    },
                    icon: const Icon(Icons.edit, color: AppColors.shadyLady),
                  ),
                  IconButton(
                    onPressed: () {
                      // Delete floor plan
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: AppColors.alizarinCrimson,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            floorPlan.filename,
            style: GoogleFonts.anuphan(
              fontSize: 14,
              color: AppColors.shadyLady,
            ),
          ),
          const SizedBox(height: 8),
          if (floorPlan.displayUrl != null)
            ElevatedButton(
              onPressed: () {
                // View floor plan
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.jungleGreen,
                foregroundColor: AppColors.white,
              ),
              child: const Text('View Floor Plan'),
            ),
        ],
      ),
    );
  }
}
