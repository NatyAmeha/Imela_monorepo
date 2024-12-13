import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class EligableRewardListItem extends StatelessWidget {
  final Reward reward;
  final String selectedLanguage;
  final bool isSelected;
  final Function(Reward)? onTap;
  final WidgetFactory widgetFactory;
  final bool isLocked;
  const EligableRewardListItem({
    super.key,
    required this.reward,
    required this.selectedLanguage,
    this.isSelected = false,
    this.onTap,
    required this.widgetFactory,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.primaryContainer;
    final widgetfactory = AppController.getInstance.getWidgetFactory(context);
    return IgnorePointer(
      ignoring: isLocked,
      child: widgetfactory.createCard(
        onTap: () {
          onTap?.call(reward);
        },
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widgetfactory.createText(context, reward.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleMedium),
                  BadgeList(
                    values: [reward.getDiscountInfo(selectedLanguage)],
                    colors: [Theme.of(context).colorScheme.tertiary],
                    widgetFactory: widgetFactory,
                  ),
                  widgetfactory.createText(context, reward.redeemPointString(), style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            if (isLocked) widgetfactory.createIcon(materialIcon: Icons.lock, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
