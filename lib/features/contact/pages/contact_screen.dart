import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../widgets/backgrounds/blue_wave_background.dart';
import '../../../widgets/app_coming_soon_placeholder.dart';

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
              SafeArea(child: Center(child: const AppComingSoonPlaceholder())),
              Positioned(
                top: kToolbarHeight,
                left: 16,
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/chevron-left.svg',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
