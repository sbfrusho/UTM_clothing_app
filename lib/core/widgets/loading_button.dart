import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Filled button that shows a spinner and disables itself while [isLoading].
class LoadingButton extends StatelessWidget {
  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: isLoading
          ? SizedBox.square(
              key: const ValueKey('spinner'),
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: scheme.onPrimary,
              ),
            )
          : Text(label.tr, key: const ValueKey('label')),
    );
    final callback = isLoading ? null : onPressed;
    final style = FilledButton.styleFrom(
      disabledBackgroundColor: isLoading ? scheme.primary : null,
    );
    return icon == null || isLoading
        ? FilledButton(onPressed: callback, style: style, child: child)
        : FilledButton.icon(
            onPressed: callback,
            style: style,
            icon: Icon(icon),
            label: child,
          );
  }
}
