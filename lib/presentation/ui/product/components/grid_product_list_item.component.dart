import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/product/product.model.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/app_image.dart';

class GridProductListItem extends StatelessWidget {
  // final Product product;
  final double? imageHeight;
  final double? imageWidth;
  const GridProductListItem({super.key, this.imageHeight, this.imageWidth = double.infinity});

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return appWidgetFactory.createCard(
        borderRadius: BorderRadius.circular(24),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSDdS1eDQ2LrLx-zbH4RORjPSdSDpzQKlt6tA&s", width: imageWidth, height: imageHeight), // (1
            const SizedBox(height: 4),
            appWidgetFactory.createText(context, "Product name with long description"*2, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis),

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
                appWidgetFactory.createText(context, "Min order - ", style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: 1),
                appWidgetFactory.createText(context, "12 Unit", style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                appWidgetFactory.createIcon(materialIcon: Icons.keyboard_option_key, size: 16),
                const SizedBox(width: 2),
                appWidgetFactory.createText(context, "5 Options", style: Theme.of(context).textTheme.titleSmall),
                
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                appWidgetFactory.createIcon(materialIcon: Icons.business, size: 16),
                const SizedBox(width: 2),
                appWidgetFactory.createText(context, "Business Name", style: Theme.of(context).textTheme.titleSmall),
                
              ],
            ),
          ],
        ));
  }
}
