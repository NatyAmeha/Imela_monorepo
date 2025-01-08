import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/number_utils.dart';

class DiscountListModal extends StatelessWidget {
  final OrderItem item;
  final WidgetFactory widgetFactory;
  final String selectedLanguage;
  final String selectedCurrency;
  DiscountListModal({
    super.key,
    required this.item,
    required this.widgetFactory,
    required this.selectedLanguage,
    required this.selectedCurrency,
  });

  double subtotalAfterDiscount = 0;

  @override
  Widget build(BuildContext context) {
    subtotalAfterDiscount = item.getSubtotalPOSUpdated(includeAddonPrice: false);
    final totalAddonPrice = item.getTotalAddonPrices();
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widgetFactory.createText(context, 'Price breakdown', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Subtotal', style: Theme.of(context).textTheme.bodyLarge),
              widgetFactory.createText(context, item.subtotalAmountString(selectedCurrency, includeAddonPrice: false), style: Theme.of(context).textTheme.titleSmall),
            ],
          ).withPaddingSymetric(vertical: 6),
          if (totalAddonPrice > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widgetFactory.createText(context, 'Addon price', style: Theme.of(context).textTheme.bodyLarge),
                widgetFactory.createText(context, item.getTotalAddonPricesString(currency: selectedCurrency), style: Theme.of(context).textTheme.titleSmall),
              ],
            ).withPaddingSymetric(vertical: 6),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Total discount', style: Theme.of(context).textTheme.bodyLarge),
              widgetFactory.createText(context, item.getTotalDiscountAmountPOSString(currency: selectedCurrency), style: Theme.of(context).textTheme.titleSmall),
            ],
          ).withPaddingSymetric(vertical: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Total', style: Theme.of(context).textTheme.bodyLarge),
              widgetFactory.createText(context, item.totalAmountString(currency: selectedCurrency), style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const Divider(height: 24),
          widgetFactory.createText(context, 'Applied discounts', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          AppListView<ItemDiscount>(
            shrinkWrap: true,
            items: item.discount ?? [],
            itemBuilder: (context, discountInfo, index) {
              return widgetFactory.createListTile(
                title: Text(discountInfo.name.localize(selectedLanguage)),
                subtitle: Text(getDiscountedAmount(discountInfo)),
                leading: widgetFactory.createIcon(materialIcon: Icons.discount),
                onTap: () {},
              );
            },
          ),
          const Divider(height: 24),
          widgetFactory
              .createButton(
                context: context,
                content: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
              .withPaddingSymetric(vertical: 16),
        ],
      ),
    );
  }

  String getDiscountedAmount(ItemDiscount discount) {
    final discountAmount = discount.getDiscountAmount(subTotal: subtotalAfterDiscount).getPresision(2);
    subtotalAfterDiscount -= discountAmount;
    return '- $selectedCurrency ${discountAmount.getPresisionString(precision: 2)}';
  }
}
