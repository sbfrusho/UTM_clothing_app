import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../view_models/social_sign_in_view_model.dart';

/// "or" divider plus "Continue with Google". Renders nothing when Google
/// sign-in is not configured for this build.
class GoogleSignInSection extends GetView<SocialSignInViewModel> {
  const GoogleSignInSection({super.key});

  @override
  Widget build(BuildContext context) {
    if (!controller.isGoogleAvailable) return const SizedBox.shrink();
    final muted = context.palette.mutedText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: muted),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 20),
        Obx(() {
          final loading = controller.isGoogleLoading.value;
          return OutlinedButton(
            onPressed: loading ? null : controller.continueWithGoogle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const _GoogleMark(size: 20),
                const SizedBox(width: 12),
                const Text('Continue with Google'),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// Google "G", drawn in code (four arcs and the bar).
class _GoogleMark extends StatelessWidget {
  const _GoogleMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Google',
    child: CustomPaint(size: Size.square(size), painter: _GooglePainter()),
  );
}

class _GooglePainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = s * 0.2;
    final rect = Rect.fromCircle(
      center: Offset(s / 2, s / 2),
      radius: (s - stroke) / 2,
    );
    Paint arc(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    double rad(double deg) => deg * math.pi / 180;
    // Angles clockwise from 3 o'clock.
    canvas
      ..drawArc(rect, rad(-40), rad(-95), false, arc(_red))
      ..drawArc(rect, rad(-135), rad(-90), false, arc(_yellow))
      ..drawArc(rect, rad(135), rad(-90), false, arc(_green))
      ..drawArc(rect, rad(45), rad(-45), false, arc(_blue))
      ..drawRect(
        Rect.fromLTWH(s / 2, s / 2 - stroke / 2, s / 2 - stroke / 4, stroke),
        Paint()..color = _blue,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
