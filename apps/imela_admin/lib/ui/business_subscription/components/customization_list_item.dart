import 'package:flutter/material.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/subscription/model/customization.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class CustomizationList extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final CustomizationCategory customizationCategory;
  final List<String> selectedCustomizationIds;
  final Function(String, bool isMultiSelection) onCustomizationSelected;
  CustomizationList({super.key, required this.widgetFactory, required this.customizationCategory, required this.selectedCustomizationIds, required this.onCustomizationSelected});

  final selectedLanguage = AppViewmodel.getInstance().selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widgetFactory.createText(context, customizationCategory.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleMedium).withPaddingSymetric(horizontal: 16),
        AppListView(
          shrinkWrap: true,
          items: customizationCategory.customizations!,
          itemBuilder: (context, customization, index) {
            if(customizationCategory.selectionType == CustomizationSelectionType.SINGLE_SELECTION.name) {
              return _buildRadioListTile(context, customization);
            } else {
              return _buildCheckboxListTile(context, customization);
            }
          },
        ),
      ],
    );
  }

  Widget _buildRadioListTile(BuildContext context, Customization customization) {
    return widgetFactory.createRadioListTile(
      context,
      title: customization.name.localize(selectedLanguage),
      value: customization.id,
      groupValue: selectedCustomizationIds.firstOrNull,
      onChanged: (value) {
        onCustomizationSelected(customization.id!, false);
      },
    );
  }

  Widget _buildCheckboxListTile(BuildContext context, Customization customization) {
    return widgetFactory.createCheckboxListTile(
      context,
      title: customization.name.localize(selectedLanguage),
      value: customization.isSelected(selectedCustomizationIds),
      onChanged: (value) {
        onCustomizationSelected(customization.id!, true);
      },
    );
  }
}
