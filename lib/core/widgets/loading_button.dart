import 'package:flutter/material.dart';

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
    final child = isLoading
        ? const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Text(label);
    final callback = isLoading ? null : onPressed;
    return icon == null || isLoading
        ? FilledButton(onPressed: callback, child: child)
        : FilledButton.icon(
            onPressed: callback,
            icon: Icon(icon),
            label: child,
          );
  }
}
