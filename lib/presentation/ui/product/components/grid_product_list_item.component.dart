import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/domain/shared/gallery.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/app_image.dart';
import 'package:melegna_customer/presentation/utils/currency_utils.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';
import 'package:melegna_customer/presentation/utils/widget_extesions.dart';

class GridProductListItem extends StatelessWidget {
  final Product product;
  final double? imageHeight;
  final double? imageWidth;
  final WidgetFactory widgetFactory;
  final bool showBusiness;
  final bool showMinOrderQty;
  final Function()? onTap;
  const GridProductListItem({
    super.key,
    required this.product,
    required this.widgetFactory,
    this.imageHeight,
    this.imageWidth = double.infinity,
    this.showBusiness = false,
    this.showMinOrderQty = true,
    this.onTap,
  });

  String? get productOptionValue => product.getProductOptionInfo();
  bool get hasProductOption => productOptionValue != null && productOptionValue!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(imageUrl: product.gallery?.getImages().firstOrNull, width: imageWidth, height: imageHeight, borderRadius: BorderRadius.circular(16)), // (1
            const SizedBox(height: 4),
            widgetFactory.createText(context, '${product.getLocalizedProductName(AppLanguage.ENGLISH.name)}', style: Theme.of(context).textTheme.titleSmall, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            widgetFactory.createText(context, product.getPrice().toSelectedPriceString(), style: Theme.of(context).textTheme.bodySmall, textDecoration: TextDecoration.lineThrough),
            widgetFactory.createText(context, product.getPrice().toSelectedPriceString(), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widgetFactory.createIcon(materialIcon: Icons.star, color: ColorManager.tertiary, size: 16),
                const SizedBox(width: 2),
                widgetFactory.createText(context, '4.5 Rating', style: Theme.of(context).textTheme.titleSmall, color: ColorManager.tertiary),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widgetFactory.createIcon(materialIcon: Icons.book, size: 16),
                const SizedBox(width: 4),
                widgetFactory.createText(context, product.getMinOrderQty(), style: Theme.of(context).textTheme.bodySmall),
              ],
            ).showIfTrue(showMinOrderQty),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widgetFactory.createIcon(materialIcon: Icons.keyboard_option_key, size: 16),
                const SizedBox(width: 2),
                widgetFactory.createText(context, productOptionValue ?? '', style: Theme.of(context).textTheme.bodySmall),
              ],
            ).showIfTrue(hasProductOption),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widgetFactory.createIcon(materialIcon: Icons.business, size: 16),
                const SizedBox(width: 4),
                widgetFactory.createText(context, '${product.business?.name.localize()}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ).showIfTrue(showBusiness),
          ],
        ),
        onTap: () {
          onTap?.call();
        });
  }
}
