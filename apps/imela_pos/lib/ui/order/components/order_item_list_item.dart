import 'package:flutter/material.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class OrderItemListItem extends StatelessWidget {
  final OrderItem orderItem;
  final String selectedCurrency;
  final String selectedLanguage;
  final WidgetFactory widgetFactory;

  const OrderItemListItem({
    super.key,
    required this.orderItem,
    required this.selectedCurrency,
    required this.selectedLanguage,
    required this.widgetFactory,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage(imageUrl: orderItem.image, width: 40, height: 40),
          const SizedBox(width: 16),
          _buildItemInfo(context),
          _buildItemPrice(context),
        ],
      ).withPaddingAll(12),
    );
  }

  Widget _buildItemInfo(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widgetFactory.createText(
            context,
            orderItem.name.localize(selectedLanguage),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          widgetFactory.createText(
            context,
            'Quantity: ${orderItem.quantity}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          widgetFactory.createText(
            context,
            'Options: ${orderItem.getTotalAmountPOS()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildItemPrice(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        widgetFactory.createText(
          context,
          orderItem.getTotalAmountPOS().toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        // widgetFactory.createText(
        //   context,
        //   '${orderItem.priceString(selectedCurrency, selectedLanguage)} each',
        //   style: Theme.of(context).textTheme.bodySmall,
        // ),
      ],
    );
  }
}
