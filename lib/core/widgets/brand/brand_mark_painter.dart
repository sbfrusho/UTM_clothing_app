import 'package:flutter/rendering.dart';

/// The Your Shop mark: a rounded shopping bag with a "Y" cut into it.
///
/// Drawn on a 100×100 grid so it scales to any size; used both in the app
/// ([AppLogo]) and to generate launcher/splash PNGs
/// (`tool/generate_brand_assets.dart`).
class BrandMarkPainter extends CustomPainter {
  const BrandMarkPainter({required this.bagColor, required this.letterColor});

  final Color bagColor;
  final Color letterColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 100;
    // A fully transparent letter color means "cut the Y out of the bag"
    // (used for monochrome/themed icons).
    final knockout = letterColor.a == 0;
    if (knockout) canvas.saveLayer(Offset.zero & size, Paint());
    canvas
      ..save()
      ..translate(
        (size.width - 100 * scale) / 2,
        (size.height - 100 * scale) / 2,
      )
      ..scale(scale);

    final handle = Paint()
      ..color = bagColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(36, 34)
        ..cubicTo(36, 13, 64, 13, 64, 34),
      handle,
    );

    // Body: slightly tapered bag with soft corners.
    final body = Path()
      ..moveTo(24, 30)
      ..lineTo(76, 30)
      ..quadraticBezierTo(81, 30, 81.6, 35)
      ..lineTo(85.5, 82)
      ..quadraticBezierTo(86, 90, 78, 90)
      ..lineTo(22, 90)
      ..quadraticBezierTo(14, 90, 14.5, 82)
      ..lineTo(18.4, 35)
      ..quadraticBezierTo(19, 30, 24, 30)
      ..close();
    canvas.drawPath(body, Paint()..color = bagColor);

    final letter = Paint()
      ..color = knockout ? const Color(0xFF000000) : letterColor
      ..blendMode = knockout ? BlendMode.clear : BlendMode.srcOver
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawPath(
        Path()
          ..moveTo(38, 46)
          ..lineTo(50, 60)
          ..lineTo(62, 46)
          ..moveTo(50, 60)
          ..lineTo(50, 76),
        letter,
      )
      ..restore();
    if (knockout) canvas.restore();
  }

  @override
  bool shouldRepaint(BrandMarkPainter oldDelegate) =>
      oldDelegate.bagColor != bagColor ||
      oldDelegate.letterColor != letterColor;
}
