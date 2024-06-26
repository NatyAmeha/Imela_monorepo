import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/presentation/resources/values.dart';
import 'package:melegna_customer/presentation/ui/factory/button_style_utils.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';

class ProductCallToActionBottomComponenet extends StatelessWidget {
  final Product product;
  final WidgetFactory widgetFactory;
  final Function? onPressed;
  const ProductCallToActionBottomComponenet({super.key, required this.product, required this.widgetFactory, this.onPressed});

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
              // flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widgetFactory.createText(context, '54000 Birr', style: Theme.of(context).textTheme.headlineMedium),
                  widgetFactory.createText(context, '4 options', style: Theme.of(context).textTheme.bodyMedium, textDecoration: TextDecoration.underline),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              // flex: 3,
              child: widgetFactory.createButton(
                context: context,
                icon: const Icon(Icons.shopping_cart_sharp),
                style: AppButtonStyle.applyBtnStyle(color: Theme.of(context).primaryColor),
                content: Text('${product.callToAction}'),
                onPressed: () {
                  onPressed?.call();
                },
              ),
            )
          ],
        ));
  }
}
