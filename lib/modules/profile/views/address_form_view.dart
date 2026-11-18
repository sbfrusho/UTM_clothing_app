import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/loading_button.dart';
import '../view_models/address_form_view_model.dart';

class AddressFormView extends GetView<AddressFormViewModel> {
  const AddressFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget field(
      TextEditingController c,
      String label, {
      TextInputType? type,
      bool required = true,
      String? Function(String?)? validator,
      List<String>? autofill,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        textInputAction: TextInputAction.next,
        autofillHints: autofill,
        textCapitalization: type == null
            ? TextCapitalization.words
            : TextCapitalization.none,
        validator:
            validator ??
            (required ? (v) => Validators.required(v, field: label) : null),
        decoration: InputDecoration(
          labelText: required ? label : '$label (optional)',
        ),
      ),
    );

    return Scaffold(
      appBar: AppTopBar(
        title: controller.isEditing ? 'Edit address' : 'New address',
      ),
      body: Form(
        key: controller.formKey,
        child: AutofillGroup(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Obx(
                () => Wrap(
                  spacing: 8,
                  children: [
                    for (final l in AddressFormViewModel.labels)
                      ChoiceChip(
                        label: Text(l),
                        selected: controller.label.value == l,
                        onSelected: (_) => controller.label.value = l,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Contact', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              field(
                controller.fullName,
                'Full name',
                autofill: const [AutofillHints.name],
              ),
              field(
                controller.phone,
                'Phone',
                type: TextInputType.phone,
                validator: Validators.phone,
                autofill: const [AutofillHints.telephoneNumber],
              ),
              const SizedBox(height: 8),
              Text('Address', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              field(
                controller.address,
                'House, unit or building',
                autofill: const [AutofillHints.streetAddressLine1],
              ),
              field(
                controller.street,
                'Street',
                required: false,
                autofill: const [AutofillHints.streetAddressLine2],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: field(
                      controller.postalCode,
                      'Postcode',
                      type: TextInputType.number,
                      autofill: const [AutofillHints.postalCode],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: field(
                      controller.city,
                      'City',
                      autofill: const [AutofillHints.addressCity],
                    ),
                  ),
                ],
              ),
              field(
                controller.state,
                'State',
                required: false,
                autofill: const [AutofillHints.addressState],
              ),
              field(
                controller.country,
                'Country',
                autofill: const [AutofillHints.countryName],
              ),
              Obx(
                () => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Use as default address'),
                  value: controller.isDefault.value,
                  onChanged: (v) => controller.isDefault.value = v,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => LoadingButton(
                  label: 'Save address',
                  isLoading: controller.isSaving.value,
                  onPressed: controller.save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
