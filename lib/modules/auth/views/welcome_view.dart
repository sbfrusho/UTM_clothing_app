import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/brand/app_logo.dart';

/// Static entry screen; no state, so no view model.
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: AppLogo(size: 40, showWordmark: true),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _HeroPanel(
                  background: theme.colorScheme.surfaceContainerHigh,
                  accent: palette.accent,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Dress well.\nLive simply.',
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Everyday clothing and merchandise, thoughtfully picked '
                'and delivered to your door.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: palette.mutedText,
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () => Get.toNamed<void>(AppRoutes.register),
                child: const Text('Get started'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Get.toNamed<void>(AppRoutes.login),
                child: const Text('I already have an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decorative composition: soft shapes framing the brand mark.
class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.background, required this.accent});

  final Color background;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: ColoredBox(
        color: background,
        child: LayoutBuilder(
          builder: (context, c) {
            final s = c.biggest.shortestSide;
            return Stack(
              children: [
                Positioned(
                  right: -s * 0.18,
                  top: -s * 0.12,
                  child: _Circle(
                    size: s * 0.75,
                    color: accent.withValues(alpha: 0.45),
                  ),
                ),
                Positioned(
                  left: -s * 0.2,
                  bottom: -s * 0.25,
                  child: _Circle(
                    size: s * 0.8,
                    color: scheme.surfaceContainerLowest.withValues(alpha: 0.7),
                  ),
                ),
                Positioned(
                  left: s * 0.12,
                  top: s * 0.14,
                  child: _Circle(size: s * 0.1, color: scheme.primary),
                ),
                Center(child: AppLogo(size: s * 0.42)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
