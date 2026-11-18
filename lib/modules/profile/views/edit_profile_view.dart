import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../core/widgets/state_views.dart';
import '../view_models/edit_profile_view_model.dart';

class EditProfileView extends GetView<EditProfileViewModel> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Edit profile'),
      body: Obx(
        () => controller.isLoading.value
            ? const LoadingView()
            : Form(
                key: controller.formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      initialValue: controller.email,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: 'Email'.tr,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.nameController,
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => Validators.required(v, field: 'Name'),
                      decoration: InputDecoration(
                        labelText: 'Full name'.tr,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone'.tr,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),
                    LoadingButton(
                      label: 'Save',
                      isLoading: controller.isSaving.value,
                      onPressed: controller.save,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
