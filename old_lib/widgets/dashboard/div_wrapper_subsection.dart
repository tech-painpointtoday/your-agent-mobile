import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/dashboard/pie_chart_widget.dart';

class DivWrapperSubsection extends StatelessWidget {
  final int? totalBuyersRenters;
  final int? totalBuyers;
  final int? totalRenters;
  final bool isMobile;

  const DivWrapperSubsection({
    super.key,
    this.totalBuyersRenters,
    this.totalBuyers,
    this.totalRenters,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    // Mock data based on image
    final buyersRentersCount = totalBuyersRenters ?? 100;
    final buyersCount = totalBuyers ?? 31;
    final rentersCount = totalRenters ?? 69;

    // Mock breakdown data (percentages from image)
    final buyersRentersData = {
      'อื่น ๆ': 35,
      'บ้าน': 30,
      'คอนโด': 21,
      'บ้านแฝด': 14,
    };
    final buyersData = {'อื่น ๆ': 35, 'บ้าน': 30, 'คอนโด': 21, 'บ้านแฝด': 14};
    final rentersData = {'อื่น ๆ': 35, 'บ้าน': 30, 'คอนโด': 21, 'บ้านแฝด': 14};

    // Color schemes for each chart (from CSS)
    final greenColors = [
      AppColors.pieGreen1,
      AppColors.pieGreen2,
      AppColors.pieGreen3,
      AppColors.pieGreen4,
    ];
    final blueColors = [
      AppColors.pieBlue1,
      AppColors.pieBlue2,
      AppColors.pieBlue3,
      AppColors.pieBlue4,
    ];
    final orangeColors = [
      AppColors.pieOrange1,
      AppColors.pieOrange2,
      AppColors.pieOrange3,
      AppColors.pieOrange4,
    ];

    final cards = [
      _CardData(
        title: 'ผู้ซื้อ/ผู้เช่าทั้งหมด',
        count: buyersRentersCount,
        data: buyersRentersData,
        colors: greenColors,
      ),
      _CardData(
        title: 'ผู้ซื้อทั้งหมด',
        count: buyersCount,
        data: buyersData,
        colors: blueColors,
      ),
      _CardData(
        title: 'ผู้เช่าทั้งหมด',
        count: rentersCount,
        data: rentersData,
        colors: orangeColors,
      ),
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cards.asMap().entries.map((entry) {
          final index = entry.key;
          final card = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index < 2 ? 16 : 0),
            child: _buildCard(card, isMobile),
          );
        }).toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          cards
              .map((card) => Expanded(child: _buildCard(card, isMobile)))
              .expand((widget) => [widget, const SizedBox(width: 16)])
              .toList()
            ..removeLast(),
    );
  }

  Widget _buildCard(_CardData card, bool isMobile) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xFFE9E9EB)),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.all(isMobile ? 24 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.title,
            style: GoogleFonts.anuphan(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF717680),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${card.count}',
                style: GoogleFonts.anuphan(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.baseDarkGrey,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'คน',
                style: GoogleFonts.anuphan(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.baseDarkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Pie chart
          Center(
            child: PieChartWidget(
              data: card.data,
              colors: card.colors,
              size: isMobile ? 100 : 120,
              strokeWidth: isMobile ? 16 : 20,
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ประเภทอสังหาฯ',
                style: GoogleFonts.anuphan(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF717680),
                ),
              ),
              const SizedBox(height: 8),
              ...card.data.entries.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final dataEntry = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: card.colors[index % card.colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${dataEntry.key}: ${dataEntry.value}',
                        style: GoogleFonts.anuphan(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.baseDarkGrey,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardData {
  final String title;
  final int count;
  final Map<String, int> data;
  final List<Color> colors;

  _CardData({
    required this.title,
    required this.count,
    required this.data,
    required this.colors,
  });
}
