import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_palette.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel = 'See all',
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 12, 12),
      child: Row(
        crossAxisAlignment: subtitle == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.tr, style: theme.textTheme.headlineSmall),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!.tr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.palette.mutedText,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel.tr)),
        ],
      ),
    );
  }
}
