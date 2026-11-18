import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/utils/formatters.dart';
import '../view_models/product_list_view_model.dart';

/// Bottom sheet editing [ProductListViewModel.draft]; nothing changes in
/// the list until "Show results".
class ProductFilterSheet extends StatelessWidget {
  const ProductFilterSheet({super.key, required this.vm});

  final ProductListViewModel vm;

  static Future<void> show(ProductListViewModel vm) {
    vm.beginEditing();
    return Get.bottomSheet<void>(
      ProductFilterSheet(vm: vm),
      isScrollControlled: true,
      // GetX does not read the theme's sheet colour.
      backgroundColor: Get.theme.bottomSheetTheme.backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.palette;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Obx(() {
          final draft = vm.draft.value;
          final facets = vm.facets.value;
          final lo = (draft.minPrice ?? facets.minPrice).clamp(
            facets.minPrice,
            facets.maxPrice,
          );
          final hi = (draft.maxPrice ?? facets.maxPrice).clamp(
            lo,
            facets.maxPrice,
          );
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Filters', style: theme.textTheme.titleLarge),
                    ),
                    TextButton(
                      onPressed: draft.hasRefinements ? vm.resetDraft : null,
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  children: [
                    if (facets.hasPriceRange) ...[
                      const _Heading('Price'),
                      Row(
                        children: [
                          Text(Formatters.price(lo)),
                          const Spacer(),
                          Text(Formatters.price(hi)),
                        ],
                      ),
                      RangeSlider(
                        min: facets.minPrice,
                        max: facets.maxPrice,
                        values: RangeValues(lo, hi),
                        labels: RangeLabels(
                          Formatters.price(lo),
                          Formatters.price(hi),
                        ),
                        onChanged: (v) => vm.setDraftPrice(
                          v.start.roundToDouble(),
                          v.end.roundToDouble(),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (facets.sizes.isNotEmpty) ...[
                      const _Heading('Size'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final size in facets.sizes)
                            FilterChip(
                              label: Text(size),
                              selected: draft.sizes.contains(size),
                              onSelected: (_) => vm.toggleDraftSize(size),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    const _Heading('Availability'),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('On sale'),
                      subtitle: Text(
                        'Discounted products only',
                        style: TextStyle(color: palette.mutedText),
                      ),
                      value: draft.onSaleOnly,
                      onChanged: vm.setDraftOnSale,
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('In stock'),
                      subtitle: Text(
                        'Hide sold-out products',
                        style: TextStyle(color: palette.mutedText),
                      ),
                      value: draft.inStockOnly,
                      onChanged: vm.setDraftInStock,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: FilledButton(
                  onPressed: vm.draftCount.value == 0
                      ? null
                      : () {
                          vm.applyDraft();
                          Get.back<void>();
                        },
                  child: Text(
                    vm.draftCount.value == 0
                        ? 'No matching products'
                        : 'Show ${vm.draftCount.value} '
                              '${vm.draftCount.value == 1 ? 'result' : 'results'}',
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}
