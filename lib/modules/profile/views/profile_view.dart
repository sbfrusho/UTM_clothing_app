import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../view_models/profile_view_model.dart';

class ProfileView extends GetView<ProfileViewModel> {
  const ProfileView({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can log back in at any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await controller.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Scaffold(
      appBar: const AppTopBar.large(title: 'Profile'),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Obx(
                  () => Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        child: Text(
                          controller.initials,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.displayName,
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(
                              controller.email,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      AppIconButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit profile',
                        onPressed: controller.openEditProfile,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const _Label('Shopping'),
            _Group(
              children: [
                _Tile(
                  icon: Icons.receipt_long_outlined,
                  title: 'My orders',
                  onTap: () => Get.toNamed<void>(AppRoutes.orders),
                ),
                _Tile(
                  icon: Icons.location_on_outlined,
                  title: 'Shipping address',
                  onTap: () => Get.toNamed<void>(AppRoutes.address),
                ),
              ],
            ),
            const _Label('Appearance'),
            Obx(
              () => SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  selectedBackgroundColor: theme.colorScheme.primary,
                  selectedForegroundColor: theme.colorScheme.onPrimary,
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                segments: const [
                  ButtonSegment(value: ThemeMode.system, label: Text('System')),
                  ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ],
                selected: {controller.themeMode.value},
                onSelectionChanged: (s) => controller.setThemeMode(s.first),
              ),
            ),
            const _Label('Security'),
            _Group(
              children: [
                _Tile(
                  icon: Icons.verified_user_outlined,
                  title: 'Signed in with',
                  subtitle: controller.signInMethod,
                  showChevron: false,
                ),
                if (controller.canChangePassword)
                  _Tile(
                    icon: Icons.lock_reset_rounded,
                    title: 'Change password',
                    subtitle: 'We will email you a reset link',
                    onTap: controller.sendPasswordReset,
                    showChevron: false,
                  ),
                Obx(
                  () => SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded),
                    title: const Text('App lock'),
                    subtitle: const Text('Require biometrics to open the app'),
                    value: controller.isAppLockEnabled.value,
                    onChanged: controller.setAppLock,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              onPressed: () => _confirmSignOut(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Your Shop · v1.0.0',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: palette.mutedText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 28, 4, 10),
    child: Text(
      text.toUpperCase(),
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(letterSpacing: 1.4),
    ),
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final divided = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) divided.add(const Divider(indent: 56));
      divided.add(children[i]);
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(children: divided),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.onTap,
    this.subtitle,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: showChevron ? const Icon(Icons.chevron_right_rounded) : null,
    onTap: onTap,
  );
}
