import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/number_utils.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class AddonProductSelectorModal extends StatelessWidget {
  final ProductAddon addon;
  final WidgetFactory widgetFactory;
  final double? height;
  final List<Product> selectedProducts;
  final Function(BuildContext, ProductAddon, Product)? addOrRemoveProductFromAddon;
  final Function(BuildContext)? onFinish;
  final Function(Product)? isSelected;
  final List<Discount> discounts;
  final Map<String, double>? qtyInfo;

  AddonProductSelectorModal({
    super.key,
    required this.addon,
    required this.widgetFactory,
    this.height = 100,
    this.onFinish,
    this.selectedProducts = const [],
    this.discounts = const [],
    this.isSelected,
    this.addOrRemoveProductFromAddon,
    this.qtyInfo,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetFactory.createText(context, addon.name.localize('ENGLISH'), style: Theme.of(context).textTheme.titleMedium),
                widgetFactory.createText(
                  context,
                  '${selectedProducts.length} of ${addon.products?.length} selected',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                AppGridView(
                  shrinkWrap: true,
                  items: addon.products ?? <Product>[],
                  isStaggered: true,
                  itemExtent: 345,
                  crossAxisCount: Responsive.getGridCount(context, itemWidth: 170),
                  itemBuilder: (context, product, index) {
                    final isSelectedResult = isSelected?.call(product);
                    final selectedQty = qtyInfo?[product.id] ?? 1.0;
                    final totalPrice = product.getTotalPriceUpdated("ETB", discounts: discounts, qtyInput: selectedQty);
                    return Stack(
                      children: [
                        GridProductListItem(
                          product: product,
                          imageHeight: 100,
                          height: 250,
                          isSelected: isSelectedResult,
                          widgetFactory: widgetFactory,
                          discounts: discounts,
                          onTap: () {
                            addOrRemoveProductFromAddon?.call(context, addon, product);
                          },
                        ),
                        if (qtyInfo?[product.id] != null && isSelectedResult == true)
                          Positioned(
                            bottom: 32,
                            right: 4,
                            left: 4,
                            child: widgetFactory.createCard(
                              padding: const EdgeInsets.all(4),
                              color: Theme.of(context).colorScheme.surfaceContainerLow,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Qty - ${qtyInfo?[product.id]}', style: Theme.of(context).textTheme.bodySmall),
                                  const SizedBox(height: 2),
                                  Text('Total price - ${totalPrice.getPresision(2)}', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  // height: height,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 124,
            right: 0,
            left: 0,
            child: widgetFactory.createButton(
              context: context,
              content: const Text('Select Product'),
              onPressed: () {
                onFinish?.call(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
