import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class DiscountListItem extends StatelessWidget {
  final DiscountInfo discount;
  final Function onToggle;
  final WidgetFactory widgetFactory;

  DiscountListItem({required this.discount, required this.onToggle, required this.widgetFactory});

  @override
  Widget build(BuildContext context) {
    print('applied applied discount ${discount.name} ${discount.isApplied}'); 
    return widgetFactory.createCard(
      onTap: (){},
      padding: const EdgeInsets.all(10),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(discount.name, style: Theme.of(context).textTheme.titleSmall),
                Row(
                  children: [
                    Text(
                      "${discount.value} ${discount.type == DiscountType.PERCENTAGE ? '%' : '\$'}",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(width: 10),
                    Text(
                      discount.source.toString().split('.').last,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: discount.isApplied,
            onChanged: (value) => onToggle(),
          ),
        ],
      ),
    );
  }
}
