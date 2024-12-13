import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/product/components/dynamic_price_viewmodel.dart';

import 'package:imela/presentation/ui/shared/qty_modifier.component.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';

class ProductDynamicPricing extends StatefulWidget {
  final double basePrice;
  final Product product;
  final List<Discount> dynamicPricingDiscounts;
  final bool haveDynamicPricing;
  final double width;
  final double? minQty;
  final double? maxQty;
  final Function(double)? onQtyChange;
  final bool showFinishBtn;
  final double? initialQty;
  final String selectedCurrency;
  final Function(BuildContext, double)? onFinish;
  const ProductDynamicPricing({
    super.key,
    required this.product,
    required this.basePrice,
    this.dynamicPricingDiscounts = const [],
    this.haveDynamicPricing = true,
    this.width = double.infinity,
    this.minQty,
    this.maxQty,
    this.onQtyChange,
    this.showFinishBtn = false,
    this.onFinish,
    this.initialQty,
    this.selectedCurrency = 'ETB',
  });

  @override
  State<ProductDynamicPricing> createState() => _ProductDynamicPricingState();
}

class _ProductDynamicPricingState extends State<ProductDynamicPricing> {
  final viewmodel = DynamicPriceViewmodel.getInstance();

  bool get disableQtyDeduction => viewmodel.selectedQty.value <= (widget.minQty ?? widget.product.minimumOrderQty);
  bool get disableQtyAddition => !widget.product.canOrderWithQty(viewmodel.selectedQty.value, minQty: widget.minQty, maxQty: widget.maxQty);

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel(data: {
      'discounts': widget.product.sortedDynamicPricingDiscounts,
      'basePrice': widget.basePrice,
      'product': widget.product,
      'initialQty': widget.initialQty,
      'minQty': widget.product.minimumOrderQty,
    });

    viewmodel.handleScrollonPriceChange();
  }

  String get uom => widget.product.inventory?.firstOrNull?.unit ?? 'Quantity';

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
              if (widget.dynamicPricingDiscounts.isNotEmpty) ...[
                Obx(
                  () => AppListView(
                    height: 60,
                    shrinkWrap: true,
                    primary: false,
                    scrollController: viewmodel.scrollController,
                    scrollDirection: Axis.horizontal,
                    items: viewmodel.discountsWithPrice.value.entries.toList(),
                    contentPadding: const EdgeInsets.only(right: 8),
                    itemBuilder: (context, discount, index) {
                      final priceString = '${widget.selectedCurrency} ${discount.key} / ${widget.product.getDefaultUOM()}';
                      final qtyConditionString = '>=${discount.value?.conditionValue} ${widget.product.getDefaultUOM()}';
                      return Obx(
                        () => widgetFactory.createCard(
                          padding: const EdgeInsets.all(4),
                          border: Border.all(color: viewmodel.selectedPrice.value == discount.key ? Colors.red : Colors.black),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (discount.value != null) widgetFactory.createText(context, '${qtyConditionString}') else widgetFactory.createText(context, 'Starting price'),
                                  widgetFactory.createText(context, priceString, style: Theme.of(context).textTheme.bodyLarge),
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
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: widget.width,
                child: Row(
                  children: [
                    widgetFactory.createText(context, uom, style: Theme.of(context).textTheme.bodyLarge),
                    const Spacer(),
                    Obx(
                      () => Expanded(
                        child: QuantityModifierComponent(
                            currentQty: viewmodel.selectedQty.value,
                            deductQtyDisabled: disableQtyDeduction,
                            addQtyDisabled: disableQtyAddition,
                            onQtyChange: (qty) {
                              viewmodel.updateSelectedQty(qty);
                              widget.onQtyChange?.call(viewmodel.selectedQty.value);
                            },
                            widgetFactory: widgetFactory),
                      ),
                    )
                  ],
                ),
              ),
              if (widget.showFinishBtn)
                widgetFactory.createButton(
                  context: context,
                  content: Text("Finish"),
                  onPressed: () {
                    widget.onFinish?.call(context, viewmodel.selectedQty.value);
                  },
                )
            ],
          ),
        ),
      ],
    );
  }
}
