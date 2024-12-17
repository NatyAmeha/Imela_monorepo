import 'package:flutter/material.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class HomeProductListItem extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final double width;
  final double? height;
  final double imageHeight;
  final Product product;
  final Function? onTap;
  final List<String> badgeInfos;
  final String selectedCurrency;
  const HomeProductListItem({
    super.key,
    required this.widgetFactory,
    required this.product,
    this.width = double.infinity,
    this.height,
    this.imageHeight = 100,
    this.onTap,
    this.badgeInfos = const [],
    required this.selectedCurrency,
  });

  String get selectedLanguage => AppViewmodel.getInstance().selectedLanguage;

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Stack(
      children: [
        widgetFactory.createCard(
          onTap: () {
            onTap?.call();
          },
          width: width,
          height: height,
          border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppImage(imageUrl: product.getImageUrl(), height: imageHeight, width: double.infinity),
              const SizedBox(height: 5),
              widgetFactory.createText(context, product.name.localize(selectedLanguage), style: Theme.of(context).textTheme.bodyLarge, maxLines: 2).withPaddingSymetric(horizontal: 10),
              widgetFactory.createText(context, product.getPriceRangeString(selectedCurrency), style: Theme.of(context).textTheme.titleMedium).withPaddingSymetric(horizontal: 10),
              if (product.category != null) widgetFactory.createText(context, product.getProductCategoryString(), style: Theme.of(context).textTheme.bodySmall).withPaddingSymetric(horizontal: 10),
            ],
          ),
        ),
        if (badgeInfos.isNotEmpty) Positioned(top: 0, left: 0, child: getBadgeInfos(context)),
      ],
    );
  }

  Widget getBadgeInfos(BuildContext context) {
    return BadgeList(
      widgetFactory: widgetFactory,
      values: badgeInfos,
      colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
    );
  }
}
