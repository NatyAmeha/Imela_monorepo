import 'package:flutter/material.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class BranchListItem extends StatelessWidget {
  final Branch branchInfo;
  final Function onStartSession;
  final String selectedLanguage;
  const BranchListItem({
    super.key,
    required this.branchInfo,
    required this.onStartSession,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Theme.of(context).colorScheme.primary),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widgetFactory.createText(context, branchInfo.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              widgetFactory.createButton(
                  context: context,
                  content: const Text('Start Session'),
                  onPressed: () {
                    onStartSession();
                  }),
            ],
          )
        ],
      ),
    );
  }
}
