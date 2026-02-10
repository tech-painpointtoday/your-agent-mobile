import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/widgets/buttons/app_button.dart';
import 'package:youragent/l10n/app_localizations.dart';

class LanguageSelectionBottomSheet extends StatefulWidget {
  final Function(Locale) onLanguageSelected;
  final Locale currentLocale;

  const LanguageSelectionBottomSheet({
    super.key,
    required this.onLanguageSelected,
    required this.currentLocale,
  });

  static Future<void> show({
    required BuildContext context,
    required Locale currentLocale,
    required Function(Locale) onLanguageSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LanguageSelectionBottomSheet(
        onLanguageSelected: onLanguageSelected,
        currentLocale: currentLocale,
      ),
    );
  }

  @override
  State<LanguageSelectionBottomSheet> createState() =>
      _LanguageSelectionBottomSheetState();
}

class _LanguageSelectionBottomSheetState
    extends State<LanguageSelectionBottomSheet> {
  late Locale _selectedLocale;

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.currentLocale;
  }

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
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).change_language,
                  style: GoogleFonts.anuphan(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).select_language,
                  style: GoogleFonts.anuphan(
                    fontSize: 14,
                    color: AppColors.baseGrey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                _LanguageOption(
                  label: AppLocalizations.of(context).thaiLanguage,
                  flagAsset: 'assets/country/TH.png',
                  isSelected: _selectedLocale.languageCode == 'th',
                  onTap: () =>
                      setState(() => _selectedLocale = const Locale('th')),
                ),
                const SizedBox(height: 12),
                _LanguageOption(
                  label: AppLocalizations.of(context).englishLanguage,
                  flagAsset: 'assets/country/US.png',
                  isSelected: _selectedLocale.languageCode == 'en',
                  onTap: () =>
                      setState(() => _selectedLocale = const Locale('en')),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0x145A5A5A),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: AppLocalizations.of(context).statusCancelled,
                    style: AppButtonStyle.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: AppButton(
                    text: AppLocalizations.of(context).confirmSaveLabel,
                    style: AppButtonStyle.primary,
                    onPressed: () {
                      widget.onLanguageSelected(_selectedLocale);
                      Navigator.pop(context);
                    },
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

class _LanguageOption extends StatelessWidget {
  final String label;
  final String flagAsset;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.flagAsset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.supportBlueLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent, width: 1),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                flagAsset,
                width: 32,
                height: 24,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.anuphan(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.baseBlack,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.brandBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
