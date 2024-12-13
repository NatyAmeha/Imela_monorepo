import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/addon_viewmodel.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/product_addon_optioin_list_item.dart';
import 'package:imela/presentation/ui/shared/list/list_header.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductAddonDetailsModal extends StatelessWidget {
  final ProductAddon addon;
  final Function(BuildContext context) onSelectionFinished;
  final String selectedLanguage;
  final WidgetFactory widgetFactory;
  ProductAddonDetailsModal({
    super.key,
    required this.addon,
    required this.onSelectionFinished,
    required this.selectedLanguage,
    required this.widgetFactory,
  });

  final viewmodel = ProductAddonViewmodel.getInstance();

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      height: MediaQuery.sizeOf(context).height * 0.9,
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          AppListView(
            header: ListHeader(title: addon.name.localize(selectedLanguage), widgetFactory: widgetFactory),
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 75),
            items: addon.options,
            itemBuilder: (context, option, index) {
              return Obx(
                () => ProductAddonOptioinListItem(
                  addon: addon,
                  option: option,
                  selectedOptionsId: viewmodel.selectedAddonOptionsId(addon.id!),
                  currency: viewmodel.appViewmmodel.selectedCurrency.name,
                  onOptionSelected: (selectedOptionId, isSelected) {
                    viewmodel.selectAddonOption(context, addon, selectedOptionId);
                  },
                ),
              );
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Obx(
              () => widgetFactory.createButton(
                context: context,
                content: const Text('Complete'),
                onPressed: viewmodel.canEnableOptionSelection.value
                    ? () {
                        onSelectionFinished(context);
                      }
                    : null,
              ),
            ),
          )
        ],
      ),
    );
  }
}
