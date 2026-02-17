import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppComingSoonPlaceholder extends StatelessWidget {
  const AppComingSoonPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/home/no_access.png',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),
        Text(
          'Coming Soon',
          style: GoogleFonts.anuphan(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ฟีเจอร์ทั้งหมดกำลังจะเปิดตัวเร็ว ๆ นี้',
          textAlign: TextAlign.center,
          style: GoogleFonts.anuphan(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
