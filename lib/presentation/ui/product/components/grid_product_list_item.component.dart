import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/product/product.model.dart';
import 'package:melegna_customer/domain/shared/gallery.model.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/app_image.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';

class GridProductListItem extends StatelessWidget {
  final Product product;
  final double? imageHeight;
  final double? imageWidth;
  const GridProductListItem({super.key, required this.product, this.imageHeight, this.imageWidth = double.infinity});

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return appWidgetFactory.createCard(
        border:  Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(imageUrl: product.gallery?.getImages().firstOrNull, width: imageWidth, height: imageHeight, borderRadius: BorderRadius.circular(16)), // (1
            const SizedBox(height: 4),
            appWidgetFactory.createText(context, '${product.getLocalizedProductName(AppLanguage.ENGLISH.name)}', style: Theme.of(context).textTheme.titleMedium, maxLines: 3, overflow: TextOverflow.ellipsis),

            const SizedBox(height: 4),
            appWidgetFactory.createText(context, "5400 Birr", style: Theme.of(context).textTheme.bodySmall,textDecoration: TextDecoration.lineThrough),
            appWidgetFactory.createText(context, "5000 Birr", style: Theme.of(context).textTheme.titleMedium, color: Theme.of(context).primaryColor),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                appWidgetFactory.createIcon(materialIcon: Icons.star, color: ColorManager.tertiary, size: 16),
                const SizedBox(width: 2),
                appWidgetFactory.createText(context, "4.5 Rating", style: Theme.of(context).textTheme.titleSmall, color: ColorManager.tertiary),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                appWidgetFactory.createIcon(materialIcon: Icons.book, size: 16),
                const SizedBox(width: 2),
                appWidgetFactory.createText(context, "Min order - ", style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 1),
                appWidgetFactory.createText(context, "12 Unit", style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                appWidgetFactory.createIcon(materialIcon: Icons.keyboard_option_key, size: 16),
                const SizedBox(width: 2),
                appWidgetFactory.createText(context, "5 Options", style: Theme.of(context).textTheme.bodySmall),
                
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                appWidgetFactory.createIcon(materialIcon: Icons.business, size: 16),
                const SizedBox(width: 2),
                appWidgetFactory.createText(context, "Business Name", style: Theme.of(context).textTheme.bodySmall),
                
              ],
            ),
          ],
        ));
  }
}
