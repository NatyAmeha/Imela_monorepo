import 'package:flutter/material.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/components/qty_modifier.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';

class CartListItem extends StatelessWidget {
  final OrderItem cartItem;
  final double width;
  final double? height;
  final double imageWidth;
  final double imageHeight;
  final Function(double qty) onQtyChange;
  final Function() onDelete;
  const CartListItem({
    super.key,
    required this.cartItem,
    this.imageWidth = 60,
    this.imageHeight = 60,
    required this.onQtyChange,
    this.width = double.infinity,
    this.height,
    required this.onDelete,
  });

  String get selectedLanguage => AppViewmodel.getInstance().selectedLanguage;

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
      width: width,
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage(imageUrl: cartItem.image, width: imageWidth, height: imageHeight),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: widgetFactory.createText(context, cartItem.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleSmall)),
                    const SizedBox(width: 4),
                    widgetFactory.createText(context, '${cartItem.getTotalAmount} ', style: Theme.of(context).textTheme.titleMedium).withPaddingSymetric(horizontal: 8),
                  ],
                ),
                const SizedBox(height: 4),
                if (cartItem.config?.isNotEmpty ?? false) getOrderConfigAndAddon(context, cartItem.config!),
                Row(
                  children: [
                    QuantityModifierComponent(
                      currentQty: cartItem.quantity,
                      onQtyChange: onQtyChange,
                      width: 150,
                      widgetFactory: widgetFactory,
                      deductQtyDisabled: false,
                    ),
                    const Spacer(),
                    Wrap(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        widgetFactory.createIcon(
                            materialIcon: Icons.delete,
                            onPressed: () {
                              onDelete();
                            }),
                        widgetFactory.createIcon(materialIcon: Icons.more_vert, onPressed: () {}),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getOrderConfigAndAddon(BuildContext context, List<OrderConfig> orderConfigs) {
    return Column(
      children: orderConfigs
          .map(
            (e) => Text(e.getConfigNameForPOSCart(selectedLanguage) ?? '', style: Theme.of(context).textTheme.labelMedium),
          )
          .toList(),
    );
  }
}
