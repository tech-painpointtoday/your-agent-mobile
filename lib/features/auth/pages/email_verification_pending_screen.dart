import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class EmailVerificationPendingScreen extends StatelessWidget {
  final String email;
  const EmailVerificationPendingScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOperationState) {
          if (state.resendEmailStatus == ResendEmailStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ส่งอีเมลเรียบร้อยแล้ว')),
            );
          } else if (state.resendEmailStatus == ResendEmailStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.resendEmailError ?? 'ไม่สามารถส่งอีเมลได้'),
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
                const Spacer(),
                // Illustration placeholder
                Center(
                  child: Image.asset(
                    'assets/icons/mail.png',
                    width: 170,
                    height: 170,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'ยืนยันอีเมล',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.eerieBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'เราได้ส่งลิงก์ยืนยันไปที่อีเมลของคุณแล้ว\nกรุณายืนยันอีเมลผ่านลิงก์ที่ส่งไป เพื่อเริ่มต้นใช้งาน',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.gray400,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading =
                        state is AuthOperationState &&
                        state.resendEmailStatus == ResendEmailStatus.loading;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () => context.read<AuthBloc>().add(
                                AuthResendVerificationPublicRequested(
                                  email: email,
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
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
                            : const Text(
                                'ส่งลิงก์อีกครั้ง',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
