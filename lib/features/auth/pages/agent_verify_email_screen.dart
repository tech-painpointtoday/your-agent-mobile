import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/dependency_injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/buttons/app_button.dart';
import '../../../widgets/dialogs/status_dialog.dart';

class AgentVerifyEmailScreen extends StatefulWidget {
  final String id;
  final String hash;
  final String expires;
  final String signature;

  const AgentVerifyEmailScreen({
    super.key,
    required this.id,
    required this.hash,
    required this.expires,
    required this.signature,
  });

  @override
  State<AgentVerifyEmailScreen> createState() => _AgentVerifyEmailScreenState();
}

class _AgentVerifyEmailScreenState extends State<AgentVerifyEmailScreen> {
  bool _isLoading = true;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verify();
  }

  Future<void> _verify() async {
    final missing = <String>[];
    if (widget.id.isEmpty) missing.add('id');
    if (widget.hash.isEmpty) missing.add('hash');
    if (widget.expires.isEmpty) missing.add('expires');
    if (widget.signature.isEmpty) missing.add('signature');

    if (missing.isNotEmpty) {
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _errorMessage = 'Missing query parameters: ${missing.join(', ')}';
      });
      return;
    }

    try {
      final response = await DependencyInjection.apiClient.get(
        '/agent/verify-email',
        queryParameters: {
          'id': widget.id,
          'hash': widget.hash,
          'expires': widget.expires,
          'signature': widget.signature,
        },
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isSuccess = response.statusCode == 200;
        _errorMessage = response.statusCode == 200
            ? null
            : 'Verification failed.';
      });

      if (response.statusCode == 200) {
        StatusDialog.showSuccess(
          context: context,
          title: 'Email verified',
          message: 'Your email has been verified successfully.',
        );
      } else {
        StatusDialog.showError(
          context: context,
          title: 'Verification failed',
          message: 'Please try again or request a new verification link.',
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map
          ? (e.response?.data['message']?.toString())
          : e.message;
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _errorMessage = message ?? 'Unable to verify email.';
      });
      StatusDialog.showError(
        context: context,
        title: 'Verification failed',
        message: _errorMessage,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSuccess = false;
        _errorMessage = e.toString();
      });
      StatusDialog.showError(
        context: context,
        title: 'Verification failed',
        message: _errorMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    const Spacer(),
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error,
                      size: 72,
                      color: _isSuccess
                          ? AppColors.supportGreenDark
                          : AppColors.supportRedDeep,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isSuccess ? 'Email verified' : 'Verification failed',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.baseDarkGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSuccess
                          ? 'You can now log in to your account.'
                          : (_errorMessage ??
                                'Please try again or request a new verification link.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.baseGrey,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      width: double.infinity,
                      text: 'Go to Login',
                      style: AppButtonStyle.primary,
                      onPressed: () => context.go('/login'),
                    ),
                    if (!_isSuccess) ...[
                      const SizedBox(height: 12),
                      AppButton(
                        width: double.infinity,
                        text: 'Try again',
                        style: AppButtonStyle.outline,
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _isSuccess = false;
                            _errorMessage = null;
                          });
                          _verify();
                        },
                      ),
                    ],
                    const Spacer(),
                  ],
                ),
        ),
      ),
    );
  }
}
