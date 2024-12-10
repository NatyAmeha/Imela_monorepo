import 'package:flutter/material.dart';
import 'package:imela_pos/resources/colors.dart';
import 'package:imela_pos/ui/search/search.model.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class SearchResultListItem extends StatelessWidget {
  final SearchModel searchInfo;
  final double imageWidth;
  final double imageHeight;
  final WidgetFactory widgetFactory;
  final Function? onTap;
  const SearchResultListItem({
    super.key,
    required this.searchInfo,
    required this.widgetFactory,
    this.imageWidth = double.infinity,
    this.imageHeight = 100,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
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
                    imageUrl: searchInfo.image,
                    width: imageWidth,
                    height: imageHeight,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  // Positioned(left: 0, bottom: 0, child: ProductItemBadge(badgeInfos: badgeInfos, widgetFactory: widgetFactory)),
                ],
              ), // (1
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  widgetFactory.createText(context, searchInfo.name, style: Theme.of(context).textTheme.labelMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  widgetFactory.createText(context, searchInfo.price.toString(), style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  if (searchInfo.price != null) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widgetFactory.createIcon(materialIcon: Icons.loyalty, color: ColorManager.tertiary, size: 16),
                        const SizedBox(width: 2),
                        widgetFactory.createText(context, searchInfo.price.toString(), style: Theme.of(context).textTheme.labelMedium, color: ColorManager.tertiary),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                ],
              ).withPaddingAll(4)
            ],
          ),
        ],
      ),
      onTap: () {
        onTap?.call();
      },
    );
  }
}
