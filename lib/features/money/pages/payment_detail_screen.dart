import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/money/pages/payment_installments_screen.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/modals/app_call_bottom_sheet.dart';

class PaymentDetailScreen extends StatelessWidget {
  const PaymentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/chevron-left.svg',
            width: 18,
            height: 18,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              AppColors.baseDarkGrey,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'รายละเอียดการชำระเงิน',
          style: GoogleFonts.anuphan(
            color: const Color(0xFF181D27),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPropertyHeader(),
              const SizedBox(height: 24),
              _buildContactCards(context),
              const SizedBox(height: 24),
              _buildInstallmentProgress(),
              const SizedBox(height: 16),
              AppButton(
                text: 'ดูรายละเอียด',
                style: AppButtonStyle.outline,
                width: double.infinity,
                height: 32,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentInstallmentsScreen(),
                    ),
                  );
                },
                textStyle: GoogleFonts.anuphan(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF717680),
                ),
              ),
              const SizedBox(height: 24),
              _buildPaymentDetailSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'อสังหาริมทรัพย์ที่ 1 บ้านเช่าถูก ปุณณวิถี ใกล้บีทีเอส เดินทางสะดวก ',
          style: GoogleFonts.anuphan(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF181D27),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sansiri Developer • ซื่อตรง แกรนด์ โฮม เกษตร - ปุณณวิถี 33 สุขุมวิท 101',
          style: GoogleFonts.anuphan(
            fontSize: 14,
            color: const Color(0xFF181D27),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildContactCard(
            context,
            role: 'เจ้าของทรัพย์',
            name: 'สมชาย ใจดี',
            phone: '0898765432',
            alignCenter: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildContactCard(
            context,
            role: 'ผู้เช่า',
            name: 'สมหญิง สงวนงาม',
            phone: '0812345678',
            alignCenter: true,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required String role,
    required String name,
    required String phone,
    bool alignCenter = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: const Color(0xFFFAFAFA),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE9EAEB)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: alignCenter
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: GoogleFonts.anuphan(
              fontSize: 12,
              color: const Color(0xFF717680),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: GoogleFonts.anuphan(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF181D27),
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'โทรออก',
            style: AppButtonStyle.outline,
            height: 32,
            width: double.infinity,
            iconPath: 'assets/icons/phone.svg',
            iconSize: 12,
            textColor: AppColors.baseDarkGrey,
            textStyle: GoogleFonts.anuphan(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            onPressed: () {
              AppCallBottomSheet.show(
                context: context,
                options: [CallOption(label: role, phone: phone)],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'งวดชำระที่ 7/12',
              style: GoogleFonts.anuphan(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF181D27),
              ),
            ),
            Text(
              'ชำระทุกวันที่ 5 ของเดือน',
              style: GoogleFonts.anuphan(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF717680),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 4.0,
            runSpacing: 4.0,
            children: List.generate(12, (index) {
              String iconPath;
              if (index < 4) {
                iconPath = 'assets/icons/money/status_on_time.svg';
              } else if (index == 4) {
                iconPath = 'assets/icons/money/status_delayed.svg';
              } else if (index == 5) {
                iconPath = 'assets/icons/money/status_on_time.svg';
              } else if (index == 6) {
                iconPath = 'assets/icons/money/status_now.svg';
              } else {
                iconPath = 'assets/icons/money/status_not_yet.svg';
              }

              return SvgPicture.asset(iconPath, width: 24, height: 24);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'รายละเอียดการชำระเงิน',
              style: GoogleFonts.anuphan(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF181D27),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: ShapeDecoration(
                color: AppColors.basePaleGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'กำหนดชำระ : 5 ม.ค. 69',
                style: GoogleFonts.anuphan(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF717680),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: Color(0xFFE9EAEB), thickness: 1),
        const SizedBox(height: 16),
        _buildPaymentRow('ราคาเช่า', '฿8,000'),
        const SizedBox(height: 12),
        _buildPaymentRow('ค่าส่วนกลาง', '฿2,000'),
        const SizedBox(height: 12),
        _buildPaymentRow('ค่าบริการอื่น ๆ', '-'),
        const SizedBox(height: 12),
        _buildPaymentRow('ค่าปรับ', '-'),
        const SizedBox(height: 12),
        _buildPaymentRow('รวมทั้งสิ้น', '฿10,000', isTotal: true),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.anuphan(
            fontSize: 16,
            color: const Color(0xFF717680),
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.anuphan(
            fontSize: 16,
            color: isTotal ? const Color(0xFFF04437) : const Color(0xFF181D27),
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
