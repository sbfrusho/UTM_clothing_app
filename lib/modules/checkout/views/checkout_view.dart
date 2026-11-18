import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/loading_button.dart';
import '../../../data/models/order_model.dart';
import '../view_models/checkout_view_model.dart';

class CheckoutView extends GetView<CheckoutViewModel> {
  const CheckoutView({super.key});

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          controller.deliveryDate.value ?? now.add(const Duration(days: 3)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) controller.setDeliveryDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const AppTopBar(title: 'Checkout'),
      body: Obx(
        () => Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              if (controller.isLoadingProfile.value)
                const LinearProgressIndicator(),
              Text('Contact', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.nameController,
                textCapitalization: TextCapitalization.words,
                validator: (v) => Validators.required(v, field: 'Name'),
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                validator: Validators.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text('Delivery', style: theme.textTheme.titleMedium),
                  ),
                  TextButton(
                    onPressed: controller.openAddressBook,
                    child: const Text('Saved address'),
                  ),
                ],
              ),
              TextFormField(
                controller: controller.addressController,
                minLines: 2,
                maxLines: 4,
                validator: (v) => Validators.required(v, field: 'Address'),
                decoration: const InputDecoration(
                  labelText: 'Delivery address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<DeliveryType>(
                initialValue: controller.deliveryType.value,
                decoration: const InputDecoration(
                  labelText: 'Delivery type',
                  prefixIcon: Icon(Icons.local_shipping_outlined),
                ),
                items: DeliveryType.values
                    .map(
                      (t) => DropdownMenuItem(value: t, child: Text(t.label)),
                    )
                    .toList(),
                onChanged: (t) {
                  if (t != null) controller.setDeliveryType(t);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                tileColor: theme.colorScheme.surfaceContainerLowest,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Delivery date'),
                subtitle: Text(
                  controller.deliveryDate.value == null
                      ? 'Choose a date'
                      : controller.deliveryDateLabel,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickDate(context),
              ),
              const SizedBox(height: 24),
              Text('Payment', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              RadioGroup<PaymentMethod>(
                groupValue: controller.paymentMethod.value,
                onChanged: (m) {
                  if (m != null) controller.setPaymentMethod(m);
                },
                child: Card(
                  child: Column(
                    children: [
                      const RadioListTile(
                        value: PaymentMethod.cashOnDelivery,
                        secondary: Icon(Icons.payments_outlined),
                        title: Text('Cash on Delivery'),
                      ),
                      RadioListTile(
                        value: PaymentMethod.card,
                        secondary: const Icon(Icons.credit_card),
                        title: const Text('Card'),
                        subtitle: AppConfig.isStripeConfigured
                            ? null
                            : const Text('Test mode: no money is charged'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Summary', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ...controller.cart.availableItems.map(
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${i.quantity} × ${i.name}'
                                  '${i.size.isEmpty ? '' : ' (${i.size})'}',
                                ),
                              ),
                              Text(Formatters.price(i.total)),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Total',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            Formatters.price(controller.cart.total),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Obx(
            () => LoadingButton(
              label: 'Place order · ${Formatters.price(controller.cart.total)}',
              isLoading: controller.isSubmitting.value,
              onPressed: controller.placeOrder,
            ),
          ),
        ),
      ),
    );
  }
}
