import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/buttons/app_button.dart';

enum PolicyType { terms, privacy, disclaimer }

class PolicyScreen extends StatefulWidget {
  final Function(Locale) changeLocale;
  final PolicyType? initialPolicyType;
  final bool showBottomButtons;

  const PolicyScreen({
    super.key,
    required this.changeLocale,
    this.initialPolicyType,
    this.showBottomButtons = true,
  });

  @override
  State<PolicyScreen> createState() => _PolicyScreenState();
}

class _PolicyScreenState extends State<PolicyScreen> {
  late PolicyType _selectedPolicy;
  late ScrollController _scrollController;
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _selectedPolicy = widget.initialPolicyType ?? PolicyType.terms;
    _scrollController = ScrollController();
    _scrollController.addListener(_checkScrollPosition);
    // Check if content fits on screen after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfContentFits();
    });
  }

  void _checkIfContentFits() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      // If content doesn't require scrolling, enable button immediately
      if (maxScroll <= 0) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      } else {
        // Also check current position in case user is already at bottom
        _checkScrollPosition();
      }
    } else {
      // Retry after a short delay if controller not attached yet
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _checkIfContentFits();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScrollPosition);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollPosition() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final threshold = 50.0; // Allow some tolerance (50px from bottom)

      if (currentScroll >= maxScroll - threshold && !_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
          onPressed: () => context.pop(false),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title(),
                            style: GoogleFonts.anuphan(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: AppColors.baseBlack,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'บริษัท ยัวร์โฮม แพลตฟอร์ม จำกัด',
                            style: GoogleFonts.anuphan(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'อัปเดตล่าสุด 24 ธ.ค. 2568, 12:00 น.',
                            style: GoogleFonts.anuphan(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.baseGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: AppColors.baseLightGrey),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _content(),
                    ),
                    SizedBox(height: 256),
                  ],
                ),
              ),
            ),
            if (widget.showBottomButtons)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.baseLightGrey),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 10,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.baseDarkGrey,
                          side: const BorderSide(
                            color: AppColors.baseLightGrey,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: Text(
                          'ไม่ยอมรับ',
                          style: GoogleFonts.anuphan(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'ยอมรับ',
                        style: AppButtonStyle.primary,
                        height: 52,
                        onPressed: _hasScrolledToBottom
                            ? () => context.pop(true)
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _title() {
    switch (_selectedPolicy) {
      case PolicyType.terms:
        return 'ข้อตกลงและเงื่อนไขการใช้งาน';
      case PolicyType.privacy:
        return 'นโยบายความเป็นส่วนตัว';
      case PolicyType.disclaimer:
        return 'ข้อสงวนสิทธิ์';
    }
  }

  Widget _content() {
    switch (_selectedPolicy) {
      case PolicyType.terms:
        return _buildTermsContent();
      case PolicyType.privacy:
        return _buildPrivacyContent();
      case PolicyType.disclaimer:
        return _buildDisclaimerContent();
    }
  }

  Widget _buildTermsContent() {
    final items = <String>[
      'ผู้ใช้บริการตกลงที่จะใช้บริการของบริษัท ยัวร์เอเจนต์ แพลตฟอร์ม จำกัด ตามข้อกำหนดและเงื่อนไขที่กำหนดไว้ในเอกสารฉบับนี้ โดยการเข้าใช้งานหรือใช้บริการใดๆ ของแพลตฟอร์ม ถือว่าผู้ใช้บริการยอมรับและผูกพันตามข้อกำหนดและเงื่อนไขทั้งหมด',
      'บริษัทขอสงวนสิทธิ์ในการแก้ไข เปลี่ยนแปลง หรือยกเลิกข้อกำหนดและเงื่อนไขการใช้งานได้ตลอดเวลา โดยจะแจ้งให้ผู้ใช้บริการทราบผ่านทางเว็บไซต์หรือช่องทางอื่นๆ ที่เหมาะสม การแก้ไขใดๆ จะมีผลบังคับใช้ทันทีหลังจากประกาศ',
      'ผู้ใช้บริการต้องรับผิดชอบต่อข้อมูลที่ให้ไว้ในแพลตฟอร์ม และต้องให้ข้อมูลที่ถูกต้อง ครบถ้วน และเป็นปัจจุบัน บริษัทไม่รับผิดชอบต่อความเสียหายใดๆ ที่เกิดจากการให้ข้อมูลที่ไม่ถูกต้องหรือไม่ครบถ้วน',
      'ผู้ใช้บริการตกลงที่จะไม่ใช้บริการในทางที่ผิดกฎหมาย หรือเพื่อวัตถุประสงค์ที่ผิดกฎหมาย รวมถึงการละเมิดสิทธิ์ของผู้อื่น การส่งข้อมูลที่เป็นเท็จ หรือการกระทำใดๆ ที่อาจก่อให้เกิดความเสียหายต่อบริษัทหรือบุคคลที่สาม',
      'บริษัทขอสงวนสิทธิ์ในการระงับหรือยกเลิกการให้บริการแก่ผู้ใช้บริการที่ละเมิดข้อกำหนดและเงื่อนไขการใช้งาน โดยไม่ต้องแจ้งให้ทราบล่วงหน้า และไม่ต้องรับผิดชอบต่อความเสียหายใดๆ ที่เกิดขึ้นจากการระงับหรือยกเลิกการให้บริการ',
      'ข้อกำหนดและเงื่อนไขการใช้งานนี้อยู่ภายใต้กฎหมายไทย หากเกิดข้อพิพาทใดๆ ให้ศาลที่มีเขตอำนาจในกรุงเทพมหานครเป็นผู้ชี้ขาด',
    ];

    return _numberedList(items);
  }

  Widget _buildPrivacyContent() {
    final items = <String>[
      'บริษัท ยัวร์เอเจนต์ แพลตฟอร์ม จำกัด ให้ความสำคัญกับการคุ้มครองข้อมูลส่วนบุคคลของผู้ใช้บริการ โดยจะเก็บรวบรวม ใช้ และเปิดเผยข้อมูลส่วนบุคคลตามนโยบายความเป็นส่วนตัวนี้เท่านั้น',
      'ข้อมูลส่วนบุคคลที่บริษัทเก็บรวบรวม ได้แก่ ชื่อ นามสกุล อีเมล หมายเลขโทรศัพท์ ที่อยู่ และข้อมูลอื่นๆ ที่ผู้ใช้บริการให้ไว้ในระหว่างการใช้งานแพลตฟอร์ม',
      'บริษัทจะใช้ข้อมูลส่วนบุคคลเพื่อการให้บริการ การปรับปรุงบริการ การส่งข้อมูลข่าวสาร และวัตถุประสงค์อื่นๆ ที่เกี่ยวข้องกับบริการของบริษัทเท่านั้น',
      'บริษัทจะไม่เปิดเผยข้อมูลส่วนบุคคลให้แก่บุคคลที่สามโดยไม่ได้รับความยินยอมจากผู้ใช้บริการ ยกเว้นในกรณีที่กฎหมายกำหนด หรือเพื่อการป้องกันหรือระงับอันตรายต่อชีวิต ร่างกาย หรือสุขภาพ',
      'ผู้ใช้บริการมีสิทธิ์ในการเข้าถึง แก้ไข หรือลบข้อมูลส่วนบุคคลของตนได้ตลอดเวลา โดยติดต่อผ่านช่องทางที่บริษัทกำหนด',
    ];

    return _numberedList(items);
  }

  Widget _buildDisclaimerContent() {
    final items = <String>[
      'ข้อมูลที่แสดงในแพลตฟอร์มเป็นข้อมูลที่ได้รับจากแหล่งต่างๆ บริษัทไม่รับประกันความถูกต้อง ครบถ้วน หรือเป็นปัจจุบันของข้อมูลทั้งหมด',
      'บริษัทไม่รับผิดชอบต่อความเสียหายใดๆ ที่เกิดจากการใช้หรือไม่สามารถใช้บริการของแพลตฟอร์ม รวมถึงความเสียหายทางอ้อม ตามมา หรือเฉพาะเจาะจง',
      'การเชื่อมโยงไปยังเว็บไซต์อื่นๆ ที่ปรากฏในแพลตฟอร์ม เป็นเพียงการอำนวยความสะดวกเท่านั้น บริษัทไม่รับผิดชอบต่อเนื้อหา หรือการปฏิบัติการใดๆ ของเว็บไซต์เหล่านั้น',
      'บริษัทขอสงวนสิทธิ์ในการแก้ไข เปลี่ยนแปลง หรือยกเลิกบริการใดๆ ได้ตลอดเวลาโดยไม่ต้องแจ้งให้ทราบล่วงหน้า',
    ];

    return _numberedList(items);
  }

  Widget _numberedList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    '${i + 1}.',
                    style: GoogleFonts.anuphan(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.baseDarkGrey,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    items[i],
                    style: GoogleFonts.anuphan(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.baseDarkGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
