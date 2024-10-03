import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/shared/countdown_timer.component.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BusinessDiscountCard extends StatelessWidget {
  final List<Discount> discounts;
  final double width;
  final double? height;
  final String selectedCurrency;
  final Function(Discount) onDiscountSelected;
  const BusinessDiscountCard({
    super.key,
    required this.discounts,
    this.width = double.infinity,
    this.height,
    required this.onDiscountSelected,
    required this.selectedCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return widgetFactory.createPageView(
      context,
      itemCount: discounts.length,
      itemBuilder: (context, index) {
        return widgetFactory.createCard(
          color: Theme.of(context).colorScheme.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BusinessDiscountCardItem(discount: discounts[index], selectedCurrency: selectedCurrency, widgetFactory: widgetFactory),
        );
      },
      controller: PageController(),
      width: width,
      height: height ?? 40,
    );
  }
}

class BusinessDiscountCardItem extends StatelessWidget {
  final Discount discount;
  final String selectedCurrency;
  final WidgetFactory widgetFactory;
  const BusinessDiscountCardItem({super.key, required this.discount, required this.selectedCurrency, required this.widgetFactory});

  @override
  Widget build(BuildContext context) {
    if (discount.condition == DiscountCondition.TIME_BASED.name) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widgetFactory.createText(context, discount.getDiscountValueString(selectedCurrency), color: ColorManager.white),
          const SizedBox(width: 8),
          CountdownTimer(duration: discount.remainingTime, backgroundColor: Colors.transparent, textStyle: Theme.of(context).textTheme.bodySmall),
        ],
      );
    }
    return Text(discount.getDiscountValueString(selectedCurrency));
  }
}
