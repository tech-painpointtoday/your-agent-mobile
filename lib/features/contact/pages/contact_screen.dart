import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/backgrounds/blue_wave_background.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double headerHeight = constraints.maxHeight * 0.38;

          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: headerHeight,
                child: const BlueWaveBackground(),
              ),
              SafeArea(
                child: Center(
                  child: Text(
                    'Contact Screen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.baseDarkGrey,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
