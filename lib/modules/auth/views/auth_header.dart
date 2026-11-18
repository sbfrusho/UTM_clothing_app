import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';

/// Serif headline + muted supporting line used on every auth screen.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineLarge),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: context.palette.mutedText,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
