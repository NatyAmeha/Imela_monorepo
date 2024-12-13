import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';

class LoyaltyListItem extends StatelessWidget {
  final CustomerLoyalty customerLoyalty;
  final String selectedLanguage;
  final bool showRewardCount;
  final Function? onTap;
  const LoyaltyListItem({super.key, required this.customerLoyalty, required this.selectedLanguage, this.showRewardCount = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return widgetFactory.createCard(
      onTap: () => onTap?.call(),
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Your points', style: Theme.of(context).textTheme.titleLarge, color: Colors.white),
              widgetFactory.createCard(
                borderRadius: BorderRadius.circular(32),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                child: widgetFactory.createText(context, customerLoyalty.currentPointsString(selectedLanguage), style: Theme.of(context).textTheme.titleMedium, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          widgetFactory.createText(context, 'You can use your points in the cart page when you purchase products or services from this business', style: Theme.of(context).textTheme.labelMedium),
          if ((customerLoyalty.rewards?.isNotEmpty ?? false) && showRewardCount) ...[
            const SizedBox(height: 4),
            widgetFactory.createText(context, customerLoyalty.rewardCountString(selectedLanguage), style: Theme.of(context).textTheme.titleMedium),
          ]
        ],
      ),
    );
  }
}
