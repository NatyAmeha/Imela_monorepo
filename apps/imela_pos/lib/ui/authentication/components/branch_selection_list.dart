import 'package:flutter/material.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BranchSelectionList extends StatelessWidget {
  final List<Branch> branches;
  final WidgetFactory widgetFactory;
  final Function(Branch) onBranchSelected;
  final String selectedLanguage;
  const BranchSelectionList({
    super.key,
    required this.branches,
    required this.widgetFactory,
    required this.onBranchSelected,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return AppListView(
      shrinkWrap: true,
      items: branches,
      itemBuilder: (context, item, index) {
        return widgetFactory.createListTile(
          title: widgetFactory.createText(context, item.name.localize(selectedLanguage)),
          onTap: () => onBranchSelected(item),
        );
      },
    );
  }
}
