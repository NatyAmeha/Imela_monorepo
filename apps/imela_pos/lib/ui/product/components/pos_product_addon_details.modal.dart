import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/ui/product/components/addon_viewmodel.dart';
import 'package:imela_pos/ui/product/components/product_addon_optioin_list_item.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class PosProductAddonDetailsModal extends StatelessWidget {
  final ProductAddon addon;
  final String selectedLanguage;
  final WidgetFactory widgetFactory;
  final Function onSelectionFinished;
  PosProductAddonDetailsModal({
    super.key,
    required this.addon,
    required this.selectedLanguage,
    required this.widgetFactory,
    required this.onSelectionFinished,
  });

  final viewmodel = ProductAddonViewmodel.getInstance();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(addon.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleMedium),
          ListView.builder(
            shrinkWrap: true,
            itemCount: addon.options.length,
            itemBuilder: (context, index) {
              final option = addon.options[index];
              print('option ${option.id} ${option.name.localize(selectedLanguage)}');
              return Obx(
                () => ProductAddonOptioinListItem( 
                  inputType: addon.inputType,
                  option: option,
                  selectedOptionsId: viewmodel.selectedAddonOptionsId(addon.id!),
                  onOptionSelected: (selectedOptionId, isSelected) {
                    viewmodel.selectAddonOption(context, addon, selectedOptionId);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              onSelectionFinished();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
