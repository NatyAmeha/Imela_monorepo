import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';

class ProductAddonOptioinListItem extends StatelessWidget {
  final ProductAddon addon;
  final ProductAddonOption option;
  final List<String> selectedOptionsId;
  final String currency;
  final Function(String?, bool? isSelected) onOptionSelected;
  const ProductAddonOptioinListItem({
    super.key,
    required this.addon,
    required this.option,
    required this.selectedOptionsId,
    required this.onOptionSelected,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return addon.inputType == AddonInputType.SINGLE_SELECTION_INPUT.name
        ? widgetFactory.createRadioListTile(
            context,
            title: option.name.localize('ENGLISH'),
            subtitle: option.getOptionPriceString(currency),
            value: option.id!,
            groupValue: selectedOptionsId.firstOrNull, 
            onChanged: (value) {
              onOptionSelected(value, null);
            },
          )
        : widgetFactory.createCheckboxListTile(
            context,
            title: option.name.localize('ENGLISH'),
            subtitle: option.getOptionPriceString(currency),
            value: selectedOptionsId.contains(option.id!),
            onChanged: (isChecked) {
              onOptionSelected(option.id, isChecked);
            },
          );
  }
}
