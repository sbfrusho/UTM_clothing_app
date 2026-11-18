import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/loading_button.dart';
import '../view_models/forgot_password_view_model.dart';
import 'auth_header.dart';

class ForgotPasswordView extends GetView<ForgotPasswordViewModel> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const AppTopBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Obx(
            () => controller.emailSent.value
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Check your inbox',
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We sent a password reset link to '
                        '${controller.emailController.text.trim()}.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: context.palette.mutedText,
                        ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: () => Get.back<void>(),
                        child: Text('Back to log in'.tr),
                      ),
                    ],
                  )
                : Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AuthHeader(
                          title: 'Reset password',
                          subtitle:
                              'Enter the email you registered with and '
                              'we will send you a link to choose a new one.',
                        ),
                        TextFormField(
                          controller: controller.emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          onFieldSubmitted: (_) => controller.sendResetLink(),
                          decoration: InputDecoration(
                            labelText: 'Email'.tr,
                            prefixIcon: const Icon(
                              Icons.alternate_email_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        LoadingButton(
                          label: 'Send reset link',
                          isLoading: controller.isLoading.value,
                          onPressed: controller.sendResetLink,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
