// Renders the app-tour video slides from the screenshots in
// tool/screenshots (run tool/screenshots_test.dart first).
//
//   flutter test tool/app_tour/slides_test.dart --update-goldens
//   sh tool/app_tour/make_video.sh
//
// Uses the app's own fonts and colours, so the video matches the brand.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_shop/core/theme/app_colors.dart';

const _w = 1080.0;
const _h = 1920.0;

/// (screenshot, title, subtitle, dark)
const _slides = <(String, String, String, bool)>[
  (
    '01_welcome',
    'Your Shop',
    'Clothing and merchandise, delivered across Bangladesh.',
    false,
  ),
  (
    '02_login',
    'Sign in your way',
    'Email or Google, with email verification and app lock.',
    false,
  ),
  (
    '03_home',
    'Made for browsing',
    'Categories, sale picks and new arrivals at a glance.',
    false,
  ),
  (
    '04_categories',
    'Every category',
    'Shirts, caps, mugs, corporate wear and more.',
    false,
  ),
  (
    '11_product_list',
    'Filter and sort',
    'By price, size, stock and discount.',
    false,
  ),
  ('12_search', 'Find it fast', 'Ranked search that forgives typos.', false),
  (
    '05_product',
    'Every detail',
    'Gallery, sizes, live stock and prices in Taka.',
    false,
  ),
  (
    '06_cart',
    'A cart that syncs',
    'Saved to your account, checked against live stock.',
    false,
  ),
  (
    '13_checkout',
    'Simple checkout',
    'Cash on delivery or card, with saved addresses.',
    false,
  ),
  (
    '08_orders',
    'Track every order',
    'Live status from placed to delivered, with push updates.',
    false,
  ),
  (
    '14_addresses',
    'Address book',
    'Home, office, anywhere in Bangladesh.',
    false,
  ),
  (
    '07_profile',
    'Your account',
    'Photo, language, privacy and account deletion.',
    false,
  ),
  ('09_home_dark', 'Dark mode', 'Easy on the eyes at night.', true),
  ('10_product_dark', 'Your Shop', 'Get it on Google Play.', true),
];

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      loader.addFont(
        Future.value(ByteData.sublistView(File(f).readAsBytesSync())),
      );
    }
    await loader.load();
  }

  await load('Manrope', [
    'assets/fonts/Manrope-Medium.ttf',
    'assets/fonts/Manrope-Bold.ttf',
  ]);
  await load('PlayfairDisplay', ['assets/fonts/PlayfairDisplay-Bold.ttf']);
}

class _Slide extends StatelessWidget {
  const _Slide({
    required this.shot,
    required this.title,
    required this.subtitle,
    required this.dark,
    required this.index,
    required this.count,
  });

  final ui.Image shot;
  final String title;
  final String subtitle;
  final bool dark;
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? AppColors.night900 : AppColors.cream100;
    final ink = dark ? AppColors.cream100 : AppColors.grey900;
    final muted = dark ? AppColors.grey400 : AppColors.grey500;
    const phoneH = 1360.0;
    final phoneW = phoneH * shot.width / shot.height;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ColoredBox(
        color: bg,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(80, 90, 80, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${'${index + 1}'.padLeft(2, '0')} / $count",
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                  letterSpacing: 4,
                  color: dark ? AppColors.sand : AppColors.sandDeep,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.w700,
                  fontSize: 84,
                  height: 1.05,
                  color: ink,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w500,
                  fontSize: 36,
                  height: 1.3,
                  color: muted,
                ),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: phoneW + 28,
                  height: phoneH + 28,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.night600 : AppColors.grey800,
                    borderRadius: BorderRadius.circular(64),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: RawImage(image: shot, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  setUpAll(_loadFonts);

  for (final (i, (file, title, subtitle, dark)) in _slides.indexed) {
    testWidgets('slide $file', (tester) async {
      tester.view
        ..physicalSize = const Size(_w, _h)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final shot = (await tester.runAsync(() async {
        final bytes = File('tool/screenshots/$file.png').readAsBytesSync();
        final codec = await ui.instantiateImageCodec(bytes);
        return (await codec.getNextFrame()).image;
      }))!;

      await tester.pumpWidget(
        _Slide(
          shot: shot,
          title: title,
          subtitle: subtitle,
          dark: dark,
          index: i,
          count: _slides.length,
        ),
      );
      await expectLater(
        find.byType(_Slide),
        matchesGoldenFile('slides/${'$i'.padLeft(2, '0')}_$file.png'),
      );
    });
  }
}
