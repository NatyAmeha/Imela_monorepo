import 'package:flutter/material.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';

class PaymentMethodListItem extends StatelessWidget {
  final PaymentMethod paymentMethod;
  final String amountEntered;
  final String selectedLanguage;

  final Function()? onSelected;
  final Function() onDelete;
  final bool isSelected;
  const PaymentMethodListItem({
    super.key,
    required this.paymentMethod,
    required this.amountEntered,
    required this.selectedLanguage,
    required this.isSelected,
    required this.onDelete,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer;
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
      borderRadius: BorderRadius.zero,
        border: Border.all(color: borderColor),
        padding: const EdgeInsets.symmetric(vertical: 8),
        onTap: () {
          onSelected?.call();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: widgetFactory.createText(context, paymentMethod.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleMedium).withPaddingSymetric(horizontal: 24)),
            Expanded(child: widgetFactory.createText(context, amountEntered, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center)),
            Expanded(
              child: widgetFactory.createIcon(
                materialIcon: Icons.delete,
                onPressed: () {
                  onDelete();
                },
              ),
            )
          ],
        ));
  }
}
