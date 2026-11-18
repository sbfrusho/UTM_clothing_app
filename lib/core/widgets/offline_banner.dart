import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/connectivity_service.dart';

/// Thin strip at the bottom of every screen while the device is offline.
/// Cached pages keep working; actions that need the server will say so.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ConnectivityService>()) {
      return const SizedBox.shrink();
    }
    final online = Get.find<ConnectivityService>().isOnline;
    final scheme = Theme.of(context).colorScheme;
    return Obx(
      () => AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: online.value
            ? const SizedBox(width: double.infinity)
            : Semantics(
                liveRegion: true,
                child: Material(
                  color: scheme.inverseSurface,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 16,
                            color: scheme.onInverseSurface,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'You are offline. Showing saved data.'.tr,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: scheme.onInverseSurface),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
