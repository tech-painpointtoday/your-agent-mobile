import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/widgets/buttons/app_button.dart';
import 'package:yourhome/widgets/inputs/app_text_field.dart';
import 'package:yourhome/l10n/app_localizations.dart';

class MatchingSettingsBottomSheet extends StatefulWidget {
  final int initialScore;
  final Function(int) onSave;

  const MatchingSettingsBottomSheet({
    super.key,
    required this.initialScore,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required int initialScore,
    required Function(int) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MatchingSettingsBottomSheet(
          initialScore: initialScore,
          onSave: onSave,
        ),
      ),
    );
  }

  @override
  State<MatchingSettingsBottomSheet> createState() =>
      _MatchingSettingsBottomSheetState();
}

class _MatchingSettingsBottomSheetState
    extends State<MatchingSettingsBottomSheet> {
  late TextEditingController _scoreController;

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController(
      text: widget.initialScore.toString(),
    );
    _scoreController.addListener(_onScoreChanged);
  }

  void _onScoreChanged() {
    final text = _scoreController.text;

    if (text.isEmpty) {
      setState(() {});
      return;
    }

    final score = int.tryParse(text);

    if (score != null) {
      String newText = text;

      if (score > 100) {
        newText = '100';
      } else if (text != score.toString()) {
        newText = score.toString();
      }

      if (text != newText) {
        _scoreController.text = newText;
        _scoreController.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
                  l10n.matchingSettingsTitle,
                  style: GoogleFonts.anuphan(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.matchingSettingsSubtitle,
                  style: GoogleFonts.anuphan(
                    fontSize: 14,
                    color: AppColors.baseGrey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: l10n.minimumScoreLabel,
                  isRequired: true,
                  controller: _scoreController,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  hintText: '0',
                  suffix: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      l10n.scorePercentSuffix,
                      style: GoogleFonts.anuphan(
                        fontSize: 16,
                        color: AppColors.baseGrey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
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
                    text: l10n.cancel,
                    style: AppButtonStyle.outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: AppButton(
                    text: l10n.save,
                    style: AppButtonStyle.primary,
                    onPressed: _scoreController.text.isEmpty
                        ? null
                        : () {
                            final score =
                                int.tryParse(_scoreController.text) ?? 0;
                            widget.onSave(score);
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
