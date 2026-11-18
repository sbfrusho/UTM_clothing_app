import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../data/repositories/user_repository.dart';
import '../utils/app_logger.dart';
import '../utils/app_snackbar.dart';

/// Push notifications for order updates (sent by `onOrderWritten` in
/// functions/).
///
/// * Keeps this device's FCM token on the profile (`fcmTokens` for every
///   device, `deviceToken` for the admin app).
/// * Asks for permission only in context: after an order, or from Profile.
/// * Foreground messages show a snackbar; tapping a notification opens the
///   order.
class NotificationService extends GetxService {
  NotificationService({FirebaseMessaging? messaging})
    : _messagingOverride = messaging;

  final FirebaseMessaging? _messagingOverride;
  FirebaseMessaging get _fm => _messagingOverride ?? FirebaseMessaging.instance;

  UserRepository get _users => Get.find<UserRepository>();

  /// Whether the user allowed notifications (null until checked).
  final RxnBool enabled = RxnBool();

  /// Opened from a notification before the app was ready.
  String? _pendingOrderId;
  final _subs = <StreamSubscription<Object?>>[];
  String? _uid;

  Future<NotificationService> init() async {
    try {
      await _refreshPermission();
      _subs
        ..add(FirebaseMessaging.onMessage.listen(_onForeground))
        ..add(FirebaseMessaging.onMessageOpenedApp.listen(_onOpened))
        // Classic registration tokens: what the admin app and the server
        // (sendEachForMulticast) target. Migrate with both.
        // ignore: deprecated_member_use
        ..add(_fm.onTokenRefresh.listen(_saveToken));
      final initial = await _fm.getInitialMessage();
      if (initial != null) _pendingOrderId = _orderIdOf(initial);
    } catch (e, st) {
      // Messaging unavailable (e.g. no Play services): the app still works.
      AppLogger.error('Notifications unavailable', e, st);
    }
    return this;
  }

  @override
  void onClose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.onClose();
  }

  // ----- tokens ---------------------------------------------------------------

  Future<String?> token() async {
    try {
      // See onTokenRefresh above.
      // ignore: deprecated_member_use
      return await _fm.getToken();
    } catch (e, st) {
      AppLogger.error('Could not get FCM token', e, st);
      return null;
    }
  }

  /// Called once a verified user is signed in.
  Future<void> attach(String uid) async {
    _uid = uid;
    final t = await token();
    if (t != null) await _users.addDeviceToken(uid, t);
  }

  /// Called before sign-out, so the device stops receiving their orders.
  Future<void> detach(String uid) async {
    final t = await token();
    if (t != null) await _users.removeDeviceToken(uid, t);
    _uid = null;
  }

  Future<void> _saveToken(String t) async {
    final uid = _uid;
    if (uid != null) await _users.addDeviceToken(uid, t);
  }

  // ----- permission -------------------------------------------------------------

  Future<void> _refreshPermission() async {
    final s = await _fm.getNotificationSettings();
    enabled.value = _allowed(s.authorizationStatus);
  }

  /// Shows the system prompt (Android 13+, iOS). Returns whether allowed.
  /// Once denied, Android won't prompt again; the caller explains how to
  /// turn it on in system settings.
  Future<bool> requestPermission() async {
    try {
      final s = await _fm.requestPermission();
      enabled.value = _allowed(s.authorizationStatus);
      final uid = _uid;
      if (enabled.value! && uid != null) await attach(uid);
    } catch (e, st) {
      AppLogger.error('Notification permission failed', e, st);
    }
    return enabled.value ?? false;
  }

  static bool _allowed(AuthorizationStatus s) =>
      s == AuthorizationStatus.authorized ||
      s == AuthorizationStatus.provisional;

  // ----- messages ---------------------------------------------------------------

  static String? _orderIdOf(RemoteMessage m) {
    final id = m.data['orderId'];
    return id is String && id.isNotEmpty ? id : null;
  }

  void _onForeground(RemoteMessage m) {
    final n = m.notification;
    if (n == null) return;
    final orderId = _orderIdOf(m);
    if (orderId == null) {
      AppSnackbar.info(n.body ?? '', title: n.title ?? 'Your Shop');
      return;
    }
    AppSnackbar.action(
      n.title ?? 'Order update',
      n.body ?? '',
      actionLabel: 'View',
      onAction: () => _openOrder(orderId),
    );
  }

  void _onOpened(RemoteMessage m) {
    final id = _orderIdOf(m);
    if (id != null) _openOrder(id);
  }

  /// The shell calls this once it is on screen.
  void openPendingIfAny() {
    final id = _pendingOrderId;
    _pendingOrderId = null;
    if (id != null) _openOrder(id);
  }

  void _openOrder(String orderId) =>
      Get.toNamed<void>(AppRoutes.orderDetail, arguments: orderId);
}
