import 'package:flutter/material.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/date_utils.dart';

class UserMembershipDetailModal extends StatelessWidget {
  final Customer customer;
  final CustomerWithMembership membershipInfo;
  final List<Membership> memberships;
  final WidgetFactory widgetFactory;
  final double width;
  final double height;
  final Function() onRenewSubscriptionPressed;
  final Function() onCancelSubscriptionPressed;
  const UserMembershipDetailModal({
    super.key,
    required this.customer,
    required this.membershipInfo,
    required this.widgetFactory,
    required this.onRenewSubscriptionPressed,
    required this.onCancelSubscriptionPressed,
    required this.memberships,
    this.width = 300,
    this.height = 600,
  });

  String get membershipStatusString => membershipInfo.membershipSubscriptionStatusString('ENGLISH', customerId: customer.userId!);

  @override
  Widget build(BuildContext context) { 
    print('CUSTOMER INFO ${customer.getCustomerMembershipInfo(membershipInfo.membership.id!, memberships)}');
    return Stack(children: [
      widgetFactory.createCard(
        width: double.infinity,
        height: height,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widgetFactory.createCard(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widgetFactory.createText(context, customer.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  widgetFactory.createText(context, membershipStatusString, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (membershipInfo.getCustomerGroupMemberInfo(customer.userId!) != null) ...[
              buildSummarItem(context, 'Name', membershipInfo.membership.name.localize('ENGLISH')),
              const SizedBox(height: 4),
              buildSummarItem(context, ' Start Date', membershipInfo.subscription!.startDate.toFormattedString()),
              const SizedBox(height: 4),
              buildSummarItem(context, 'End Date', membershipInfo.subscription!.endDate.toFormattedString()),
              const SizedBox(height: 4),
              buildSummarItem(context, 'Duration', membershipInfo.membership.getDurationString('ENGLISH')),
              const SizedBox(height: 4),
              buildSummarItem(context, 'Payment Amount', membershipInfo.subscription!.amountPaid.toString()),
              if (customer.userId != null) ...[
                const Divider(),
                widgetFactory.createText(context, 'Payment proof', style: Theme.of(context).textTheme.bodySmall),
                // buildPaymentProof(context, membershipInfo.membership.getPaymentProof(customer.userId!)),
              ],
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
      Positioned(
        bottom: 50,
        left: 0,
        right: 0,
        child: buildActionButton(context),
      ),
    ]);
  }

  Widget buildSummarItem(BuildContext context, String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        widgetFactory.createText(context, title, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 8),
        widgetFactory.createText(context, value, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget buildPaymentProof(BuildContext context, List<String> receiptImages) {
    return SizedBox(
      height: 200,
      width: 500,
      child: AppListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        items: receiptImages,
        itemBuilder: (context, image, index) => AppImage(imageUrl: image, width: 100, height: 100),
      ),
    );
  }

  Widget buildActionButton(BuildContext context) {
    final customerGroupMemberInfo = membershipInfo.getCustomerGroupMemberInfo(customer.userId!);
    return Column(
      children: [
        if (customerGroupMemberInfo?.isUserMembershipStatusPending ?? false) ...[
          widgetFactory.createButton(
            context: context,
            content: const Text('Approve membership request'),
            onPressed: () {
              onRenewSubscriptionPressed();
            },
          ),
        ],
        if (customerGroupMemberInfo?.isUserMembershipStatusActive ?? false) ...[
          widgetFactory.createButton(
            context: context,
            content: const Text('Renew Subscription'),
            onPressed: () {
              onRenewSubscriptionPressed();
            },
          ),
          const SizedBox(height: 8),
          widgetFactory.createButton(
            context: context,
            content: const Text('Cancel Subscription'),
            style: AppButtonStyle.textButtonStyle(context),
            onPressed: () {
              onCancelSubscriptionPressed();
            },
          ),
        ]
      ],
    );
  }
}
