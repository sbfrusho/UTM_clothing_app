import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/loading_button.dart';
import '../view_models/verify_email_view_model.dart';

class VerifyEmailView extends GetView<VerifyEmailViewModel> {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: palette.accent.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      size: 44,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Verify your email',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'We sent a link to '),
                      TextSpan(
                        text: controller.email,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(
                        text:
                            '. Open it to activate your account. This page '
                            'continues on its own once you have.',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: palette.mutedText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Can't find it? Check your spam folder.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedText,
                  ),
                ),
                const SizedBox(height: 32),
                Obx(
                  () => LoadingButton(
                    label: "I've verified my email",
                    isLoading: controller.isChecking.value,
                    onPressed: controller.check,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final wait = controller.cooldown.value;
                  final busy = controller.isSending.value;
                  return OutlinedButton(
                    onPressed: wait > 0 || busy ? null : controller.resend,
                    child: Text(
                      wait > 0 ? 'Resend email in ${wait}s' : 'Resend email',
                    ),
                  );
                }),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: controller.useAnotherAccount,
                  child: Text('Use a different account'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
