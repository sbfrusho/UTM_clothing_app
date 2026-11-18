import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../../../data/models/address_model.dart';
import '../view_models/address_book_view_model.dart';

class AddressBookView extends GetView<AddressBookViewModel> {
  const AddressBookView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        title: controller.isSelecting ? 'Deliver to' : 'Addresses',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.add,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add address'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const ListSkeleton(itemCount: 3);
        if (controller.error.value != null && controller.addresses.isEmpty) {
          return ErrorView(message: controller.error.value!);
        }
        if (controller.addresses.isEmpty) {
          return const EmptyView(
            title: 'No addresses yet',
            message: 'Add one and checkout becomes a single tap.',
            icon: Icons.location_on_outlined,
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
          children: [
            for (final a in controller.addresses) ...[
              _AddressCard(address: a),
              const SizedBox(height: 12),
            ],
          ],
        );
      }),
    );
  }
}

class _AddressCard extends GetView<AddressBookViewModel> {
  const _AddressCard({required this.address});

  final AddressModel address;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: address.isDefault
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: address.isDefault ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => controller.onTap(address),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(switch (address.label) {
                  'Home' => Icons.home_outlined,
                  'Work' => Icons.work_outline_rounded,
                  _ => Icons.location_on_outlined,
                }),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            address.displayLabel,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: palette.accent.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Default',
                              style: theme.textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${address.fullName} · ${address.phone}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.formatted,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'More',
                onSelected: (v) => switch (v) {
                  'edit' => controller.edit(address),
                  'default' => controller.makeDefault(address),
                  'delete' => _confirmDelete(context),
                  _ => null,
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  if (!address.isDefault)
                    const PopupMenuItem(
                      value: 'default',
                      child: Text('Set as default'),
                    ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete address?'),
        content: Text(address.formatted),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok ?? false) await controller.delete(address);
  }
}
