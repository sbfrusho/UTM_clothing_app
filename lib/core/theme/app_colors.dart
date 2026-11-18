import 'package:flutter/material.dart';

/// Raw brand palette: warm greys and creams.
///
/// Widgets should not use these directly; read `Theme.of(context)
/// .colorScheme` or the [AppPalette] extension so light/dark both work.
abstract final class AppColors {
  // Creams
  static const cream50 = Color(0xFFFFFCF7);
  static const cream100 = Color(0xFFF7F2EA);
  static const cream200 = Color(0xFFEFE8DD);
  static const cream300 = Color(0xFFE5DCCE);
  static const sand = Color(0xFFCDBBA0);
  static const sandDeep = Color(0xFFA8916F);

  // Greys (warm)
  static const grey900 = Color(0xFF22201E);
  static const grey800 = Color(0xFF2E2C29);
  static const grey700 = Color(0xFF3D3A36);
  static const grey600 = Color(0xFF56524C);
  static const grey500 = Color(0xFF7A746C);
  static const grey400 = Color(0xFFA39C92);
  static const grey300 = Color(0xFFC9C2B8);

  // Dark surfaces
  static const night900 = Color(0xFF161513);
  static const night800 = Color(0xFF1E1C1A);
  static const night700 = Color(0xFF282623);
  static const night600 = Color(0xFF34312D);
  static const night500 = Color(0xFF45413C);

  // Status (muted to sit with the neutrals)
  static const sage = Color(0xFF5F7F5B);
  static const sageLight = Color(0xFF9DBA97);
  static const ochre = Color(0xFFB3803A);
  static const ochreLight = Color(0xFFD9AE6F);
  static const terracotta = Color(0xFFA6473A);
  static const terracottaLight = Color(0xFFE29A8D);
  static const slate = Color(0xFF4E6A80);
  static const slateLight = Color(0xFF9DB6C9);
}
