import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class OrderItemListItem extends StatelessWidget {
  final OrderItem orderItem;
  final String selectedLanguage;
  final String selectedCurrency;
  const OrderItemListItem({super.key, required this.orderItem, required this.selectedLanguage, required this.selectedCurrency});

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return widgetFactory.createCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppImage(imageUrl: orderItem.image, width: 50, height: 50),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widgetFactory.createText(context, orderItem.name.localize(selectedLanguage), style: Theme.of(context).textTheme.bodyMedium),
                    widgetFactory.createText(context, orderItem.quantity.toString(), style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              widgetFactory.createText(context, orderItem.totalAmountString(currency:  selectedCurrency), style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          if (orderItem.config?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            _buildProductAddonConfig(context, orderItem.config!, widgetFactory),
          ]
        ],
      ),
    );
  }

  Widget _buildProductAddonConfig(BuildContext context, List<OrderConfig> configs, WidgetFactory widgetfactory) {
    return widgetfactory.createCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.all(8),
      child: AppListView(
        shrinkWrap: true,
        items: configs,
        itemBuilder: (context, item, index) {
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    widgetfactory.createText(context, item.name.localize(selectedLanguage), style: Theme.of(context).textTheme.bodyMedium),
                    widgetfactory.createText(context, item.selectedConfigValue(orderItem.product?.addons, selectedLanguage), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              widgetfactory.createText(context, item.getAdditionalPrice(selectedCurrency), style: Theme.of(context).textTheme.titleSmall),
            ],
          );
        },
      ),
    );
  }
}
