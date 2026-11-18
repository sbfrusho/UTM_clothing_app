import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/loading_button.dart';
import '../view_models/login_view_model.dart';
import 'auth_header.dart';
import 'google_sign_in_button.dart';

class LoginView extends GetView<LoginViewModel> {
  const LoginView({super.key});

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
                    title: 'Welcome back',
                    subtitle: 'Log in to continue shopping.',
                  ),
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
                  const SizedBox(height: 16),
                  Obx(
                    () => TextFormField(
                      controller: controller.passwordController,
                      obscureText: controller.obscurePassword.value,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      validator: (v) =>
                          Validators.required(v, field: 'Password'),
                      onFieldSubmitted: (_) => controller.signIn(),
                      decoration: InputDecoration(
                        labelText: 'Password'.tr,
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.toNamed(
                        AppRoutes.forgotPassword,
                        arguments: controller.emailController.text.trim(),
                      ),
                      child: Text('Forgot password?'.tr),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => LoadingButton(
                      label: 'Log in',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.signIn,
                    ),
                  ),
                  const GoogleSignInSection(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () => Get.offNamed(AppRoutes.register),
                        child: Text('Sign up'.tr),
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
