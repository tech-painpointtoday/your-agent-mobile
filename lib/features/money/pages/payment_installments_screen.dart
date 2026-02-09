import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';

class PaymentInstallmentsScreen extends StatelessWidget {
  const PaymentInstallmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
          'งวดการชำระเงิน',
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
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPropertyHeader(),
              const SizedBox(height: 24),
              _buildInstallmentProgress(),
              const SizedBox(height: 24),
              _buildInstallmentList(),
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

  Widget _buildInstallmentList() {
    final List<Map<String, dynamic>> installments = [
      {
        'number': '6/12',
        'price': '10,000',
        'status': 'ชำระเมื่อ : 1 ม.ค. 2569',
        'paid': true,
        'delayed': false,
      },
      {
        'number': '5/12',
        'price': '10,200',
        'status': 'ชำระเมื่อ : 6 ธ.ค. 2568 (ล่าช้า)',
        'paid': true,
        'delayed': true,
      },
      {
        'number': '4/12',
        'price': '10,000',
        'status': 'ชำระเมื่อ : 1 พ.ย. 2568',
        'paid': true,
        'delayed': false,
      },
      {
        'number': '3/12',
        'price': '10,000',
        'status': 'ชำระเมื่อ : 1 ต.ค. 2568',
        'paid': true,
        'delayed': false,
      },
      {
        'number': '2/12',
        'price': '10,000',
        'status': 'ชำระเมื่อ : 1 ก.ย. 2568',
        'paid': true,
        'delayed': false,
      },
      {
        'number': '1/12',
        'price': '10,000',
        'status': 'ชำระเมื่อ : 1 ส.ค. 2568',
        'paid': true,
        'delayed': false,
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: installments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = installments[index];
        return _buildInstallmentCard(item);
      },
    );
  }

  Widget _buildInstallmentCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFF2F4F7)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'งวดชำระที่ ${item['number']}',
                style: GoogleFonts.anuphan(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF181D27),
                ),
              ),
              Text(
                '฿${item['price']}',
                style: GoogleFonts.anuphan(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF04437),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/check-circle-filled.svg',
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(
                  item['delayed']
                      ? AppColors.supportGreenDark
                      : AppColors.supportOrangeDark,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item['status'],
                style: GoogleFonts.anuphan(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF717680),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
