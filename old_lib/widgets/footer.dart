import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:youragent/l10n/app_localizations.dart';

class Footer extends StatelessWidget {
  final Color bgColor;

  const Footer({super.key, this.bgColor = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(color: Colors.transparent),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          
          if (isMobile) {
            // Mobile: Stack vertically
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: _buildFooterText(l10n.copyright),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    _buildFooterLink(context, l10n.terms_and_conditions, 'terms'),
                    _buildFooterSeparator(),
                    _buildFooterLink(context, l10n.privacy_policy, 'privacy'),
                    _buildFooterSeparator(),
                    _buildFooterLink(context, l10n.reserved_rights, 'disclaimer'),
                  ],
                ),
              ],
            );
          }
          
          // Desktop: Horizontal layout with flexible children
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: _buildFooterText(l10n.copyright),
              ),
              _buildFooterSeparator(),
              Flexible(
                child: _buildFooterLink(context, l10n.terms_and_conditions, 'terms'),
              ),
              _buildFooterSeparator(),
              Flexible(
                child: _buildFooterLink(context, l10n.privacy_policy, 'privacy'),
              ),
              _buildFooterSeparator(),
              Flexible(
                child: _buildFooterLink(context, l10n.reserved_rights, 'disclaimer'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFooterText(String text) {
    return Text(
      text,
      style: GoogleFonts.anuphan(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFA4A7AE),
      ),
    );
  }

  Widget _buildFooterSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '|',
        style: GoogleFonts.anuphan(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFA4A7AE),
        ),
      ),
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, String policyType) {
    return InkWell(
      onTap: () {
        context.push('/policy?type=$policyType');
      },
      child: Text(
        text,
        style: GoogleFonts.anuphan(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFA4A7AE),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
