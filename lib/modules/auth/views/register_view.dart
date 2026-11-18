import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/loading_button.dart';
import '../../legal/legal_content.dart';
import '../view_models/register_view_model.dart';
import 'auth_header.dart';
import 'google_sign_in_button.dart';

class RegisterView extends GetView<RegisterViewModel> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Form(
            key: controller.formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Create account',
                    subtitle: 'It only takes a minute.',
                  ),
                  TextFormField(
                    controller: controller.nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: (v) => Validators.required(v, field: 'Name'),
                    decoration: InputDecoration(
                      labelText: 'Full name'.tr,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: Validators.email,
                    decoration: InputDecoration(
                      labelText: 'Email'.tr,
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    validator: Validators.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone'.tr,
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => TextFormField(
                      controller: controller.passwordController,
                      obscureText: controller.obscurePassword.value,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: Validators.password,
                      decoration: InputDecoration(
                        labelText: 'Password'.tr,
                        helperText:
                            'At least 8 characters, with letters and numbers',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: controller.obscurePassword.value
                              ? 'Show password'.tr
                              : 'Hide password'.tr,
                          onPressed: controller.obscurePassword.toggle,
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => TextFormField(
                      controller: controller.confirmController,
                      obscureText: controller.obscurePassword.value,
                      textInputAction: TextInputAction.done,
                      validator: controller.confirmPassword,
                      onFieldSubmitted: (_) => controller.register(),
                      decoration: InputDecoration(
                        labelText: 'Confirm password'.tr,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _LegalNotice(),
                  const SizedBox(height: 16),
                  Obx(
                    () => LoadingButton(
                      label: 'Create account',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.register,
                    ),
                  ),
                  const GoogleSignInSection(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account?'.tr),
                      TextButton(
                        onPressed: () => Get.offNamed<void>(AppRoutes.login),
                        child: Text('Log in'.tr),
                      ),
                    ],
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

/// "By creating an account you agree to the Terms and Privacy policy."
class _LegalNotice extends StatelessWidget {
  const _LegalNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget link(String label, LegalPage page) => InkWell(
      onTap: () => Get.toNamed<void>(AppRoutes.legal, arguments: page),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          label.tr,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(
          'By creating an account you agree to our'.tr,
          style: theme.textTheme.bodySmall,
        ),
        link('Terms of use', LegalPage.terms),
        Text('and'.tr, style: theme.textTheme.bodySmall),
        link('Privacy policy', LegalPage.privacy),
      ],
    );
  }
}
