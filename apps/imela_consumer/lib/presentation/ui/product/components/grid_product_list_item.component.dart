import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/product/components/product_item_badge.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/localization_utils.dart';

class GridProductListItem extends StatelessWidget {
  final Product product;
  final double? imageHeight;
  final double? height;
  final double? imageWidth;
  final WidgetFactory widgetFactory;
  final bool showBusiness;
  final bool showRemainingItem;
  final bool isSelected;
  final List<Discount> discounts;
  final List<ProductBadgeInfo> badgeInfos;
  final bool showDiscountedBanner;
  final Function()? onTap;
  const GridProductListItem({
    super.key,
    required this.product,
    required this.widgetFactory,
    this.imageHeight,
    this.height,
    this.imageWidth = double.infinity,
    this.showBusiness = false,
    this.showRemainingItem = true,
    this.isSelected = false,
    this.discounts = const [],
    this.badgeInfos = const [],
    this.onTap,
    this.showDiscountedBanner = false,
  });

  String? get productOptionValue => product.getProductOptionInfo();
  bool get hasProductOption => productOptionValue != null && productOptionValue!.isNotEmpty;
  String get remainingQtyInfo => '${product.remainingAmount} remaining';
  bool get canShowRemainingQty => showRemainingItem && (product.remainingAmount?.isLowerThan(10) ?? false);

  @override
  Widget build(BuildContext context) {
    Border border = Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer, width: 1);
    return widgetFactory.createCard(
      border: border,
      height: height,
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  AppImage(
                    imageUrl: product.gallery?.getImages().firstOrNull,
                    width: imageWidth,
                    height: imageHeight,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  Positioned(left: 0, bottom: 0, child: ProductItemBadge(badgeInfos: badgeInfos, widgetFactory: widgetFactory)),
                ],
              ), // (1
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  widgetFactory.createText(context, '${product.getLocalizedProductName(AppLanguage.ENGLISH.name)}', style: Theme.of(context).textTheme.labelMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Wrap(
                    children: [
                      if (discounts.isNotEmpty) ...[
                        widgetFactory.createText(context, product.getPriceRangeString('ETB'), style: Theme.of(context).textTheme.bodySmall, textDecoration: TextDecoration.lineThrough),
                      ],
                      if (!showDiscountedBanner && discounts.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        BadgeList(
                          values: [product.getTotalDiscountPercentageApplied('ETB', discounts: discounts)],
                          colors: [Theme.of(context).colorScheme.tertiary],
                          height: 15,
                          width: 20,
                          widgetFactory: widgetFactory,
                        ),
                      ],
                    ],
                  ),
                  widgetFactory.createText(context, product.getPriceRangeString('ETB', discounts: discounts), style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  if (product.loyaltyPoint.isGreaterThan(0)) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widgetFactory.createIcon(materialIcon: Icons.loyalty, color: ColorManager.tertiary, size: 12),
                        const SizedBox(width: 2),
                        widgetFactory.createText(context, product.getLoyaltyPointString("ENGLISH"), style: Theme.of(context).textTheme.labelSmall, color: ColorManager.tertiary),
                      ],
                    ),
                  ],
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widgetFactory.createIcon(materialIcon: Icons.book, size: 16),
                      const SizedBox(width: 4),
                      widgetFactory.createText(context, remainingQtyInfo, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ).showIfTrue(canShowRemainingQty),
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
                      widgetFactory.createText(context, '${product.business?.name?.localize('ENGLISH')}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ).showIfTrue(showBusiness),
                ],
              ).withPaddingSymetric(vertical: 4, horizontal: 6),
            ],
          ),
          if (isSelected) ...[
            Positioned(
              right: 8,
              top: 8,
              child: widgetFactory.createIcon(materialIcon: Icons.check_circle, color: ColorManager.success, size: 30),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: BadgeList(
                values: ['selected'],
                width: 70,
                height: 20,
                colors: [Theme.of(context).colorScheme.primary],
                widgetFactory: widgetFactory,
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        onTap?.call();
      },
    );
  }

  Widget getDiscountedBanner(BuildContext context) {
    return widgetFactory.createCard(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.zero,
      child: widgetFactory.createText(
        context,
        product.getTotalDiscountPercentageApplied('ETB', discounts: discounts),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
