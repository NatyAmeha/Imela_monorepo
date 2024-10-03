import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/addon_viewmodel.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/product_addon_optioin_list_item.dart';
import 'package:imela_core/product/model/product_addon.model.dart';

class ProductAddonDetailsModal extends StatelessWidget {
  final ProductAddon addon;
  final Function onSelectionFinished;
  ProductAddonDetailsModal({super.key, required this.addon, required this.onSelectionFinished});

  final viewmodel = ProductAddonViewmodel.getInstance();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Select Options for ${addon.name}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            itemCount: addon.options.length,
            itemBuilder: (context, index) {
              final option = addon.options[index];
              return Obx(
                () => ProductAddonOptioinListItem(
                  inputType: addon.inputType,
                  option: option,
                  selectedOptionsId: viewmodel.selectedAddonOptionsId(addon.id!),
                  onOptionSelected: (selectedOptionId, isSelected) {
                    viewmodel.selectAddonOption(addon, selectedOptionId);
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
