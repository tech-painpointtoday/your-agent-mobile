import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yourhome/core/di/dependency_injection.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/l10n/app_localizations.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String id;
  final String hash;
  final String expires;
  final String signature;
  final String role;

  const VerifyEmailScreen({
    super.key,
    required this.id,
    required this.hash,
    required this.expires,
    required this.signature,
    required this.role,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _isLoading = true;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verifyEmail();
  }

  Future<void> _verifyEmail() async {
    setState(() {
      _isLoading = true;
      _isSuccess = false;
      _errorMessage = null;
    });

    try {
      await DependencyInjection.apiClient.get(
        '/${widget.role}/verify-email',
        queryParameters: {
          'id': widget.id,
          'hash': widget.hash,
          'expires': widget.expires,
          'signature': widget.signature,
        },
        options: Options(headers: const {'Accept': 'application/json'}),
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.emailVerified,
          style: GoogleFonts.anuphan(
            color: AppColors.baseBlack,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _isLoading
              ? const CircularProgressIndicator(color: AppColors.primary)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error_outline,
                      size: 64,
                      color: _isSuccess
                          ? AppColors.supportGreenDark
                          : AppColors.supportRedDeep,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isSuccess ? l10n.emailVerified : l10n.errorOccurredTitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseBlack,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSuccess
                          ? l10n.registrationSuccessTitle
                          : (_errorMessage ?? l10n.errorOccurredTitle),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.anuphan(
                        color: AppColors.baseDarkGrey,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
