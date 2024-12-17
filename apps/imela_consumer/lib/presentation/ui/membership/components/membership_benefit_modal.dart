import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela_core/membership/model/group.model.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/subscription/model/subscription.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class MembershipBenefitsModal extends StatelessWidget {
  final Membership membershipInfo;
  final Subscription? currentUserSubscription;
  final Widget? qrcodeWidget;
  final GroupMember? userGroupMemberInfo;
  final String selectedLanguage;
  final String currency;
  final double? height;
  const MembershipBenefitsModal({
    super.key,
    this.qrcodeWidget,
    required this.membershipInfo,
    required this.selectedLanguage,
    required this.currency,
    this.currentUserSubscription,
    this.userGroupMemberInfo,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    var widgetFactory = AppController.getInstance.getWidgetFactory(context);
    double modalHeight = height ?? MediaQuery.of(context).size.height * 0.8;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (qrcodeWidget != null) ...[
            Align(alignment: Alignment.center, child: Padding(padding: const EdgeInsets.all(16), child: qrcodeWidget!)),
          ],
          widgetFactory.createText(context, membershipInfo.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          _buildMembershipSummary(context, widgetFactory, membershipInfo, selectedLanguage, currency),
          const SizedBox(height: 16),
          widgetFactory.createText(context, 'Benefits', style: Theme.of(context).textTheme.titleMedium).withPaddingSymetric(vertical: 16),
          AppListView(
            items: membershipInfo.benefits,
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            shrinkWrap: true,
            primary: false,
            itemBuilder: (context, item, index) {
              return Row(
                children: [
                  widgetFactory.createIcon(materialIcon: Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 10),
                  Expanded(child: widgetFactory.createText(context, item.name.localize(selectedLanguage), style: Theme.of(context).textTheme.labelLarge)),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          widgetFactory.createButton(context: context, content: const Text('Close'), onPressed: () => Navigator.of(context).pop())
        ],
      ),
    );
  }

  Widget _buildMembershipSummary(BuildContext context, WidgetFactory widgetFactory, Membership membershipInfo, String selectedLanguage, String currency) {
    return Column(
      children: [
        Row(
          children: [
            widgetFactory.createIcon(materialIcon: Icons.payment, color: Colors.grey),
            const SizedBox(width: 10),
            widgetFactory.createText(context, 'Amount', style: Theme.of(context).textTheme.labelMedium),
            const Spacer(),
            widgetFactory.createText(context, membershipInfo.price.toSelectedPriceString(currency).toString(), style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            widgetFactory.createIcon(materialIcon: Icons.calendar_month, color: Colors.grey),
            const SizedBox(width: 10),
            widgetFactory.createText(context, 'Duration', style: Theme.of(context).textTheme.labelMedium),
            const Spacer(),
            widgetFactory.createText(context, membershipInfo.getDurationString(selectedLanguage), style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            widgetFactory.createIcon(materialIcon: Icons.card_membership, color: Colors.grey),
            const SizedBox(width: 10),
            widgetFactory.createText(context, 'Status', style: Theme.of(context).textTheme.labelMedium),
            const Spacer(),
            widgetFactory.createText(context, currentUserSubscription != null ? 'Active' : 'Pending', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                widgetFactory.createIcon(materialIcon: Icons.receipt, color: Colors.grey),
                const SizedBox(width: 10),
                widgetFactory.createText(context, 'Payment receipt', style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
            const SizedBox(height: 10),
            if (userGroupMemberInfo?.paymentMethod?.receiptImages?.isNotEmpty == true) ...[
              AppImage(
                imageUrl: userGroupMemberInfo?.paymentMethod?.receiptImages?.first,
                width: 50,
                height: 50,
              )
            ] else
              widgetFactory.createText(context, 'No receipt', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ],
    );
  }
}
