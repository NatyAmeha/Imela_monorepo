import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
import 'package:imela_core/loyalty/model/loyalty_tier.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';

class LoyaltyListItem extends StatelessWidget {
  final CustomerLoyalty customerLoyalty;
  final String selectedLanguage;
  final bool showRewardCount;
  final Function? onTap;
  final Color? color;
  final bool showSeeRewardBtn;
  final LoyaltyTier? loyaltyTier;
  const LoyaltyListItem({
    super.key,
    required this.customerLoyalty,
    required this.selectedLanguage,
    this.showRewardCount = true,
    this.onTap,
    this.color,
    this.showSeeRewardBtn = true,
    this.loyaltyTier,
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
              widgetFactory.createText(context, 'Earned points', style: Theme.of(context).textTheme.titleSmall, color: Colors.white70),
              const SizedBox(width: 8),
              widgetFactory.createText(context, customerLoyalty.currentPointsString(selectedLanguage), style: Theme.of(context).textTheme.bodyLarge, color: Colors.white),
            ],
          ).withPaddingSymetric(vertical: 2),
          if (loyaltyTier != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widgetFactory.createText(context, 'Your Current Tier', style: Theme.of(context).textTheme.titleSmall, color: Colors.white70),
                const SizedBox(width: 8),
                widgetFactory.createText(context, '${loyaltyTier?.name?.localize(selectedLanguage)}', style: Theme.of(context).textTheme.bodyLarge, color: Colors.white),
              ],
            ).withPaddingSymetric(vertical: 2),
          ],
          // if (loyaltyTier != null) ...[
          //   AppListView(
          //     items: (loyaltyTier?.rewards ?? []).take(2).toList(),
          //     shrinkWrap: true,
          //     itemBuilder: (context, reward, item) {
          //       return Column(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Row(
          //             children: [
          //               widgetFactory.createIcon(materialIcon: Icons.discount_rounded, color: Colors.white),
          //               const SizedBox(width: 8),
          //               widgetFactory.createText(context, reward.name?.localize(selectedLanguage) ?? '', style: Theme.of(context).textTheme.bodyLarge, color: Colors.white),
          //             ],
          //           ),
          //           widgetFactory.createText(context, reward.minPointsToRedeem.toString(), style: Theme.of(context).textTheme.bodyLarge, color: Colors.white),
          //         ],
          //       );
          //     },
          //   ),
          // ],
          if (showSeeRewardBtn) ...[
            widgetFactory.createButton(
              context: context,
              content: widgetFactory.createText(context, 'See rewards', style: Theme.of(context).textTheme.bodySmall, color: Colors.white),
              style: AppButtonStyle.outlinedButtonStyle(
                context,
                borderRadius: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
