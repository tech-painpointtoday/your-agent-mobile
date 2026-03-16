import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yourhome/core/theme/app_colors.dart';
import 'package:yourhome/widgets/buttons/app_button.dart';
import 'package:yourhome/widgets/dialogs/status_dialog.dart';
import 'package:yourhome/widgets/inputs/app_text_field.dart';
import 'package:yourhome/l10n/app_localizations.dart';
import 'package:yourhome/utils/thai_phone_input_formatter.dart';
import 'package:yourhome/core/di/dependency_injection.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yourhome/widgets/modals/app_confirmation_bottom_sheet.dart';
import '../bloc/profile_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_bloc.dart';

class AccountActionSheets {
  static Future<void> showChangeEmail(BuildContext context, ProfileBloc bloc) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          BlocProvider.value(value: bloc, child: const _EmailChangeSheet()),
    );
  }

  static Future<void> showChangePhone(BuildContext context, ProfileBloc bloc) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          BlocProvider.value(value: bloc, child: const _PhoneChangeSheet()),
    );
  }

  static Future<void> showDeleteAccount(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _DeleteAccountSheet(),
    );
  }
}

class _EmailChangeSheet extends StatefulWidget {
  const _EmailChangeSheet();

  @override
  State<_EmailChangeSheet> createState() => _EmailChangeSheetState();
}

class _EmailChangeSheetState extends State<_EmailChangeSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isEnabled = false;

  void _validate(String value) {
    final regex = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    );
    setState(() {
      _isEnabled = regex.hasMatch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          context.pop();
        }
      },
      builder: (context, state) {
        return _BaseActionSheet(
          title: AppLocalizations.of(context).requestChangeEmailLabel,
          subtitle: AppLocalizations.of(context).changeEmailSubtitle,
          actionLabel: AppLocalizations.of(context).requestChangeButton,
          isActionEnabled: _isEnabled,
          isLoading: state is ProfileUpdateLoading,
          onAction: () {
            context.read<ProfileBloc>().add(
              UpdateWorkInfo({'email': _controller.text.trim()}),
            );
          },
          child: AppTextField(
            label: AppLocalizations.of(context).newEmailLabel,
            isRequired: true,
            hintText: AppLocalizations.of(context).newEmailLabel,
            controller: _controller,
            onChanged: _validate,
            keyboardType: TextInputType.emailAddress,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
            ],
            prefix: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 0, 16),
              child: SvgPicture.asset(
                'assets/icons/email.svg',
                height: 16,
                width: 16,
                fit: BoxFit.scaleDown,
                colorFilter: const ColorFilter.mode(
                  AppColors.baseGrey,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PhoneChangeSheet extends StatefulWidget {
  const _PhoneChangeSheet();

  @override
  State<_PhoneChangeSheet> createState() => _PhoneChangeSheetState();
}

class _PhoneChangeSheetState extends State<_PhoneChangeSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isEnabled = false;

  void _validate(String value) {
    setState(() {
      _isEnabled = value.length >= 9; // Basic phone length check
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          context.pop();
        }
      },
      builder: (context, state) {
        return _BaseActionSheet(
          title: AppLocalizations.of(context).requestChangePhoneLabel,
          subtitle: AppLocalizations.of(context).changePhoneSubtitle,
          actionLabel: AppLocalizations.of(context).requestChangeButton,
          isActionEnabled: _isEnabled,
          isLoading: state is ProfileUpdateLoading,
          onAction: () {
            context.read<ProfileBloc>().add(
              UpdateWorkInfo({'mobile_number': _controller.text.trim()}),
            );
          },
          child: AppTextField(
            label: AppLocalizations.of(context).newPhoneLabel,
            isRequired: true,
            hintText: AppLocalizations.of(context).newPhoneLabel,
            controller: _controller,
            onChanged: _validate,
            prefix: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 0, 16),
              child: SvgPicture.asset(
                'assets/icons/phone.svg',
                height: 16,
                width: 16,
                fit: BoxFit.scaleDown,
                colorFilter: const ColorFilter.mode(
                  AppColors.baseGrey,
                  BlendMode.srcIn,
                ),
              ),
            ),
            inputFormatters: [ThaiPhoneInputFormatter()],
            keyboardType: TextInputType.phone,
          ),
        );
      },
    );
  }
}

class _BaseActionSheet extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final String actionLabel;
  final VoidCallback onAction;
  final bool isActionEnabled;
  final bool isLoading;

  const _BaseActionSheet({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.actionLabel,
    required this.onAction,
    this.isActionEnabled = true,
    this.isLoading = false,
  });

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
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
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
                SizedBox(height: 24),
                Text(
                  title,
                  style: GoogleFonts.anuphan(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  subtitle,
                  style: GoogleFonts.anuphan(
                    fontSize: 14,
                    color: AppColors.baseGrey,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 24),
                child,
              ],
            ),
          ),
          SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x145A5A5A),
                  blurRadius: 24,
                  offset: Offset(0, -8),
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
                    onPressed: () => context.pop(),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: AppButton(
                    text: actionLabel,
                    style: AppButtonStyle.primary,
                    isLoading: isLoading,
                    onPressed: (isActionEnabled && !isLoading)
                        ? onAction
                        : null,
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

class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet();

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _canDelete = false;
  bool _isDeleting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _canDelete =
          _passwordController.text.isNotEmpty &&
          _reasonController.text.trim() == 'DELETE';
    });
  }

  Future<void> _deleteAccount() async {
    final result = await DependencyInjection.authRepository.deleteAccount(
      password: _passwordController.text.trim(),
      reason: 'USER:DELETE',
    );
    result.fold((failure) => throw Exception(failure.message), (_) => null);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            32,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/dialog/YA_Illustration_ConfirmDeleteAccount.png',
                width: 160,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: Colors.grey[100],
                  child: const Icon(
                    Icons.person_off,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).deleteAccountTitle,
                style: GoogleFonts.anuphan(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.baseBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppLocalizations.of(context).deleteAccountWarning,
                  style: GoogleFonts.anuphan(
                    fontSize: 14,
                    color: AppColors.baseGrey,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    style: GoogleFonts.anuphan(
                      fontSize: 14,
                      color: AppColors.baseGrey,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(
                          context,
                        ).deleteAccountConfirmPrompt,
                      ),
                      TextSpan(
                        text: 'DELETE',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.supportRedDark,
                        ),
                      ),
                      TextSpan(
                        text: AppLocalizations.of(
                          context,
                        ).deleteAccountConfirmSuffix,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AppTextField(
                label: AppLocalizations.of(context).password,
                hintText: AppLocalizations.of(context).password,
                controller: _passwordController,
                obscureText: true,
                onChanged: (_) => _validate(),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: AppLocalizations.of(context).confirmDelete,
                hintText: 'DELETE',
                controller: _reasonController,
                onChanged: (_) => _validate(),
              ),
              const SizedBox(height: 24),
              AppButton(
                width: double.infinity,
                text: AppLocalizations.of(context).yesDeleteImmediately,
                style: AppButtonStyle.destructive,
                isLoading: _isDeleting,
                onPressed: (_canDelete && !_isDeleting)
                    ? () async {
                        AppConfirmationBottomSheet.show(
                          context: context,
                          style: ConfirmationStyle.destructive,
                          title: AppLocalizations.of(
                            context,
                          ).deleteAccountTitle,
                          description: AppLocalizations.of(
                            context,
                          ).deleteAccountWarning,
                          confirmLabel: AppLocalizations.of(
                            context,
                          ).confirmDelete,
                          onConfirm: () async {
                            setState(() => _isDeleting = true);
                            try {
                              await _deleteAccount();

                              // Refresh global auth state to trigger router/UI updates
                              if (context.mounted) {
                                context.read<AuthBloc>().add(
                                  const CheckAuthStatusEvent(),
                                );
                                // Clear all modals and go to login
                                context.go('/login');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                setState(() => _isDeleting = false);
                                StatusDialog.showError(
                                  title: AppLocalizations.of(context).error,
                                  message: e.toString(),
                                  context: context,
                                );
                              }
                            }
                          },
                        );
                      }
                    : null,
              ),
              const SizedBox(height: 16),
              AppButton(
                width: double.infinity,
                onPressed: () => context.pop(),
                text: AppLocalizations.of(context).statusCancelled,
                style: AppButtonStyle.ghost,
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: InkWell(
            onTap: () => context.pop(),
            child: SvgPicture.asset(
              'assets/icons/x-circle-filled.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.baseLightGrey,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
