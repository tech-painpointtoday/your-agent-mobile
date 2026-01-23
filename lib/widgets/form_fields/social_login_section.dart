import 'package:flutter/widgets.dart';

import '../../domain/entities/user.dart';

/// Stubbed for mobile until social auth is wired.
class SocialLoginSection extends StatelessWidget {
  final UserRole role;
  const SocialLoginSection({super.key, required this.role});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

