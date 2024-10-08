import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import '../../../resources/colors.dart';
import '../../shared/app_image.dart';
import '../../../utils/widget_extesions.dart';

class VerticalProductListItem extends StatelessWidget {
  final Product product;
  final double? imageHeight;
  final double? imageWidth;
  final WidgetFactory widgetFactory;
  final bool showBusiness;
  final bool showRemainingQty;
  final Function()? onTap;
  const VerticalProductListItem({
    super.key,
    required this.product,
    required this.widgetFactory,
    this.imageHeight,
    this.imageWidth = double.infinity,
    this.showBusiness = false,
    this.showRemainingQty = true,
    this.onTap,
  });

  String? get productOptionValue => product.getProductOptionInfo();

  bool get isProductOptionAvailable => productOptionValue != null && productOptionValue!.isNotEmpty;
  String get remainingQtyInfo => '${product.remainingAmount} remaining';
  bool get canShowRemainingQty => showRemainingQty &&  (product.remainingAmount?.isLowerThan(10) ?? false);

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      onTap: (){
        onTap?.call();
      },
      child: Row(
        children: [
          AppImage(imageUrl: product.gallery?.getImages().firstOrNull, width: imageWidth, height: imageHeight, borderRadius: BorderRadius.circular(16)), // (1
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetFactory.createText(context, product.name?.localize('ENGLISH') ?? '', style: Theme.of(context).textTheme.titleSmall, maxLines: 3, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                widgetFactory.createText(context, product.getPrice().toSelectedPriceString('ETB'), style: Theme.of(context).textTheme.bodySmall, textDecoration: TextDecoration.lineThrough),
                widgetFactory.createText(context, product.getPrice().toSelectedPriceString('ETB') , style: Theme.of(context).textTheme.titleMedium),
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
                    widgetFactory.createText(context, remainingQtyInfo, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ).showIfTrue(canShowRemainingQty),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widgetFactory.createIcon(materialIcon: Icons.keyboard_option_key, size: 16),
                    const SizedBox(width: 2),
                    widgetFactory.createText(context, productOptionValue!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ).showIfTrue(isProductOptionAvailable),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widgetFactory.createIcon(materialIcon: Icons.business, size: 16),
                    const SizedBox(width: 2),
                    widgetFactory.createText(context, '${product.business?.name.localize('ENGLISH')}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ).showIfTrue(showBusiness),
              ],
            ),
          )
        ],
      ),
    );
  }
}
