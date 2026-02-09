import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/l10n/app_localizations.dart';
import 'package:youragent/widgets/badges/app_badge.dart';
import 'package:youragent/widgets/map/fullscreen_map_screen.dart';
import 'package:youragent/widgets/map/map_view.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final LatLng _companyLocation = const LatLng(
    13.696356549759164,
    100.61834276897947,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        title: Text(
          l10n.contactUsLabel,
          style: GoogleFonts.anuphan(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/chevron-left.svg',
            width: 18,
            height: 18,
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 16),
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: AppBadge(
                  label: l10n.contactInfoLabel,
                  color: BadgeColor.blue,
                  style: BadgeStyle.plain,
                  hasBorder: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              MapView(
                height: 160,
                initialLocation: _companyLocation,
                title: l10n.contactInfoLabel,
                snippet: l10n.companyAddressValue,
                onMaximizeTapped: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullscreenMapScreen(
                        showSearch: false,
                        initialLocation: _companyLocation,
                        title: l10n.contactInfoLabel,
                        snippet: l10n.companyAddressValue,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _ContactItem(
                icon: 'assets/icons/briefcase.svg',
                content: l10n.demoCompanyName,
              ),
              const SizedBox(height: 16),
              _ContactItem(
                icon: 'assets/icons/map-pin.svg',
                content: l10n.companyAddressValue,
              ),
              const SizedBox(height: 16),
              _ContactItem(
                icon: 'assets/icons/email.svg',
                content: l10n.companyEmailValue,
              ),
              const SizedBox(height: 16),
              _ContactItem(
                icon: 'assets/icons/phone.svg',
                content: l10n.companyPhoneValue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final String icon;
  final String content;

  const _ContactItem({required this.icon, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
          fit: BoxFit.scaleDown,
          colorFilter: const ColorFilter.mode(
            AppColors.brandBlue,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            content,
            style: GoogleFonts.anuphan(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.baseBlack,
              height: 0,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
