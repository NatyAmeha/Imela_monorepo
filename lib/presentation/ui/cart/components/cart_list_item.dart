import 'package:flutter/material.dart';
import 'package:imela/domain/order/model/cart.model.dart';
import 'package:imela/domain/shared/localized_field.model.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';

class CartListItem extends StatelessWidget {
  final Cart cartInfo;
  final double width;
  final double? height;
  final WidgetFactory widgetFactory;
  final Function onclick;
  const CartListItem({
    super.key,
    required this.cartInfo,
    required this.widgetFactory,
    required this.onclick,
    this.width = double.infinity,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      width: width,
      height: height,
      onTap: () {
        onclick();
      },
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: ColorManager.primaryBackground, width: 1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widgetFactory.createText(context, cartInfo.name.localize(), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              widgetFactory.createText(context, cartInfo.getTotalItems(), style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          widgetFactory.createIcon(materialIcon: Icons.arrow_forward_ios),
        ],
      ),
    );
  }
}
