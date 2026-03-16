import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/user.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class AuthHeader extends StatefulWidget {
  const AuthHeader({
    super.key,
    required this.changeLocale,
    this.currentRole,
    this.onRoleChanged,
  });

  final Function(Locale) changeLocale;
  final UserRole? currentRole;
  final Function(UserRole)? onRoleChanged;

  @override
  State<AuthHeader> createState() => _AuthHeaderState();
}

class _AuthHeaderState extends State<AuthHeader> {
  Locale? _currentLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    final normalized = Locale(locale.languageCode);
    _currentLocale ??= normalized;
  }

  String _roleName(UserRole role, AppLocalizations l10n) {
    switch (role) {
      case UserRole.seller:
        return l10n.role_seller;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isInLoginFlow = widget.onRoleChanged != null;

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => context.go('/login/seller'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/logo.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset('assets/icons/yourhome.svg', height: 16),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<Locale>(
                    value: _currentLocale ?? const Locale('th'),
                    onChanged: (newLocale) {
                      if (newLocale == null) return;
                      setState(() => _currentLocale = newLocale);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        widget.changeLocale(newLocale);
                      });
                    },
                    items: const [Locale('th'), Locale('en')]
                        .map(
                          (l) => DropdownMenuItem(
                            value: l,
                            child: Text(l.languageCode.toUpperCase()),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(width: 8),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is Authenticated) {
                      final user = state.user;
                      return Row(
                        children: [
                          Image.asset(
                            'assets/icons/${user.role.name}_profile.png',
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(_roleName(user.role, l10n)),
                        ],
                      );
                    }

                    if (isInLoginFlow) {
                      // Single role: seller; no dropdown needed
                      return Text(_roleName(widget.currentRole ?? UserRole.seller, l10n));
                    }

                    return TextButton(
                      onPressed: () => context.go('/login/seller'),
                      child: Text(l10n.login),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
