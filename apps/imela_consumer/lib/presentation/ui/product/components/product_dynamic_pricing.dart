import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/product/components/dynamic_price_viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela/presentation/ui/shared/qty_modifier.component.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';

class ProductDynamicPricing extends StatefulWidget {
  final double basePrice;
  final Product product;
  final List<Discount> dynamicPricingDiscounts;
  final bool haveDynamicPricing;
  final double width;
  const ProductDynamicPricing({
    super.key,
    required this.product,
    required this.basePrice,
    this.dynamicPricingDiscounts = const [],
    this.haveDynamicPricing = true,
    this.width = double.infinity,
  });

  @override
  State<ProductDynamicPricing> createState() => _ProductDynamicPricingState();
}

class _ProductDynamicPricingState extends State<ProductDynamicPricing> {
  final viewmodel = DynamicPriceViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel(data: {'discounts': widget.dynamicPricingDiscounts, 'basePrice': widget.basePrice, 'product': widget.product});
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return Column(
      children: [
        widgetFactory.createCard(
          padding: const EdgeInsets.all(10),
          border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
          child: Column(
            children: [
              Obx(
                () => AppListView(
                  height: 60,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  items: viewmodel.discountsWithPrice.value.entries.toList(),
                  contentPadding: const EdgeInsets.only(right: 8),
                  itemBuilder: (context, discount, index) {
                    return Obx(
                      () => widgetFactory.createCard(
                        width: 120,
                        padding: const EdgeInsets.all(4),
                        border: Border.all(color: viewmodel.selectedPrice.value == discount.key ? Colors.red : Colors.black),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (discount.value != null) widgetFactory.createText(context, '> ${discount.value!.conditionValue}') else widgetFactory.createText(context, 'Starting price'),
                                widgetFactory.createText(context, '\$${discount.key}', style: Theme.of(context).textTheme.bodyLarge),
                              ],
                            ),
                            if (discount.value != null) Positioned(top: 0, right: 0, child: Text('${discount.value?.value}'))
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: widget.width,
                child: Row(
                  children: [
                    widgetFactory.createText(context, 'Quantity', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    Obx(
                      () => Expanded(
                        child: QuantityModifierComponent( 
                            currentQty: viewmodel.selectedQty.value,
                            deductQtyDisabled: !widget.product.canOrderWithQty(viewmodel.selectedQty.value),
                            addQtyDisabled: !widget.product.canOrderWithQty(viewmodel.selectedQty.value),
                            onQtyChange: (qty) {
                              viewmodel.updateSelectedQty(qty);
                            },
                            widgetFactory: widgetFactory),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
