import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/business_subscription/components/customization.viewmodel.dart';
import 'package:imela_admin/ui/business_subscription/components/customization_list_item.dart';
import 'package:imela_core/subscription/model/customization.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';

class PlatformServcieCustomizationSelector extends StatefulWidget {
  final List<CustomizationCategory> customizationCategories;
  final Function(Map<String, List<String>> selectedCustomizations)? onCustomizationSelected;
  const PlatformServcieCustomizationSelector({
    super.key,
    required this.customizationCategories,
    this.onCustomizationSelected,
  });

  @override
  State<PlatformServcieCustomizationSelector> createState() => _PlatformServcieCustomizationSelectorState();
}

class _PlatformServcieCustomizationSelectorState extends State<PlatformServcieCustomizationSelector> {
  String get selectedLanguage => AppViewmodel.getInstance().selectedLanguage;

  CustomizationViewmodel get customizationViewmodel => CustomizationViewmodel.getInstance();
 
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      customizationViewmodel.initViewmodel(data: {'customizationCategories': widget.customizationCategories});
    });
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return AppListView(
      shrinkWrap: true,
      primary: false,
      items: widget.customizationCategories,
      itemBuilder: (context, customizationCategory, index) {
        return Obx(
          () => CustomizationList(
            widgetFactory: widgetFactory,
            customizationCategory: customizationCategory,
            selectedCustomizationIds: customizationViewmodel.getSelectedCustomizationForCategory(customizationCategory.id!),
            onCustomizationSelected: (customizationId, ismultiSelection) {
              ismultiSelection ? customizationViewmodel.updateMultiSelectioncustomization(customizationCategory.id!, customizationId) : customizationViewmodel.updateSingleSelectioncustomization(customizationCategory.id!, customizationId);
              widget.onCustomizationSelected?.call(customizationViewmodel.selectedCustomization.value);
            },
          ),
        );
      },
    );
  }
}
