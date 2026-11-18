import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
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
    final palette = context.palette;
    return Scaffold(
      appBar: const AppTopBar(title: 'Checkout'),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const _Heading('Deliver to'),
            const _AddressSection(),
            const SizedBox(height: 24),
            const _Heading('Delivery'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in DeliveryType.values)
                  ChoiceChip(
                    label: Text(t.label),
                    selected: controller.deliveryType.value == t,
                    onSelected: (_) => controller.setDeliveryType(t),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _Tile(
              icon: Icons.calendar_today_outlined,
              title: 'Delivery date',
              subtitle: controller.deliveryDate.value == null
                  ? 'Choose a date'
                  : controller.deliveryDateLabel,
              onTap: () => _pickDate(context),
            ),
            const SizedBox(height: 24),
            const _Heading('Payment'),
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
                      subtitle: Text('Pay the courier when it arrives'),
                    ),
                    RadioListTile(
                      value: PaymentMethod.card,
                      secondary: const Icon(Icons.credit_card),
                      title: const Text('Card'),
                      subtitle: Text(
                        controller.isTestPayments
                            ? 'Test mode: no money is charged'
                            : 'Visa, Mastercard, Google Pay',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _Heading('Summary'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (final i in controller.cart.availableItems)
                      Padding(
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
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (controller.paymentMethod.value == PaymentMethod.card) ...[
              const SizedBox(height: 12),
              Text(
                'Your order is reserved first, then you pay. If payment '
                "doesn't go through, you can retry from the order page "
                'within ${OrderModel.paymentWindow.inMinutes} minutes.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedText,
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Obx(
            () => LoadingButton(
              label: controller.isSubmitting.value
                  ? controller.stage.value
                  : controller.paymentMethod.value == PaymentMethod.card
                  ? 'Pay ${Formatters.price(controller.cart.total)}'
                  : 'Place order · ${Formatters.price(controller.cart.total)}',
              isLoading: controller.isSubmitting.value,
              onPressed: controller.placeOrder,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressSection extends GetView<CheckoutViewModel> {
  const _AddressSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      if (controller.isLoadingAddress.value) {
        return const LinearProgressIndicator();
      }
      final a = controller.address.value;
      if (a == null) {
        return OutlinedButton.icon(
          onPressed: controller.addAddress,
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('Add a delivery address'),
        );
      }
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: controller.chooseAddress,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${a.fullName} · ${a.phone}',
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(a.formatted, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: controller.chooseAddress,
                  child: const Text('Change'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Own Material: a ListTile's tileColor is otherwise painted on an
    // ancestor and drifts out of place during route transitions.
    return Material(
      color: scheme.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
