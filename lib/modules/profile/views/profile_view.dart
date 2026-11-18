import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../legal/legal_content.dart';
import '../view_models/profile_view_model.dart';

class ProfileView extends GetView<ProfileViewModel> {
  const ProfileView({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log out?'.tr),
        content: Text('You can log back in at any time.'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'.tr),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(100, 44)),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Log out'.tr),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await controller.signOut();
  }

  Future<void> _photoOptions(BuildContext context) async {
    final choice = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text('Take a photo'.tr),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('Choose from gallery'.tr),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (controller.hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: Text('Remove photo'.tr),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice is ImageSource) {
      await controller.pickPhoto(choice);
    } else if (choice == 'remove') {
      await controller.removePhoto();
    }
  }

  static const _languages = <(String?, String)>[
    (null, 'Phone language'),
    ('en', 'English'),
    ('ms', 'Bahasa Melayu'),
  ];

  static String _languageLabel(String? code) => _languages
      .firstWhere((l) => l.$1 == code, orElse: () => _languages[0])
      .$2;

  Future<void> _chooseLanguage(BuildContext context) async {
    final current = controller.languageCode;
    final picked = await showDialog<(String?,)>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Language'.tr),
        children: [
          RadioGroup<String?>(
            groupValue: current,
            onChanged: (code) => Navigator.pop(context, (code,)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (code, label) in _languages)
                  RadioListTile<String?>(
                    value: code,
                    title: Text(code == null ? label.tr : label),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked != null && picked.$1 != current) {
      await controller.setLanguage(picked.$1);
    }
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
                      _Avatar(
                        initials: controller.initials,
                        photoUrl: controller.photoUrl,
                        busy: controller.isUploadingPhoto.value,
                        onTap: () => _photoOptions(context),
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
                        tooltip: 'Edit profile'.tr,
                        onPressed: controller.openEditProfile,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _Label('Shopping'.tr),
            _Group(
              children: [
                _Tile(
                  icon: Icons.receipt_long_outlined,
                  title: 'My orders'.tr,
                  onTap: () => Get.toNamed<void>(AppRoutes.orders),
                ),
                _Tile(
                  icon: Icons.location_on_outlined,
                  title: 'Addresses'.tr,
                  onTap: () => Get.toNamed<void>(AppRoutes.address),
                ),
              ],
            ),
            _Label('Appearance'.tr),
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
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'.tr),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'.tr),
                  ),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark'.tr)),
                ],
                selected: {controller.themeMode.value},
                onSelectionChanged: (s) => controller.setThemeMode(s.first),
              ),
            ),
            const SizedBox(height: 12),
            _Group(
              children: [
                // Changing language rebuilds the whole app, so no Obx.
                _Tile(
                  icon: Icons.translate_rounded,
                  title: 'Language'.tr,
                  subtitle: _languageLabel(controller.languageCode).tr,
                  onTap: () => _chooseLanguage(context),
                ),
              ],
            ),
            _Label('Security'.tr),
            _Group(
              children: [
                _Tile(
                  icon: Icons.verified_user_outlined,
                  title: 'Signed in with'.tr,
                  subtitle: controller.signInMethod.tr,
                  showChevron: false,
                ),
                if (controller.canChangePassword)
                  _Tile(
                    icon: Icons.lock_reset_rounded,
                    title: 'Change password'.tr,
                    subtitle: 'We will email you a reset link'.tr,
                    onTap: controller.sendPasswordReset,
                    showChevron: false,
                  ),
                Obx(
                  () => SwitchListTile(
                    secondary: const Icon(Icons.notifications_none_rounded),
                    title: Text('Order updates'.tr),
                    subtitle: Text('Shipped, delivered and more'.tr),
                    value: controller.notificationsOn,
                    onChanged: controller.setNotifications,
                  ),
                ),
                Obx(
                  () => SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded),
                    title: Text('App lock'.tr),
                    subtitle: Text('Require biometrics to open the app'.tr),
                    value: controller.isAppLockEnabled.value,
                    onChanged: controller.setAppLock,
                  ),
                ),
              ],
            ),
            _Label('About'.tr),
            _Group(
              children: [
                _Tile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy policy'.tr,
                  onTap: () => controller.openLegal(LegalPage.privacy),
                ),
                _Tile(
                  icon: Icons.description_outlined,
                  title: 'Terms of use'.tr,
                  onTap: () => controller.openLegal(LegalPage.terms),
                ),
                _Tile(
                  icon: Icons.person_remove_outlined,
                  title: 'Delete account'.tr,
                  onTap: controller.openDeleteAccount,
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
              label: Text('Log out'.tr),
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

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.initials,
    required this.photoUrl,
    required this.busy,
    required this.onTap,
  });

  final String initials;
  final String photoUrl;
  final bool busy;
  final VoidCallback onTap;

  static const _size = 60.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Change profile photo'.tr,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: busy ? null : onTap,
        child: SizedBox.square(
          dimension: _size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: photoUrl.isEmpty
                    ? Container(
                        color: scheme.primary,
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: scheme.onPrimary),
                        ),
                      )
                    : AppNetworkImage(photoUrl, width: _size, height: _size),
              ),
              if (busy)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x66000000),
                    child: Center(
                      child: SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    size: 14,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
