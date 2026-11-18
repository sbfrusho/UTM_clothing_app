import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../theme/app_typography.dart';
import 'brand_mark_painter.dart';

/// Brand mark, optionally with the "Your Shop" wordmark. Theme-aware.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 48,
    this.showWordmark = false,
    this.axis = Axis.horizontal,
  });

  final double size;
  final bool showWordmark;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mark = SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: BrandMarkPainter(
          bagColor: scheme.primary,
          letterColor: scheme.surface,
        ),
      ),
    );
    if (!showWordmark) {
      return Semantics(label: AppConfig.appName, child: mark);
    }

    final wordmark = Text(
      AppConfig.appName,
      style: TextStyle(
        fontFamily: AppTypography.serif,
        fontWeight: FontWeight.w700,
        fontSize: size * (axis == Axis.horizontal ? 0.5 : 0.42),
        letterSpacing: -0.5,
        color: scheme.onSurface,
        height: 1,
      ),
    );
    return Semantics(
      label: AppConfig.appName,
      excludeSemantics: true,
      child: Flex(
        direction: axis,
        mainAxisSize: MainAxisSize.min,
        children: [
          mark,
          SizedBox(width: size * 0.25, height: size * 0.25),
          wordmark,
        ],
      ),
    );
  }
}
