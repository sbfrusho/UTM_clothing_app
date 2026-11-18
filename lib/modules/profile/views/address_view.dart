import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../core/widgets/state_views.dart';
import '../view_models/address_view_model.dart';

class AddressView extends GetView<AddressViewModel> {
  const AddressView({super.key});

  @override
  Widget build(BuildContext context) {
    Widget field(
      TextEditingController c,
      String label, {
      TextInputType? type,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        textCapitalization: TextCapitalization.words,
        validator: (v) => Validators.required(v, field: label),
        decoration: InputDecoration(labelText: label),
      ),
    );

    return Scaffold(
      appBar: const AppTopBar(title: 'Shipping address'),
      body: Obx(
        () => controller.isLoading.value
            ? const LoadingView()
            : Form(
                key: controller.formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    field(controller.addressController, 'House / building'),
                    field(controller.streetController, 'Street'),
                    field(controller.cityController, 'City'),
                    field(controller.stateController, 'State'),
                    field(
                      controller.postalCodeController,
                      'Postal code',
                      type: TextInputType.number,
                    ),
                    field(controller.countryController, 'Country'),
                    const SizedBox(height: 8),
                    LoadingButton(
                      label: 'Save address',
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
