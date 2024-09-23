import 'package:flutter/material.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';

class ProductListItem extends StatelessWidget {
  final Product product;
  final Function onTap;
  final double width;
  final double? height;
  const ProductListItem({
    super.key,
    required this.product,
    required this.onTap,
    this.width = double.infinity,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
        child: Row(
      children: [
        AppImage(imageUrl: product.getImageUrl(), width: 60, height: 60, borderRadius: BorderRadius.circular(12)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name.localize(AppViewmodel.getInstance().selectedLanguage), style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: widgetFactory.createText(context, product.getProductOptionInfo() ??'product options', style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: widgetFactory.createText(context, product.totalPrice.toString(), style: Theme.of(context).textTheme.bodyLarge),
        ),
        Expanded(
          child: widgetFactory.createText(context, product.activeString(), style: Theme.of(context).textTheme.bodyLarge),
        )
      ],
    ));
  }
}
