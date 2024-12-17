import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class DiscountListItem extends StatelessWidget {
  final DiscountInfo discount;
  final Function onToggle;
  final WidgetFactory widgetFactory;
  final String selectedLanguage;

  DiscountListItem({required this.discount, required this.onToggle, required this.widgetFactory, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      onTap: () {},
      padding: const EdgeInsets.all(10),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,

                  children: [
                    widgetFactory.createText(context, discount.name, style: Theme.of(context).textTheme.titleSmall),
                    if (discount.pointApplied > 0) ...[
                      const SizedBox(width: 8),
                      BadgeList(
                        values: [discount.getPointAppliedString(selectedLanguage)],
                        colors: [Theme.of(context).colorScheme.tertiary],
                        width: 150,
                        height: 16,
                        widgetFactory: widgetFactory,
                        textStyle: Theme.of(context).textTheme.bodySmall,
                      )
                    ]
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "${discount.value} ${discount.type == DiscountType.PERCENTAGE ? '%' : '\$'}",
                      style: Theme.of(context).textTheme.bodySmall,
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
