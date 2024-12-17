import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';

class BranchListItem extends StatelessWidget {
  final Branch branch;
  final bool isSelected;
  final Function(Branch)? onBranchSelected;
  final String selectedLanguage;
  const BranchListItem({super.key, required this.branch, this.isSelected = false, this.onBranchSelected, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    Color borderColor = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer;
    final widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return widgetFactory.createCard(
      onTap: () {
        onBranchSelected?.call(branch);
      },
      padding: const EdgeInsets.all(16),
      border: Border.all(color: borderColor),
      color: isSelected ? Theme.of(context).colorScheme.primary : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widgetFactory.createIcon(materialIcon: Icons.store, size: 24, color: isSelected ? Colors.white : null),
          const SizedBox(width: 8),
          Expanded(child: widgetFactory.createText(context, branch.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleMedium, color: isSelected ? Colors.white : null)),
          const SizedBox(width: 8),
          widgetFactory.createIcon(materialIcon: Icons.keyboard_arrow_right, size: 24, color: isSelected ? Colors.white : null),
        ],
      ),
    );
  }
}
