import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/membership/dto/membership_response.dart';

class BusinessLoyaltyBanner extends StatelessWidget {
  final String loyaltyProgramName;
  final LoyaltyResponse? loyaltyInfo;
  final MembershipResponse? membershipInfo;
  final Function() onLoyaltCardClicked;
  final Function() onMembershipCardClicked;
  const BusinessLoyaltyBanner({
    super.key,
    required this.loyaltyInfo,
    required this.loyaltyProgramName,
    required this.onLoyaltCardClicked,
    required this.onMembershipCardClicked,
    this.membershipInfo,
  });

  String get rewardsString => '${loyaltyInfo?.rewards?.length ?? 0} Rewards';

  @override
  Widget build(BuildContext context) {
    final widgetfactory = AppController.getInstance.getWidgetFactory(context);
    return widgetfactory.createCard(
      height: 50,
      child: Row(
        children: [
          if (loyaltyInfo?.rewards?.isNotEmpty ?? false)
            Expanded(
              child: widgetfactory.createCard(
                onTap: () => onLoyaltCardClicked(),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widgetfactory.createText(context, loyaltyProgramName, style: Theme.of(context).textTheme.bodyMedium, color: Colors.white),
                          // widgetfactory.createText(context, rewardsString, style: Theme.of(context).textTheme.bodySmall, color: Colors.white),
                        ],
                      ),
                    ),
                    widgetfactory.createIcon(materialIcon: Icons.keyboard_arrow_right, size: 24, color: Colors.white)
                  ],
                ),
              ),
            ),
          if (membershipInfo?.memberships?.isNotEmpty ?? false)
            Expanded(
              child: widgetfactory.createCard(
                onTap: () => onMembershipCardClicked(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.zero,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widgetfactory.createText(context, 'Membership', style: Theme.of(context).textTheme.bodyMedium, color: Colors.white),
                          // widgetfactory.createText(context, rewardsString, style: Theme.of(context).textTheme.bodySmall, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    widgetfactory.createIcon(materialIcon: Icons.keyboard_arrow_right, size: 24, color: Colors.white)
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }
}
