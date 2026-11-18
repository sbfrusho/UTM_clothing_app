import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../view_models/legal_view_model.dart';

class LegalView extends GetView<LegalViewModel> {
  const LegalView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doc = controller.document;
    return Scaffold(
      appBar: AppTopBar(
        title: doc.title,
        actions: [
          if (controller.hasOnlineCopy)
            AppIconButton(
              icon: Icons.open_in_new_rounded,
              tooltip: 'Open in browser'.tr,
              onPressed: controller.openOnline,
            ),
        ],
      ),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Text(
              'Last updated @date'.trParams({'date': doc.updated}),
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
            for (final (heading, body) in doc.sections) ...[
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Text(heading, style: theme.textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              Text(body, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}
