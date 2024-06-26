import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/product/model/product_addon.model.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/product/components/product_addon_list_item.dart';

class ProductAddonModal extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final double width;
  final double height;
  final List<ProductAddon> addons;
  const ProductAddonModal({super.key, required this.widgetFactory, required this.addons, this.width = double.infinity, this.height = 500});

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      width: width,
      height: height,
      child: ListView.builder(
        itemCount: addons.length,
        itemBuilder: (context, index) {
          return ProductAddonListItem(addon: addons[index], widgetFactory: widgetFactory);
        },
      ),
    );
  }
}
