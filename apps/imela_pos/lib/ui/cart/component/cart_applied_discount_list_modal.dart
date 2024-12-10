import 'package:flutter/material.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class CartAppliedDiscountListModal extends StatelessWidget {
  final OrderItem item;
  final WidgetFactory widgetFactory;
  final Function(ItemDiscount)? onDelete;
  final String selectedLanguage;
  final String selectedCurrency;
  const CartAppliedDiscountListModal({
    super.key,
    required this.item,
    required this.widgetFactory,
    required this.selectedLanguage,
    required this.selectedCurrency,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widgetFactory.createText(context, 'Price breakdown', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Subtotal', style: Theme.of(context).textTheme.bodyMedium),
              widgetFactory.createText(context, item.subtotalAmountString(selectedCurrency), style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          if (item.discount?.isNotEmpty == true) ...[
            widgetFactory.createText(context, 'Discounts', style: Theme.of(context).textTheme.bodyLarge),
            AppListView(
              items: item.discount!,
              shrinkWrap: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, item, index) {
                return Row(
                  children: [
                    widgetFactory.createIcon(materialIcon: Icons.discount),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widgetFactory.createText(context, item.name.localize(selectedLanguage), style: Theme.of(context).textTheme.bodyLarge),
                          widgetFactory.createText(context, item.percentage.toString(), style: Theme.of(context).textTheme.titleSmall),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    widgetFactory.createIcon(
                      materialIcon: Icons.delete,
                      onPressed: () {
                        onDelete?.call(item);
                      },
                    ),
                  ],
                );
              },
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widgetFactory.createText(context, 'Total', style: Theme.of(context).textTheme.bodyLarge),
                widgetFactory.createText(context, item.totalAmountString(currency: selectedCurrency), style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const Divider(height: 16),
            widgetFactory.createButton(
                context: context,
                content: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        ],
      ),
    );
  }
}
