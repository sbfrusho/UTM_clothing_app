import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../view_models/app_lock_view_model.dart';

class AppLockView extends GetView<AppLockViewModel> {
  const AppLockView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Back must not bypass the lock.
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${AppConfig.appName} is locked',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(controller.email, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 32),
                  Obx(
                    () => FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(220, 54),
                      ),
                      onPressed: controller.isAuthenticating.value
                          ? null
                          : controller.unlock,
                      icon: const Icon(Icons.fingerprint),
                      label: Text('Unlock'.tr),
                    ),
                  ),
                  TextButton(
                    onPressed: controller.useAnotherAccount,
                    child: Text('Use another account'.tr),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
