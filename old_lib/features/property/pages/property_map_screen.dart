import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/custom_header.dart';
// import 'package:youragent/widgets/footer.dart';
import 'package:youragent/data/mock/mock_data_service.dart';

/// Property Map Screen - shows properties on map
class PropertyMapScreen extends StatelessWidget {
  final Function(Locale) changeLocale;

  const PropertyMapScreen({super.key, required this.changeLocale});

  @override
  Widget build(BuildContext context) {
    final mockData = MockDataService();
    final properties = mockData.getMockProperties();

    return Scaffold(
      backgroundColor: AppColors.wildSand,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(changeLocale: changeLocale),
            Expanded(
              child: Column(
                children: [
                  // Map placeholder
                  Expanded(
                    child: Container(
                      color: AppColors.bonJour.withValues(alpha: 0.1),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map,
                              size: 64,
                              color: AppColors.shadyLady,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Map View',
                              style: GoogleFonts.anuphan(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.shadyLady,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${properties.length} properties',
                              style: GoogleFonts.anuphan(
                                fontSize: 14,
                                color: AppColors.shadyLady,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Property list below map
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: properties.length,
                      itemBuilder: (context, index) {
                        final property = properties[index];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.wildSand,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.bonJour,
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.name,
                                style: GoogleFonts.anuphan(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '฿${property.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                style: GoogleFonts.anuphan(
                                  fontSize: 12,
                                  color: AppColors.jungleGreen,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // const Footer(),
          ],
        ),
      ),
    );
  }
}
