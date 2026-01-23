import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Contact'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.gray700,
      ),
      body: const Center(
        child: Text(
          'Contact Screen',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.gray600,
          ),
        ),
      ),
    );
  }
}
