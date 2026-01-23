import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class MoneyScreen extends StatelessWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Money'),
        backgroundColor: AppColors.white,
        elevation: 0,
        foregroundColor: AppColors.gray700,
      ),
      body: const Center(
        child: Text(
          'Money Screen',
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
