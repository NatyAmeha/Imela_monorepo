import 'package:flutter/material.dart';
import 'package:imela/domain/product/model/product.model.dart';
import 'package:imela/presentation/resources/values.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/utils/currency_utils.dart';

class ProductCallToActionBottomComponenet extends StatelessWidget {
  final Product product;
  final WidgetFactory widgetFactory;
  final Function? onPressed;
  final String? callToActionText;
  final bool enableCallToActionBtn;
  const ProductCallToActionBottomComponenet({
    super.key,
    required this.product,
    required this.widgetFactory,
    this.callToActionText,
    this.onPressed,
    this.enableCallToActionBtn = true,
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
                  widgetFactory.createText(context, product.getPrice().toSelectedPriceString(), style: Theme.of(context).textTheme.headlineMedium),
                  widgetFactory.createText(context, '4 options', style: Theme.of(context).textTheme.bodyMedium, textDecoration: TextDecoration.underline),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: widgetFactory.createButton(
                context: context,
                icon: const Icon(Icons.shopping_cart_sharp),
                // style: AppButtonStyle.applyBtnStyle),
                content: Text(callToActionText ?? product.getCallToAction()),
                onPressed: enableCallToActionBtn ? () {
                  onPressed?.call();
                } : null
              ),
            )
          ],
        ));
  }
}
