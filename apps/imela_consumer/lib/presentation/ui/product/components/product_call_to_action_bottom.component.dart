import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/values.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductCallToActionBottomComponenet extends StatelessWidget {
  final Product product;
  final WidgetFactory widgetFactory;
  final Function? onPressed;
  final String? callToActionText;
  final bool enableCallToActionBtn;
  final List<Discount> discounts;
  const ProductCallToActionBottomComponenet({
    super.key,
    required this.product,
    required this.widgetFactory,
    this.callToActionText,
    this.onPressed,
    this.enableCallToActionBtn = true,
    this.discounts = const [],
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
        borderRadius: BorderRadius.circular(0),
        height: NumberResources.PRODUCT_BOTTOM_NAVIGATION_HEIGHT,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widgetFactory.createText(context, product.getTotalPriceUpdatedString('ETB'), style: Theme.of(context).textTheme.bodyMedium, textDecoration: TextDecoration.lineThrough),
                  widgetFactory.createText(context, product.getTotalPriceUpdatedString('ETB', discounts: discounts), style: Theme.of(context).textTheme.titleMedium),
                ],
              ).showIfTrue(enableCallToActionBtn)
            ),
            const SizedBox(width: 16),
            Expanded(
              child: widgetFactory.createButton(
                  context: context,
                  icon: const Icon(Icons.shopping_cart_sharp),
                  content: Text(callToActionText ?? product.getCallToAction()),
                  onPressed: enableCallToActionBtn
                      ? () {
                          onPressed?.call();
                        }
                      : null),
            )
          ],
        ));
  }
}
