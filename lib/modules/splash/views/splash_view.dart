import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/brand/app_logo.dart';
import '../view_models/splash_view_model.dart';

/// Matches the native splash (same color and mark) so the hand-off is seamless.
class SplashView extends GetView<SplashViewModel> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: AppLogo(size: 112, showWordmark: true, axis: Axis.vertical),
      ),
    );
  }
}
