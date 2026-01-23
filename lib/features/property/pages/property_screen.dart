import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PropertyScreen extends StatelessWidget {
  const PropertyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Property'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.gray700,
      ),
      body: const Center(
        child: Text(
          'Property Screen',
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
