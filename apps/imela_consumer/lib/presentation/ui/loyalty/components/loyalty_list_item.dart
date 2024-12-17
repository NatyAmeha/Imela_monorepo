import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';

class LoyaltyListItem extends StatelessWidget {
  final CustomerLoyalty customerLoyalty;
  final String selectedLanguage;
  final bool showRewardCount;
  final Function? onTap;
  final Color? color;
  final bool showSeeRewardBtn;
  const LoyaltyListItem({
    super.key,
    required this.customerLoyalty,
    required this.selectedLanguage,
    this.showRewardCount = true,
    this.onTap,
    this.color,
    this.showSeeRewardBtn = true,
  });

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return widgetFactory.createCard(
      onTap: () => onTap?.call(),
      color: color ?? Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widgetFactory.createText(context, customerLoyalty.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleMedium, color: Colors.white),
          const Divider(color: Colors.white),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Earned points', style: Theme.of(context).textTheme.titleSmall, color: Colors.white),
              const SizedBox(width: 8),
              widgetFactory.createText(context, customerLoyalty.currentPointsString(selectedLanguage), style: Theme.of(context).textTheme.bodyLarge, color: Colors.white),
            ],
          ).withPaddingSymetric(vertical: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Tier', style: Theme.of(context).textTheme.titleSmall, color: Colors.white),
              const SizedBox(width: 8),
              widgetFactory.createText(context, 'Tier 1', style: Theme.of(context).textTheme.bodyLarge, color: Colors.white),
            ],
          ).withPaddingSymetric(vertical: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if ((customerLoyalty.rewards?.isNotEmpty ?? false) && showRewardCount) ...[
                const SizedBox(height: 4),
                widgetFactory.createText(context, customerLoyalty.rewardCountString(selectedLanguage), style: Theme.of(context).textTheme.titleMedium),
              ],
              if (showSeeRewardBtn) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: widgetFactory.createButton(
                    context: context,
                    content: widgetFactory.createText(context, 'See rewards', style: Theme.of(context).textTheme.bodySmall, color: Colors.white),
                    style: AppButtonStyle.outlinedButtonStyle(
                      context,
                      borderRadius: 24,
                    ),
                  ),
                )
              ],
            ],
          ),
        ],
      ),
    );
  }
}
