import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/auth/widgets/auth_header.dart';
// import 'package:youragent/widgets/footer.dart';

enum PolicyType { terms, privacy, disclaimer }

class PolicyScreen extends StatefulWidget {
  final Function(Locale) changeLocale;
  final PolicyType? initialPolicyType;

  const PolicyScreen({
    super.key,
    required this.changeLocale,
    this.initialPolicyType,
  });

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  late PolicyType _selectedPolicy;

  @override
  void initState() {
    super.initState();
    _selectedPolicy = widget.initialPolicyType ?? PolicyType.terms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: AuthHeader(changeLocale: widget.changeLocale),
            ),

            // Main Content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 800;
                  if (isMobile) {
                    return _buildMobileLayout();
                  }
                  return _buildDesktopLayout();
                },
              ),
            ),

            // Footer
            // const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar
          SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Title
                Text(
                  'ศูนย์ช่วยเหลือ',
                  style: GoogleFonts.anuphan(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF181D27),
                  ),
                ),
                const SizedBox(height: 40),
                // Navigation Items
                _buildNavItem('ข้อกำหนดและเงื่อนไขการใช้งาน', PolicyType.terms),
                _buildNavItem('นโยบายความเป็นส่วนตัว', PolicyType.privacy),
                _buildNavItem('ข้อสงวนสิทธิ์', PolicyType.disclaimer),
              ],
            ),
          ),
          const SizedBox(width: 40),
          // Right Content Card
          Expanded(child: _buildContentCard()),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Title
          Text(
            'ศูนย์ช่วยเหลือ',
            style: GoogleFonts.anuphan(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF181D27),
            ),
          ),
          const SizedBox(height: 24),
          // Navigation Items
          _buildNavItem('ข้อกำหนดและเงื่อนไขการใช้งาน', PolicyType.terms),
          _buildNavItem('นโยบายความเป็นส่วนตัว', PolicyType.privacy),
          _buildNavItem('ข้อสงวนสิทธิ์', PolicyType.disclaimer),
          const SizedBox(height: 24),
          // Content Card
          _buildContentCard(),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, PolicyType type) {
    final isSelected = _selectedPolicy == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPolicy = type;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          border: isSelected
              ? const Border(
                  left: BorderSide(color: Color(0xFFE9E9EB), width: 8),
                )
              : null,
        ),
        child: Text(
          title,
          style: GoogleFonts.anuphan(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: const Color(0xFF181D27),
          ),
        ),
      ),
    );
  }

  Widget _buildContentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title
            Text(
              _getPolicyTitle(),
              style: GoogleFonts.anuphan(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF181D27),
              ),
            ),
            const SizedBox(height: 16),
            // Company Name
            Text(
              'บริษัท ยัวร์เอเจนต์ แพลตฟอร์ม จำกัด',
              style: GoogleFonts.anuphan(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.alizarinCrimson,
              ),
            ),
            const SizedBox(height: 32),
            // Policy Content
            ..._getPolicyContent(),
          ],
        ),
      ),
    );
  }

  String _getPolicyTitle() {
    switch (_selectedPolicy) {
      case PolicyType.terms:
        return 'ข้อกำหนดและเงื่อนไขการใช้งาน';
      case PolicyType.privacy:
        return 'นโยบายความเป็นส่วนตัว';
      case PolicyType.disclaimer:
        return 'ข้อสงวนสิทธิ์';
    }
  }

  List<Widget> _getPolicyContent() {
    switch (_selectedPolicy) {
      case PolicyType.terms:
        return _buildTermsContent();
      case PolicyType.privacy:
        return _buildPrivacyContent();
      case PolicyType.disclaimer:
        return _buildDisclaimerContent();
    }
  }

  List<Widget> _buildTermsContent() {
    return [
      _buildPolicyPoint(
        1,
        'ผู้ใช้บริการตกลงที่จะใช้บริการของบริษัท ยัวร์เอเจนต์ แพลตฟอร์ม จำกัด ตามข้อกำหนดและเงื่อนไขที่กำหนดไว้ในเอกสารฉบับนี้ โดยการเข้าใช้งานหรือใช้บริการใดๆ ของแพลตฟอร์ม ถือว่าผู้ใช้บริการยอมรับและผูกพันตามข้อกำหนดและเงื่อนไขทั้งหมด',
      ),
      const SizedBox(height: 24),
      _buildPolicyPoint(
        2,
        'บริษัทขอสงวนสิทธิ์ในการแก้ไข เปลี่ยนแปลง หรือยกเลิกข้อกำหนดและเงื่อนไขการใช้งานได้ตลอดเวลา โดยจะแจ้งให้ผู้ใช้บริการทราบผ่านทางเว็บไซต์หรือช่องทางอื่นๆ ที่เหมาะสม การแก้ไขใดๆ จะมีผลบังคับใช้ทันทีหลังจากประกาศ',
      ),
      const SizedBox(height: 24),
      _buildPolicyPoint(
        3,
        'ผู้ใช้บริการต้องรับผิดชอบต่อข้อมูลที่ให้ไว้ในแพลตฟอร์ม และต้องให้ข้อมูลที่ถูกต้อง ครบถ้วน และเป็นปัจจุบัน บริษัทไม่รับผิดชอบต่อความเสียหายใดๆ ที่เกิดจากการให้ข้อมูลที่ไม่ถูกต้องหรือไม่ครบถ้วน',
      ),
      const SizedBox(height: 24),
      _buildPolicyPoint(
        4,
        'ผู้ใช้บริการตกลงที่จะไม่ใช้บริการในทางที่ผิดกฎหมาย หรือเพื่อวัตถุประสงค์ที่ผิดกฎหมาย รวมถึงการละเมิดสิทธิ์ของผู้อื่น การส่งข้อมูลที่เป็นเท็จ หรือการกระทำใดๆ ที่อาจก่อให้เกิดความเสียหายต่อบริษัทหรือบุคคลที่สาม',
      ),
      const SizedBox(height: 24),
      _buildPolicyPoint(
        5,
        'บริษัทขอสงวนสิทธิ์ในการระงับหรือยกเลิกการให้บริการแก่ผู้ใช้บริการที่ละเมิดข้อกำหนดและเงื่อนไขการใช้งาน โดยไม่ต้องแจ้งให้ทราบล่วงหน้า และไม่ต้องรับผิดชอบต่อความเสียหายใดๆ ที่เกิดขึ้นจากการระงับหรือยกเลิกการให้บริการ',
      ),
      const SizedBox(height: 24),
      _buildPolicyPoint(
        6,
        'ข้อกำหนดและเงื่อนไขการใช้งานนี้อยู่ภายใต้กฎหมายไทย หากเกิดข้อพิพาทใดๆ ให้ศาลที่มีเขตอำนาจในกรุงเทพมหานครเป็นผู้ชี้ขาด',
      ),
    ];
  }

  List<Widget> _buildPrivacyContent() {
    return [
      _buildPolicyPoint(
        1,
        'บริษัท ยัวร์เอเจนต์ แพลตฟอร์ม จำกัด ให้ความสำคัญกับการคุ้มครองข้อมูลส่วนบุคคลของผู้ใช้บริการ โดยจะเก็บรวบรวม ใช้ และเปิดเผยข้อมูลส่วนบุคคลตามนโยบายความเป็นส่วนตัวนี้เท่านั้น',
      ),
      const SizedBox(height: 24),
      _buildPolicyPoint(
        2,
        'ข้อมูลส่วนบุคคลที่บริษัทเก็บรวบรวม ได้แก่ ชื่อ นามสกุล อีเมล หมายเลขโทรศัพท์ ที่อยู่ และข้อมูลอื่นๆ ที่ผู้ใช้บริการให้ไว้ในระหว่างการใช้งานแพลตฟอร์ม',
      ),
      const SizedBox(height: 24),
      _buildPolicyPoint(
        3,
        'บริษัทจะใช้ข้อมูลส่วนบุคคลเพื่อการให้บริการ การปรับปรุงบริการ การส่งข้อมูลข่าวสาร และวัตถุประสงค์อื่นๆ ที่เกี่ยวข้องกับบริการของบริษัทเท่านั้น',
      ),
      const SizedBox(height: 24),
      _buildPolicyPoint(
        4,
        'บริษัทจะไม่เปิดเผยข้อมูลส่วนบุคคลให้แก่บุคคลที่สามโดยไม่ได้รับความยินยอมจากผู้ใช้บริการ ยกเว้นในกรณีที่กฎหมายกำหนด หรือเพื่อการป้องกันหรือระงับอันตรายต่อชีวิต ร่างกาย หรือสุขภาพ',
      ),
      const SizedBox(height: 24),
      _buildPolicyPoint(
        5,
        'ผู้ใช้บริการมีสิทธิ์ในการเข้าถึง แก้ไข หรือลบข้อมูลส่วนบุคคลของตนได้ตลอดเวลา โดยติดต่อผ่านช่องทางที่บริษัทกำหนด',
      ),
    ];
  }

  List<Widget> _buildDisclaimerContent() {
    return [
      _buildPolicyPoint(
        1,
        'ข้อมูลที่แสดงในแพลตฟอร์มเป็นข้อมูลที่ได้รับจากแหล่งต่างๆ บริษัทไม่รับประกันความถูกต้อง ครบถ้วน หรือเป็นปัจจุบันของข้อมูลทั้งหมด',
      ),
      const SizedBox(height: 24),
      _buildPolicyPoint(
        2,
        'บริษัทไม่รับผิดชอบต่อความเสียหายใดๆ ที่เกิดจากการใช้หรือไม่สามารถใช้บริการของแพลตฟอร์ม รวมถึงความเสียหายทางอ้อม ตามมา หรือเฉพาะเจาะจง',
      ),
      const SizedBox(height: 24),
      _buildPolicyPoint(
        3,
        'การเชื่อมโยงไปยังเว็บไซต์อื่นๆ ที่ปรากฏในแพลตฟอร์ม เป็นเพียงการอำนวยความสะดวกเท่านั้น บริษัทไม่รับผิดชอบต่อเนื้อหา หรือการปฏิบัติการใดๆ ของเว็บไซต์เหล่านั้น',
      ),
      const SizedBox(height: 24),
      _buildPolicyPoint(
        4,
        'บริษัทขอสงวนสิทธิ์ในการแก้ไข เปลี่ยนแปลง หรือยกเลิกบริการใดๆ ได้ตลอดเวลาโดยไม่ต้องแจ้งให้ทราบล่วงหน้า',
      ),
    ];
  }

  Widget _buildPolicyPoint(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$number.',
          style: GoogleFonts.anuphan(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF181D27),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.anuphan(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF181D27),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
