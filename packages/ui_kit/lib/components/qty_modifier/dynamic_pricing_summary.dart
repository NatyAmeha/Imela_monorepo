import 'package:flutter/material.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/number_utils.dart';

class ProductDynamicPriceSummary extends StatelessWidget {
  final Product product;
  final WidgetFactory widgetFactory;
  final String selectedCurrency;
  final List<Discount> additionalDiscounts;
  const ProductDynamicPriceSummary({
    super.key,
    required this.product,
    required this.widgetFactory,
    required this.selectedCurrency,
    this.additionalDiscounts = const [],
  });

  @override
  Widget build(BuildContext context) {
    final dyanmicPrice = product.sortedDynamicPricingDiscounts;
    return widgetFactory.createCard(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 60,
        child: ListView.separated(
          itemCount: dyanmicPrice.length + 1,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, index) => const IntrinsicHeight(child: VerticalDivider(width: 8, color: Colors.grey)),
          itemBuilder: (context, index) {
            if (index == 0) {
              final basePrice = product.getTotalPriceUpdatedString(selectedCurrency, discounts: additionalDiscounts);
              final qtyCondition = double.tryParse(dyanmicPrice[0].conditionValue ?? '1');
              final qtyConditionString = '1 - ${qtyCondition?.getPresisionString() ?? 1} ${product.getDefaultUOM()}';
              return buildItem(context, basePrice, '', qtyConditionString);
            } else {
              final discount = product.sortedDynamicPricingDiscounts[index - 1];
              final qtyCondition = double.parse(discount.conditionValue ?? '1');
              double? maxQtyCondition;
              if (index < dyanmicPrice.length) {
                maxQtyCondition = double.parse(dyanmicPrice[index].conditionValue ?? '1');
              }
              final qtyConditionString = maxQtyCondition != null ? '${qtyCondition.getPresisionString()} - ${maxQtyCondition.getPresisionString()} ${product.getDefaultUOM()}' : '> ${qtyCondition.getPresisionString()} ${product.getDefaultUOM()}';
              final selectedPrice = product.selectedDynamicPrice(selectedCurrency, qty: qtyCondition, additionalDiscounts: additionalDiscounts);
              final discountAmountString = '${discount.value}% off';
              return buildItem(context, selectedPrice.amountWithCurrency, discountAmountString, qtyConditionString);
            }
          },
        ),
      ),
    );
  }

  Widget buildItem(BuildContext context, String priceString, String discountAmountString, String qtyConditionString) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widgetFactory.createText(context, priceString, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 2),
            if (discountAmountString.isNotEmpty) ...[
              BadgeList(
                values: [discountAmountString],
                colors: const [Colors.yellow],
                widgetFactory: widgetFactory,
                width: 100,
                height: 20,
              ),
            ]
          ],
        ),
        const SizedBox(height: 8),
        widgetFactory.createText(context, qtyConditionString, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ).withPaddingSymetric(horizontal: 10);
  }
}
