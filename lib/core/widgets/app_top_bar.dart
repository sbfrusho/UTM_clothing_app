import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_palette.dart';
import '../theme/app_theme.dart';

/// Flat, page-colored top bar.
///
/// * [AppTopBar.large]: main tabs, serif headline with an optional subtitle.
/// * default: pushed pages, soft square back button and compact title.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions = const [],
    this.showBack = true,
    this.bottom,
  }) : large = false,
       subtitle = null;

  const AppTopBar.large({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  }) : large = true,
       titleWidget = null,
       showBack = false,
       bottom = null;

  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final List<Widget> actions;
  final bool showBack;
  final bool large;
  final PreferredSizeWidget? bottom;

  double get _toolbarHeight => large ? (subtitle == null ? 76 : 88) : 64;

  @override
  Size get preferredSize =>
      Size.fromHeight(_toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = showBack && (ModalRoute.of(context)?.canPop ?? false);

    final Widget? titleChild =
        titleWidget ??
        (large
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title ?? '', style: theme.textTheme.headlineMedium),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: context.palette.mutedText,
                        ),
                      ),
                    ),
                ],
              )
            : (title == null ? null : Text(title!)));

    return AppBar(
      toolbarHeight: _toolbarHeight,
      automaticallyImplyLeading: false,
      titleSpacing: canPop ? 8 : 20,
      leadingWidth: canPop ? 64 : 0,
      leading: canPop
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: AppIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () => Get.back<void>(),
                ),
              ),
            )
          : null,
      title: titleChild,
      actions: [...actions, const SizedBox(width: 12)],
      bottom: bottom,
    );
  }
}

/// Soft square icon button used in top bars and over images.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.selected = false,
    this.size = 44,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool selected;
  final double size;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final button = Material(
      color: selected ? scheme.primary : scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox.square(
          dimension: size,
          child: Icon(
            icon,
            size: size * 0.45,
            color: selected ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
    final withBadge = badgeCount > 0
        ? Badge(
            label: Text('$badgeCount'),
            offset: const Offset(-2, 2),
            child: button,
          )
        : button;
    return tooltip == null
        ? withBadge
        : Tooltip(message: tooltip, child: withBadge);
  }
}
