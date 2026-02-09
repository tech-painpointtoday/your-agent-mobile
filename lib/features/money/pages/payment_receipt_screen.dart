import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import '../../../../widgets/buttons/app_button.dart';

class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
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
                onPressed: () => Navigator.pop(context),
              ),
              titleSpacing: 0,
              title: Text(
                'ประวัติการชำระ',
                style: GoogleFonts.anuphan(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.baseBlack,
                ),
              ),
              centerTitle: false,
            ),
          ];
        },
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color(0xFFF5F8FF), Colors.white],
            ),
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildReceiptHeader(),
                        const SizedBox(height: 24),
                        const _DottedDivider(),
                        const SizedBox(height: 24),
                        _buildPaymentInfo(),
                        const SizedBox(height: 24),
                        _buildPartiesInfo(),
                        const SizedBox(height: 32),
                        Text(
                          'รายละเอียดการชำระเงิน',
                          style: GoogleFonts.anuphan(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.baseBlack,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _DottedDivider(),
                        const SizedBox(height: 24),
                        _buildPaymentDetails(),
                        const SizedBox(height: 64),
                        Center(child: _buildSaveButton(context)),
                      ],
                    ),
                  ),
                ),
                PhysicalShape(
                  clipper: _ZigZagClipper(),
                  elevation: 1,
                  shadowColor: Color(0x00002aff).withValues(alpha: 0.08),
                  color: Colors.white,
                  child: const SizedBox(height: 32, width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return AppButton(
      text: 'บันทึกใบเสร็จ',
      style: AppButtonStyle.outline,
      iconPath: 'assets/icons/download.svg',
      iconSize: 16,
      textColor: AppColors.baseDarkGrey,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 48),
      borderColor: AppColors.baseLightGrey,
      textStyle: GoogleFonts.anuphan(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.baseDarkGrey,
      ),
      onPressed: () {},
    );
  }

  Widget _buildReceiptHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ใบเสร็จรับเงิน',
          style: GoogleFonts.anuphan(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.baseBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'เลขที่ใบเสร็จ : 1000023456',
          style: GoogleFonts.anuphan(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF717680),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildInfoItem('วันที่ชำระเงิน', '1 ม.ค. 2569')),
        Expanded(
          child: _buildInfoItem(
            'ช่องทางการชำระเงิน',
            'ธนาคารไทยพาณิชย์',
            subValue: 'xxx-xxx123-4',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, {String? subValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.anuphan(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.baseDarkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.anuphan(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.baseBlack,
          ),
        ),
        if (subValue != null) ...[
          const SizedBox(height: 4),
          Text(
            subValue,
            style: GoogleFonts.anuphan(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: AppColors.baseDarkGrey,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPartiesInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildPartyItem(
            'เจ้าของทรัพย์',
            'สมชาย ใจดี',
            'somchai@example.com',
            '091-123-457',
          ),
        ),
        Expanded(
          child: _buildPartyItem(
            'ผู้เช่า',
            'สมหญิง สงวนงาม',
            'somying@example.com',
            '091-123-457',
          ),
        ),
      ],
    );
  }

  Widget _buildPartyItem(String role, String name, String email, String phone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          role,
          style: GoogleFonts.anuphan(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.baseDarkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: GoogleFonts.anuphan(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.baseBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: GoogleFonts.anuphan(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.baseDarkGrey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          phone,
          style: GoogleFonts.anuphan(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.baseDarkGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      children: [
        _buildDetailRow('ราคาเช่า', '฿8,000'),
        const SizedBox(height: 12),
        _buildDetailRow('ค่าส่วนกลาง', '฿2,000'),
        const SizedBox(height: 12),
        _buildDetailRow('ค่าบริการอื่น ๆ', '-'),
        const SizedBox(height: 12),
        _buildDetailRow('ค่าปรับ', '-'),
        const SizedBox(height: 24),
        _buildDetailRow('รวมทั้งสิ้น', '฿10,000', isTotal: true),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.anuphan(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.w400 : FontWeight.w400,
            color: AppColors.baseDarkGrey,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.anuphan(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: AppColors.baseBlack,
          ),
        ),
      ],
    );
  }
}

class _DottedDivider extends StatelessWidget {
  const _DottedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.baseLightGrey),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double amplitude = 12;
    double wavelength = 24;
    double x = 0;

    path.lineTo(0, size.height - amplitude);

    while (x < size.width) {
      x += wavelength / 2;
      path.lineTo(x, size.height);
      x += wavelength / 2;
      path.lineTo(x, size.height - amplitude);
    }

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
