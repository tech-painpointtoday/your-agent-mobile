import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Footer extends StatelessWidget {
  final Color bgColor;

  const Footer({super.key, this.bgColor = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Center(
        child: Text(
          'Copyright © 2025 youragent.site',
          style: GoogleFonts.anuphan(
            fontSize: 12,
            color: const Color(0xFFA4A7AE),
          ),
        ),
      ),
    );
  }
}
