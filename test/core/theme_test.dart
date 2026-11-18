import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_shop/core/theme/app_theme.dart';

void main() {
  for (final (name, theme) in [
    ('light', AppTheme.light),
    ('dark', AppTheme.dark),
  ]) {
    testWidgets('$name: chip labels contrast with their fill', (t) async {
      await t.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Column(
              children: [
                FilterChip(
                  label: const Text('on'),
                  selected: true,
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text('off'),
                  selected: false,
                  onSelected: (_) {},
                ),
                ActionChip(label: const Text('action'), onPressed: () {}),
              ],
            ),
          ),
        ),
      );
      Color colorOf(String label) =>
          DefaultTextStyle.of(t.element(find.text(label))).style.color!;

      final scheme = theme.colorScheme;
      expect(colorOf('on'), scheme.onPrimary);
      expect(colorOf('off'), scheme.onSurface);
      expect(colorOf('action'), scheme.onSurface);
    });
  }
}
