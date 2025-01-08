import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
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
  final Function(BuildContext, ProductAddon, AddonProductOptionInfo)? addOrRemoveProductFromAddon;
  final Function(BuildContext)? onFinish;
  final Function(Product)? isSelected;
  final Map<String, double>? qtyInfo;

  bool get enableSelection => selectedProducts.isNotEmpty && selectedProducts.length <= addon.maxAmount && selectedProducts.length >= addon.minAmount;
  String get productSelectionMessage => 'You should select a minimum of ${addon.minAmount} and maximum of ${addon.maxAmount} items';
  const AddonProductSelectorModal({
    super.key,
    required this.addon,
    required this.widgetFactory,
    this.height = 100,
    this.onFinish,
    this.selectedProducts = const [],
    this.isSelected,
    this.addOrRemoveProductFromAddon,
    this.qtyInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppGridView(
        shrinkWrap: false,
        items: addon.getProductOptionInfos(),
        isStaggered: true,
        itemExtent: 345,
        crossAxisCount: Responsive.getGridCount(context, itemWidth: 170),
        itemBuilder: (context, productOptionInfo, index) {
          final isSelectedResult = isSelected?.call(productOptionInfo.product!);

          final selectedQty = qtyInfo?[productOptionInfo.product!.id!] ?? 1.0;
          final totalPrice = productOptionInfo.product!.getTotalPriceUpdated('ETB', discounts: productOptionInfo.discounts, qtyInput: selectedQty);
          return Stack(
            children: [
              GridProductListItem(
                product: productOptionInfo.product!,
                imageHeight: 100,
                height: 250,
                isSelected: isSelectedResult,
                widgetFactory: widgetFactory,
                discounts: productOptionInfo.discounts,
                onTap: () {
                  addOrRemoveProductFromAddon?.call(context, addon, productOptionInfo);
                },
              ),
              if (qtyInfo?[productOptionInfo.product!.id!] != null && isSelectedResult == true)
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
                        Text('Qty - ${qtyInfo?[productOptionInfo.product!.id!]}', style: Theme.of(context).textTheme.bodySmall),
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
    );
  }
}
