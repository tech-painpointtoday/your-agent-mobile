import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';

import '../../../widgets/app_bars/silver_app_bar.dart';
import '../widgets/money_action_button.dart';
import '../widgets/money_property_card.dart';

class MoneyScreen extends StatelessWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SilverAppBarScreen(
      preferredHeight: 200,
      backgroundHeight: 248,
      hasFilter: true,
      titleWidget: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            const Text(
              'การเงิน',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Anuphan',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            _buildCommissionSection(),
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 96, 16, 32),
            child: _buildDueTodaySection(context),
          ),
          Positioned(
            top: -36,
            left: 16,
            right: 16,
            child: _buildQuickActionCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'คอมมิชชันเดือนนี้',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Anuphan',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '฿ 108,240',
              style: GoogleFonts.anuphan(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '.56',
              style: GoogleFonts.anuphan(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFF5F8FF),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MoneyActionButton(
            label: 'รอบชำระวันนี้',
            iconPath:
                'assets/icons/calendar.svg', // Placeholder icons, need to check actual available
            onTap: () {},
          ),
          MoneyActionButton(
            label: 'รอบชำระถัดไป',
            iconPath: 'assets/icons/clock.svg',
            onTap: () {},
          ),
          MoneyActionButton(
            label: 'ประวัติการชำระ',
            iconPath: 'assets/icons/clipboard-2.svg',
            onTap: () {},
          ),
          MoneyActionButton(
            label: 'ค้างชำระ',
            iconPath: 'assets/icons/alert-triangle.svg',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDueTodaySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'รายการรอบชำระวันนี้',
                  style: TextStyle(
                    color: Color(0xFF1743C7),
                    fontSize: 16,
                    fontFamily: 'Anuphan',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'การเช่าที่ครบกำหนดชำระวันนี้ 10 รายการ',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontFamily: 'Anuphan',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'ดูทั้งหมด',
                style: TextStyle(
                  color: Color(0xFFA4A7AE),
                  fontSize: 12,
                  fontFamily: 'Anuphan',
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.baseGrey,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final mockData = [
              {
                'title': 'อสังหาริมทรัพย์ที่ 1',
                'location': 'ปุณณวิถี, กรุงเทพมหานคร',
                'price': '10,000',
                'date': '5 ม.ค. 69',
                'image':
                    'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400',
              },
              {
                'title': 'อสังหาริมทรัพย์ที่ 2',
                'location': 'อุดมสุข, กรุงเทพมหานคร',
                'price': '5,000',
                'date': '5 ม.ค. 69',
                'image':
                    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=400',
              },
              {
                'title': 'อสังหาริมทรัพย์ที่ 3',
                'location': 'สุขุมวิท, กรุงเทพมหานคร',
                'price': '7,500',
                'date': '5 ม.ค. 69',
                'image':
                    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400',
              },
            ];
            final item = mockData[index];
            return MoneyPropertyCard(
              title: item['title']!,
              location: item['location']!,
              price: item['price']!,
              dueDate: item['date']!,
              imageUrl: item['image'],
              onCall: () {},
            );
          },
        ),
      ],
    );
  }
}
