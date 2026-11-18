import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Whether the device has a network connection. Firestore keeps working
/// from its cache while offline; this only drives the offline banner.
class ConnectivityService extends GetxService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final RxBool isOnline = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  static bool hasNetwork(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  Future<ConnectivityService> init() async {
    try {
      isOnline.value = hasNetwork(await _connectivity.checkConnectivity());
    } catch (_) {
      // Assume online; Firestore reports real failures.
    }
    _sub = _connectivity.onConnectivityChanged.listen(
      (r) => isOnline.value = hasNetwork(r),
      onError: (_) {},
    );
    return this;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
