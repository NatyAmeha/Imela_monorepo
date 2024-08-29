import 'package:flutter/material.dart';
import 'package:imela/domain/business/model/business.model.dart';
import 'package:imela/domain/shared/gallery.model.dart';
import 'package:imela/domain/shared/localized_field.model.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';

class BusinessListTile extends StatelessWidget {
  final Business business;
  final WidgetFactory widgetFactory;
  final double width;
  final double imageHeight;
  final bool showDescription;
  final Function? onTap;

  const BusinessListTile({
    super.key,
    required this.business,
    required this.widgetFactory,
    required this.imageHeight,
    this.width = double.infinity,
    this.showDescription = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      onTap: () {
        onTap?.call();
      },
      width: width,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage(imageUrl: business.gallery?.getImage(featured: true), width: double.infinity, height: imageHeight),
          // widgetFactory.createText(context, business.categories?.join(","), style: Theme.of(context).textTheme.bodySmall).showIf(business.categories?.isNotEmpty == true),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              widgetFactory.createText(context, business.name.localize(), style: Theme.of(context).textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              widgetFactory.createText(context, 'A small description about this card that helps users understand the importance of what makes this so special.', style: Theme.of(context).textTheme.labelSmall, overflow: TextOverflow.ellipsis, maxLines: 2).showIfNotNull(showDescription),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Row(
                  children: [
                    // review icon with average review with divider and then with number of likes
                    widgetFactory.createText(context, '4.5', style: Theme.of(context).textTheme.titleSmall, color: Colors.yellow),
                    const SizedBox(width: 2),
                    widgetFactory.createIcon(materialIcon: Icons.star, color: Colors.yellow, size: 16),
                    const VerticalDivider(color: ColorManager.white),
                    widgetFactory.createText(context, '1000 ', style: Theme.of(context).textTheme.titleSmall, color: ColorManager.white),
                    const SizedBox(width: 2),
                    widgetFactory.createIcon(materialIcon: Icons.favorite, color: ColorManager.white, size: 16),
                  ],
                ),
              )
            ],
          ).withPaddingSymetric(horizontal: 16, vertical: 8),
        ],
      ),
    );
  }
}
