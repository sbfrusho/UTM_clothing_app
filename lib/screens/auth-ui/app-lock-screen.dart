import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:your_shop/core/config/app_config.dart';
import 'package:your_shop/core/services/biometric_service.dart';
import 'package:your_shop/screens/auth-ui/welcome-screen.dart';
import 'package:your_shop/screens/user/home-screen.dart';

/// Shown on launch when the user is signed in and has enabled app lock.
class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final BiometricService _biometrics = Get.find<BiometricService>();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await _biometrics.authenticate();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) Get.offAll(() => const HomeScreen());
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll(() => const WelcomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text('${AppConfig.appName} is locked',
                    style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  FirebaseAuth.instance.currentUser?.email ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _busy ? null : _unlock,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock'),
                ),
                TextButton(
                  onPressed: _signOut,
                  child: const Text('Use another account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
