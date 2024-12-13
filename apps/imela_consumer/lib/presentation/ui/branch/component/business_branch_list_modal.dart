import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/branch/component/branch_list_item.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_core/branch/model/branch.model.dart';

class BusinessBranchListModal extends StatelessWidget {
  final List<Branch> branches;
  final Branch? selectedBranch;
  final Function(Branch)? onBranchSelected;
  BusinessBranchListModal({super.key, required this.branches, this.selectedBranch, this.onBranchSelected});
  final String selectedLanguage = AppController.getInstance.selectedLanguage.name;

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return widgetFactory.createCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widgetFactory.createText(context, 'Select branch', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            AppListView(
              shrinkWrap: true,
              items: branches,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, branch, index) {
                return BranchListItem(
                  branch: branch,
                  isSelected: isSelected(branch),
                  onBranchSelected: onBranchSelected,
                  selectedLanguage: selectedLanguage,
                );
              },
            ),
          ],
        ));
  }

  bool isSelected(Branch branch) {
    return selectedBranch?.id == branch.id;
  }
}
