import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../view_models/profile_view_model.dart';

class ProfileView extends GetView<ProfileViewModel> {
  const ProfileView({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
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
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage(AppAssets.avatarPlaceholder),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.displayName,
                            style: theme.textTheme.titleLarge,
                          ),
                          Text(
                            controller.email,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _Section(
              children: [
                ListTile(
                  leading: const Icon(Icons.receipt_long_outlined),
                  title: const Text('My orders'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Get.toNamed(AppRoutes.orders),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Shipping address'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Get.toNamed(AppRoutes.address),
                ),
              ],
            ),
            _Section(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Edit profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: controller.openEditProfile,
                ),
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: const Text('Change password'),
                  subtitle: const Text('We will email you a reset link'),
                  onTap: controller.sendPasswordReset,
                ),
                Obx(
                  () => SwitchListTile(
                    secondary: const Icon(Icons.fingerprint),
                    title: const Text('App lock'),
                    subtitle: const Text('Require biometrics to open the app'),
                    value: controller.isAppLockEnabled.value,
                    onChanged: controller.setAppLock,
                  ),
                ),
              ],
            ),
            _Section(
              children: [
                ListTile(
                  leading: Icon(Icons.logout, color: theme.colorScheme.error),
                  title: Text(
                    'Log out',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () => _confirmSignOut(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    clipBehavior: Clip.antiAlias,
    child: Column(children: children),
  );
}
