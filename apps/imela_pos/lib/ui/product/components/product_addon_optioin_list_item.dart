import 'package:flutter/material.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';

class ProductAddonOptioinListItem extends StatelessWidget {
  final ProductAddonOption option;
  final String inputType;
  final List<String> selectedOptionsId;
  final Function(String?, bool? isSelected) onOptionSelected;
  const ProductAddonOptioinListItem({super.key, required this.inputType, required this.option, required this.selectedOptionsId, required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return inputType == AddonInputType.SINGLE_SELECTION_INPUT.name
        ? widgetFactory.createRadioListTile(
            context,
            title: option.name.localize('ENGLISH'),
            value: option.id!,
            groupValue: selectedOptionsId.firstOrNull,
            onChanged: (value) {
              onOptionSelected(value, null);
            },
          )
        : widgetFactory.createCheckboxListTile(
            context,
            title: option.name.localize('ENGLISH'),
            value: selectedOptionsId.contains(option.id),
            onChanged: (isChecked) {
              onOptionSelected(option.id, isChecked);
            },
          );
  }
}
