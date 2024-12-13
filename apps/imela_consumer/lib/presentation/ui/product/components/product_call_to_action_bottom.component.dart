import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductCallToActionBottomComponenet extends StatelessWidget {
  final Product product;
  final WidgetFactory widgetFactory;
  final Function? onPressed;
  final String unit;
  final String? callToActionText;
  final bool enableCallToActionBtn;
  final bool isMembershipProduct;
  final List<Discount> discounts;
  const ProductCallToActionBottomComponenet({
    super.key,
    required this.product,
    required this.widgetFactory,
    this.callToActionText,
    this.onPressed,
    this.enableCallToActionBtn = true,
    this.discounts = const [],
    this.isMembershipProduct = false,
    this.unit = 'Unit',
  });

  String get totalPriceWithUnit => '${product.getTotalPriceUpdatedString('ETB', discounts: discounts)}/ $unit';

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMembershipProduct && !enableCallToActionBtn) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetFactory.createIcon(materialIcon: Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                Flexible(child: widgetFactory.createText(context, 'This product is for members only who have a membership plan on the business', style: Theme.of(context).textTheme.bodySmall)),
              ],
            ),
          ],
          if (enableCallToActionBtn)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (discounts.isNotEmpty) ...[
                  Row(
                    children: [
                      widgetFactory.createText(context, product.getTotalPriceUpdatedString('ETB'), style: Theme.of(context).textTheme.bodySmall, textDecoration: TextDecoration.lineThrough),
                      const SizedBox(width: 4),
                      BadgeList(
                        values: [product.getTotalDiscountPercentageApplied('ETB', discounts: discounts)],
                        width: 100,
                        height: 20,
                        colors: [Theme.of(context).colorScheme.tertiary],
                        widgetFactory: widgetFactory,
                      ),
                    ],
                  ),
                ],
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widgetFactory.createText(context, product.getTotalPriceUpdatedString('ETB', discounts: discounts), style: Theme.of(context).textTheme.titleLarge),
                    widgetFactory.createText(context, ' /$unit', style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 8),
          widgetFactory.createButton(
            context: context,
            content: Text(callToActionText ?? product.getCallToAction()),
            onPressed: enableCallToActionBtn
                ? () {
                    onPressed?.call();
                  }
                : null,
          )
        ],
      ),
    );
  }
}
