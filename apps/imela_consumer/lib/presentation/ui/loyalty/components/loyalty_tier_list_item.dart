import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:imela_core/loyalty/model/loyalty_tier.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class LoyaltyTierListItem extends StatelessWidget {
  final LoyaltyTier loyaltyTier;
  final WidgetFactory widgetFactory;
  final String selectedLanguage;
  final Function() onTap;
  const LoyaltyTierListItem({
    super.key,
    required this.loyaltyTier,
    required this.widgetFactory,
    required this.selectedLanguage,
    required this.onTap,
  });

  List<Reward> get rewards => (loyaltyTier.rewards ?? []).take(3).toList();

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      onTap: () {
        onTap();
      },
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widgetFactory.createText(context, loyaltyTier.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleMedium),
              if (loyaltyTier.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 4),
                widgetFactory.createText(context, loyaltyTier.description.localize(selectedLanguage), style: Theme.of(context).textTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
              ],
              const Divider(),
              AppListView(
                shrinkWrap: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                items: rewards,
                itemBuilder: (context, item, index) {
                  return _buildRewardRow(context, item);
                },
              ),
              if (rewards.length > 3) widgetFactory.createText(context, '+${rewards.length - 3} more', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ).paddingAll(12),
          Positioned(
            top: 0,
            right: 0,
            child: _buildPointInfo(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardRow(BuildContext context, Reward reward) {
    return Row(
      children: [
        widgetFactory.createIcon(materialIcon: Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 4),
        widgetFactory.createText(context, reward.name.localize(selectedLanguage), style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildPointInfo(BuildContext context) {
    return widgetFactory.createCard(
      color: Theme.of(context).colorScheme.tertiary,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(1000), bottomLeft: Radius.circular(1000)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          widgetFactory.createText(context, 'point required', style: Theme.of(context).textTheme.bodySmall, color: Colors.white54),
          widgetFactory.createText(context, '${loyaltyTier.minPoints} points', style: Theme.of(context).textTheme.bodySmall, color: Colors.white),
        ],
      ),
    );
  }
}
