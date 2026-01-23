import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youragent/widgets/app_layout.dart';
import 'package:youragent/widgets/app_loader.dart';
import 'package:youragent/domain/entities/user.dart';

import '../bloc/profile_bloc.dart';
import '../widgets/profile_card.dart';

/// Profile Show Screen - shows user profile with real API data
class ProfileShowScreen extends StatefulWidget {
  final Function(Locale) changeLocale;
  final UserRole? role;

  const ProfileShowScreen({super.key, required this.changeLocale, this.role});

  @override
  State<ProfileShowScreen> createState() => _ProfileShowScreenState();
}

class _ProfileShowScreenState extends State<ProfileShowScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(const ProfileLoadRequested()),
      child: _ProfileContent(
        changeLocale: widget.changeLocale,
      ),
    );
  }
}

class _ProfileContent extends StatefulWidget {
  final Function(Locale) changeLocale;

  const _ProfileContent({required this.changeLocale});

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh profile when screen comes back into view (after initial load)
    // This handles the case when returning from edit screen
    if (_hasInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final bloc = context.read<ProfileBloc>();
          final currentState = bloc.state;
          // Only refresh if we have loaded data and not already loading
          if (currentState is ProfileLoaded && mounted) {
            // Refresh to get latest data
            bloc.add(const ProfileLoadRequested());
          }
        }
      });
    } else {
      _hasInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      changeLocale: widget.changeLocale,
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: AppLoader());
          }

          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(
                        const ProfileLoadRequested(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProfileLoaded ||
              state is ProfileUpdateSuccess ||
              state is ProfileVerificationSent) {
            final profile = state is ProfileLoaded
                ? state.profile
                : state is ProfileUpdateSuccess
                    ? state.profile
                    : (state as ProfileVerificationSent).profile;

            return ProfileCard(profile: profile);
          }

          return const Center(child: AppLoader());
        },
      ),
    );
  }
}
