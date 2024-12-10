import 'package:flutter/material.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/pop_up_menu_data.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class CustomerListItem extends StatelessWidget {
  final Customer customer;
  final Function() onSelected;
  final Function? onTap;
  final bool isSelected;
  final WidgetFactory widgetFactory;
  final List<Membership> memberships;
  final bool showSubscriptionStatus;
  final List<PopupMenuItemData<String>> actions;
  final Function(String selectedValue) onActionClick;

  const CustomerListItem({
    super.key,
    required this.customer,
    required this.onSelected,
    required this.widgetFactory,
    this.isSelected = false,
    this.onTap,
    this.memberships = const [],
    this.showSubscriptionStatus = false,
    this.actions = const [],
    required this.onActionClick,
  });

  @override
  Widget build(BuildContext context) {
    var color = isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent;
    var borderColor = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer;
    return widgetFactory.createCard(
      border: Border.all(color: borderColor),
      borderRadius: BorderRadius.circular(8),
      color: color,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  widgetFactory.createIcon(materialIcon: Icons.person, size: 30, color: isSelected ? Colors.white : Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widgetFactory.createText(context, customer.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: isSelected ? Colors.white : Colors.black)),
                        widgetFactory.createText(context, customer.phoneNumber ?? 'No phone number', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isSelected ? Colors.white70 : Colors.black)),
                      ],
                    ),
                  ),
                  if (actions.isNotEmpty)
                    widgetFactory.createPopupMenu(
                      context: context,
                      items: actions,
                      onSelected: (value) {
                        onActionClick(value);
                      },
                      child: const Icon(Icons.more_vert),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (customer.userId == null) ...[
                widgetFactory.createText(context, 'Not signed up', style: Theme.of(context).textTheme.bodySmall),
              ],
              buildMembershipInfo(context),
            ],
          ).withPaddingSymetric(vertical: 12, horizontal: 16),
        ],
      ),
      onTap: () {
        onSelected();
      },
    );
  }

  Widget buildMembershipInfo(BuildContext context) {
    final customerMemberships = customer.getCustomerMemberships(memberships);
    return AppListView(
      shrinkWrap: true,
      items: customerMemberships,
      itemBuilder: (context, membership, index) {
        final isSubscriptionActive = membership.subscription?.isSubscriptionActive() ?? false;
        final subscriptionStatusString = membership.membershipSubscriptionStatusString('ENGLISH', customerId: customer.userId);
        return widgetFactory.createCard(
          padding: const EdgeInsets.all(8),
          border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  widgetFactory.createIcon(materialIcon: Icons.card_membership_outlined, size: 16),
                  const SizedBox(width: 4),
                  Row(
                    children: [
                      widgetFactory.createText(
                        context,
                        membership.membership.name.localize('ENGLISH'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BadgeList(
                      values: [subscriptionStatusString],
                      height: 16,
                      // width: 100,
                      colors: [isSubscriptionActive ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.errorContainer],
                      widgetFactory: widgetFactory,
                    ),
                  ),
                ],
              ),
              widgetFactory.createText(context, membership.subscription?.daysLeftToExpireString('AMHARIC') ?? '', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }
}
