import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youragent/core/theme/app_colors.dart';
import 'package:youragent/features/auth/bloc/auth_bloc.dart';
import 'package:youragent/features/auth/bloc/auth_event.dart';
import 'package:youragent/features/auth/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';

class EmailVerificationPendingScreen extends StatelessWidget {
  final String email;

  const EmailVerificationPendingScreen({super.key, required this.email});

  void _handleStateChange(BuildContext context, AuthState state) {
    if (state is AuthOperationState) {
      if (state.resendEmailStatus == ResendEmailStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ส่งอีเมลเรียบร้อยแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (state.resendEmailStatus == ResendEmailStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.resendEmailError ?? 'ไม่สามารถส่งอีเมลได้'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleResendEmail(BuildContext context) {
    context.read<AuthBloc>().add(
      AuthResendVerificationPublicRequested(email: email),
    );
  }

  void _handleBackToLogin(BuildContext context) {
    context.go('/login/agent');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleStateChange,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 512),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Large Mail Icon
                    Icon(
                      Icons.mail_outline,
                      size: 120,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'ตรวจสอบอีเมลของคุณ',
                      style: GoogleFonts.anuphan(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.baseDarkGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      'เราได้ส่งลิงก์ยืนยันไปที่ $email แล้ว\nกรุณากดยืนยันเพื่อเริ่มใช้งาน',
                      style: GoogleFonts.anuphan(
                        fontSize: 16,
                        color: AppColors.baseDarkGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Resend Email Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading =
                            state is AuthOperationState &&
                            state.resendEmailStatus ==
                                ResendEmailStatus.loading;
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () => _handleResendEmail(context),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'ส่งอีเมลยืนยันอีกครั้ง',
                                    style: GoogleFonts.anuphan(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Back to Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => _handleBackToLogin(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(
                            color: AppColors.bonJour,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'กลับไปหน้าเข้าสู่ระบบ',
                          style: GoogleFonts.anuphan(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.baseDarkGrey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
