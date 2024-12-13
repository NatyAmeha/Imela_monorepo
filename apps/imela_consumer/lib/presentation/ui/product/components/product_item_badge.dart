import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductBadgeInfo {
  final String name;
  final IconData icon;
  final Color color;
  const ProductBadgeInfo({required this.name, required this.icon, this.color = ColorManager.primary});

  static List<ProductBadgeInfo> getProductBadgeInfo(Product product) {
    var badgeInfos = <ProductBadgeInfo>[];
    if (product.isMembershipProduct) {
      badgeInfos.add(const ProductBadgeInfo(name: 'Membership', icon: Icons.card_membership));
    }
    return badgeInfos;
  }
}

class ProductItemBadge extends StatelessWidget {
  final List<ProductBadgeInfo> badgeInfos;
  final WidgetFactory widgetFactory;
  final double width;
  final double height;
  const ProductItemBadge({
    super.key,
    required this.badgeInfos,
    required this.widgetFactory,
    this.width = 200,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AppListView(
        height: height,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        items: badgeInfos,
        itemBuilder: (context, badgeInfo, index) {
          return widgetFactory.createCard(
            color: badgeInfo.color,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            borderRadius: BorderRadius.circular(0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // widgetFactory.createIcon(materialIcon: badgeInfo.icon, size: 24, color: Colors.white),
                widgetFactory.createText(context, badgeInfo.name, style: Theme.of(context).textTheme.bodySmall, color: Colors.white),
              ],
            ),
          );
        },
      ),
    );
  }
}
