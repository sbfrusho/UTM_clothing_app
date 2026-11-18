import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../view_models/delete_account_view_model.dart';

class DeleteAccountView extends GetView<DeleteAccountViewModel> {
  const DeleteAccountView({super.key});

  static const _deleted = [
    'Your profile, photo and saved addresses',
    'Your cart and saved items',
    'Order notifications on all your devices',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: const AppTopBar(title: 'Delete account'),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              'This permanently deletes @email. It cannot be undone.'.trParams({
                'email': controller.email,
              }),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Text('We delete:'.tr, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            for (final line in _deleted)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.close_rounded, size: 18, color: scheme.error),
                    const SizedBox(width: 8),
                    Expanded(child: Text(line.tr)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'Past orders are kept for our accounting records, without your '
                      'name, phone or address. Orders still in progress must '
                      'be delivered or cancelled first.'
                  .tr,
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.palette.mutedText,
              ),
            ),
            const SizedBox(height: 24),
            if (controller.usesPassword)
              Obx(
                () => TextFormField(
                  controller: controller.passwordController,
                  obscureText: controller.obscurePassword.value,
                  autofillHints: const [AutofillHints.password],
                  validator: controller.validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Password'.tr,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      tooltip: controller.obscurePassword.value
                          ? 'Show password'.tr
                          : 'Hide password'.tr,
                      icon: Icon(
                        controller.obscurePassword.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: controller.toggleObscure,
                    ),
                  ),
                ),
              )
            else
              Text(
                'You will be asked to confirm with Google.'.tr,
                style: theme.textTheme.bodyMedium,
              ),
            const SizedBox(height: 12),
            Obx(
              () => CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: controller.confirmed.value,
                onChanged: controller.toggleConfirmed,
                title: Text(
                  'I understand my account and data will be deleted.'.tr,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                  minimumSize: const Size.fromHeight(52),
                ),
                onPressed: controller.canSubmit ? controller.delete : null,
                child: controller.isDeleting.value
                    ? SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: scheme.onError,
                          semanticsLabel: 'Deleting account'.tr,
                        ),
                      )
                    : Text('Delete my account'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
