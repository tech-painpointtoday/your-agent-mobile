import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/widgets/inputs/app_text_field.dart';

class AccountActionSheets {
  static Future<void> showChangeEmail(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _EmailChangeSheet(),
    );
  }

  static Future<void> showChangePhone(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _PhoneChangeSheet(),
    );
  }

  static Future<void> showDeleteAccount(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _DeleteAccountSheet(),
    );
  }
}

class _EmailChangeSheet extends StatefulWidget {
  const _EmailChangeSheet();

  @override
  State<_EmailChangeSheet> createState() => _EmailChangeSheetState();
}

class _EmailChangeSheetState extends State<_EmailChangeSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isEnabled = false;

  void _validate(String value) {
    final regex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    );
    setState(() {
      _isEnabled = regex.hasMatch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _BaseActionSheet(
      title: 'แจ้งเปลี่ยนอีเมล',
      subtitle:
          'กรอกอีเมลใหม่ที่อยากเปลี่ยนได้เลย ถ้าคุณยืนยันแล้ว เราจะรีบตรวจสอบและแจ้งให้ทราบทันที',
      actionLabel: 'แจ้งเปลี่ยน',
      isActionEnabled: _isEnabled,
      onAction: () => Navigator.pop(context),
      child: AppTextField(
        label: 'อีเมลใหม่',
        isRequired: true,
        hintText: 'อีเมลใหม่',
        controller: _controller,
        onChanged: _validate,
        keyboardType: TextInputType.emailAddress,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
        ],
        prefix: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 0, 16),
          child: SvgPicture.asset(
            'assets/icons/email.svg',
            height: 16,
            width: 16,
            fit: BoxFit.scaleDown,
            colorFilter: const ColorFilter.mode(
              AppColors.baseGrey,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneChangeSheet extends StatefulWidget {
  const _PhoneChangeSheet();

  @override
  State<_PhoneChangeSheet> createState() => _PhoneChangeSheetState();
}

class _PhoneChangeSheetState extends State<_PhoneChangeSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isEnabled = false;

  void _validate(String value) {
    setState(() {
      _isEnabled = value.length >= 9; // Basic phone length check
    });
  }

  @override
  Widget build(BuildContext context) {
    return _BaseActionSheet(
      title: 'แจ้งเปลี่ยนหมายเลขโทรศัพท์',
      subtitle:
          'กรอกหมายเลขโทรศัพท์ใหม่ที่อยากเปลี่ยนได้เลย ถ้าคุณยืนยันแล้ว เราจะรีบตรวจสอบและแจ้งให้ทราบทันที',
      actionLabel: 'แจ้งเปลี่ยน',
      isActionEnabled: _isEnabled,
      onAction: () => Navigator.pop(context),
      child: AppTextField(
        label: 'หมายเลขโทรศัพท์ใหม่',
        isRequired: true,
        hintText: 'หมายเลขโทรศัพท์ใหม่',
        controller: _controller,
        onChanged: _validate,
        prefix: Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 0, 16),
          child: SvgPicture.asset(
            'assets/icons/phone.svg',
            height: 16,
            width: 16,
            fit: BoxFit.scaleDown,
            colorFilter: const ColorFilter.mode(
              AppColors.baseGrey,
              BlendMode.srcIn,
            ),
          ),
        ),
        keyboardType: TextInputType.phone,
      ),
    );
  }
}

class _BaseActionSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final String actionLabel;
  final VoidCallback onAction;
  final bool isActionEnabled;

  const _BaseActionSheet({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.actionLabel,
    required this.onAction,
    this.isActionEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.basePaleGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: GoogleFonts.anuphan(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: GoogleFonts.anuphan(
                    fontSize: 14,
                    color: AppColors.baseGrey,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x145A5A5A),
                  blurRadius: 24,
                  offset: Offset(0, -8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: 'ยกเลิก',
                    style: AppButtonStyle.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: AppButton(
                    text: actionLabel,
                    style: AppButtonStyle.primary,
                    onPressed: isActionEnabled ? onAction : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet();

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _canDelete = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            32,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/dialog/delete_account.png',
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: Colors.grey[100],
                  child: const Icon(
                    Icons.person_off,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ลบบัญชีผู้ใช้งาน?',
                style: GoogleFonts.anuphan(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.baseBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.anuphan(
                      fontSize: 14,
                      color: AppColors.baseGrey,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(
                        text: 'หากคุณต้องการลบบัญชีผู้ใช้งาน กรุณาพิมพ์คำว่า ',
                      ),
                      TextSpan(
                        text: '“Delete”',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.baseDarkGrey,
                        ),
                      ),
                      TextSpan(text: ' เพื่อยืนยันการลบบัญชี'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: '',
                hintText: 'พิมพ์ข้อความที่นี่...',
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    _canDelete = value.trim() == 'Delete';
                  });
                },
              ),
              const SizedBox(height: 16),
              AppButton(
                width: double.infinity,
                text: 'ใช่, ลบทันที',
                style: AppButtonStyle.destructive,
                onPressed: _canDelete
                    ? () {
                        Navigator.pop(context);
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              AppButton(
                width: double.infinity,
                onPressed: () => Navigator.pop(context),
                text: 'ยกเลิก',
                style: AppButtonStyle.ghost,
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/icons/x-circle-filled.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.baseLightGrey,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
