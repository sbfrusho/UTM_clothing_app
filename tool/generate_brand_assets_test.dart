// Renders the brand mark to the PNGs used for launcher icons and the native
// splash. Run after changing BrandMarkPainter or the brand colors:
//
//   flutter test tool/generate_brand_assets_test.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_shop/core/theme/app_colors.dart';
import 'package:your_shop/core/widgets/brand/brand_mark_painter.dart';

const _out = 'assets/branding';

Future<void> _render(
  String name, {
  required int size,
  required double markFraction,
  required Color bag,
  required Color letter,
  Color? background,
  bool circle = false,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final full = Size(size.toDouble(), size.toDouble());
  if (background != null) {
    final paint = Paint()..color = background;
    if (circle) {
      canvas.drawCircle(full.center(Offset.zero), size / 2, paint);
    } else {
      canvas.drawRect(Offset.zero & full, paint);
    }
  }
  final markSize = size * markFraction;
  canvas.translate((size - markSize) / 2, (size - markSize) / 2);
  BrandMarkPainter(
    bagColor: bag,
    letterColor: letter,
  ).paint(canvas, Size.square(markSize));

  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File('$_out/$name').writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('generate brand assets', () async {
    Directory(_out).createSync(recursive: true);

    // Legacy/iOS launcher icon: cream square, dark mark (iOS masks corners).
    await _render(
      'app_icon.png',
      size: 1024,
      markFraction: 0.62,
      bag: AppColors.grey800,
      letter: AppColors.cream100,
      background: AppColors.cream100,
    );

    // Android adaptive foreground: mark inside the 66% safe zone (56% wide).
    await _render(
      'app_icon_foreground.png',
      size: 1024,
      markFraction: 0.56,
      bag: AppColors.grey800,
      letter: AppColors.cream100,
    );

    // Android 13+ themed (monochrome) icon.
    await _render(
      'app_icon_monochrome.png',
      size: 1024,
      markFraction: 0.56,
      bag: const Color(0xFF000000),
      letter: const Color(0x00000000),
    );

    // Play Store listing icon (512, full bleed).
    await _render(
      'play_store_icon.png',
      size: 512,
      markFraction: 0.62,
      bag: AppColors.grey800,
      letter: AppColors.cream100,
      background: AppColors.cream100,
    );

    // Native splash (pre-Android 12 and iOS), light and dark.
    await _render(
      'splash_logo.png',
      size: 768,
      markFraction: 0.5,
      bag: AppColors.grey800,
      letter: AppColors.cream100,
    );
    await _render(
      'splash_logo_dark.png',
      size: 768,
      markFraction: 0.5,
      bag: AppColors.cream200,
      letter: AppColors.night900,
    );

    // Android 12+ splash icon (960, content within the 640 circle).
    await _render(
      'splash_android12.png',
      size: 960,
      markFraction: 0.5,
      bag: AppColors.grey800,
      letter: AppColors.cream100,
    );
    await _render(
      'splash_android12_dark.png',
      size: 960,
      markFraction: 0.5,
      bag: AppColors.cream200,
      letter: AppColors.night900,
    );
  });
}
