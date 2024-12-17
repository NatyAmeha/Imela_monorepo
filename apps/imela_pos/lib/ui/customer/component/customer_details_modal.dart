import 'package:flutter/material.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class CustomerDetailsModal extends StatefulWidget {
  final Customer customer;
  final CustomerLoyalty? customerLoyalty;
  final List<Reward> eligableRewards;
  final List<Reward> businessRewards;
  final String selectedLanguage;
  final List<CustomerWithMembership> customerMemberships;
  final Function(BuildContext context, Reward? selectedLoyaltyReward) onCustomerSelected;

  const CustomerDetailsModal({
    Key? key,
    required this.customer,
    this.customerLoyalty,
    required this.eligableRewards,
    required this.businessRewards,
    required this.selectedLanguage,
    required this.onCustomerSelected,
    required this.customerMemberships,
  }) : super(key: key);

  @override
  State<CustomerDetailsModal> createState() => _CustomerDetailsModalState();
}

class _CustomerDetailsModalState extends State<CustomerDetailsModal> {
  // local state variables
  Reward? selectedReward;
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
  }

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCustomerInfoSection(context, widgetFactory),
              const SizedBox(height: 16),
              _buildBusinessRewardsSection(context),
              const Divider(height: 16),
              if (widget.customerMemberships.isNotEmpty) ...[
                _buildMembershipSection(context),
                const SizedBox(height: 16),
              ],
              const Divider(height: 16),
              _buildRewardsSection(context),
              const SizedBox(height: 100),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: widgetFactory.createButton(
              context: context,
              content: const Text('Select Customer'),
              onPressed: () {
                widget.onCustomerSelected(context, selectedReward);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCustomerInfoSection(BuildContext context, WidgetFactory widgetFactory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widgetFactory.createText(context, 'Customer Information', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildInfoRow(context, widgetFactory, 'Name', '${widget.customer.name}}'),
        _buildInfoRow(context, widgetFactory, 'Phone', widget.customer.phoneNumber ?? 'N/A'),
        _buildInfoRow(context, widgetFactory, 'Email', widget.customer.email ?? 'N/A'),
        // _buildInfoRow(context, widgetFactory, 'Address', customer.address ?? 'N/A'),
        const Divider(height: 16),
        if (widget.customerLoyalty?.currentPoints != null) ...[
          const SizedBox(height: 8),
          _buildInfoRow(context, widgetFactory, 'Loyalty Points', widget.customerLoyalty!.currentPointsString('ENGLISH')),
        ],
        const Divider(height: 16),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, WidgetFactory widgetFactory, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          widgetFactory.createText(context, label, style: Theme.of(context).textTheme.titleSmall),
          SizedBox(width: Responsive.getWidth(context, small: 30, medium: 40, large: 54)),
          Flexible(child: widgetFactory.createText(context, value, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildBusinessRewardsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widgetFactory.createText(context, 'Eligible Rewards', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (widget.eligableRewards.isEmpty)
          widgetFactory.createCard(
            color: Theme.of(context).colorScheme.primaryContainer,
            padding: const EdgeInsets.all(8),
            child: widgetFactory.createText(
              context,
              'No eligible rewards available. Customer has insufficient points to redeem any rewards.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          AppGridView(
            shrinkWrap: true,
            primary: false,
            itemExtent: 120,
            crossAxisCount: Responsive.getGridCount(context, itemWidth: 600),
            items: widget.eligableRewards,
            itemBuilder: (context, item, index) => _buildRewardItem(context, widgetFactory, item, canBeSelected: selectedReward?.id == item.id),
          ),
      ],
    );
  }

  Widget _buildMembershipSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widgetFactory.createText(context, 'Customer Memberships', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        AppListView(
          shrinkWrap: true,
          primary: false,
          items: widget.customerMemberships,
          itemBuilder: (context, item, index) {
            return Row(
              children: [
                widgetFactory.createIcon(materialIcon: Icons.card_membership, size: 16),
                const SizedBox(width: 4),
                Flexible(child: widgetFactory.createText(context, item.membership.name.localize('ENGLISH'), style: Theme.of(context).textTheme.bodyMedium)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRewardsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widgetFactory.createText(context, 'Available Rewards', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (widget.businessRewards.isEmpty)
          widgetFactory.createText(
            context,
            'No reward available.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          AppGridView(
            shrinkWrap: true,
            primary: false,
            itemExtent: 100,
            crossAxisCount: Responsive.getGridCount(context, itemWidth: 600),
            items: widget.businessRewards,
            itemBuilder: (context, item, index) => _buildRewardItem(context, widgetFactory, item),
          ),
      ],
    );
  }

  Widget _buildRewardItem(BuildContext context, WidgetFactory widgetFactory, Reward reward, {bool canBeSelected = false}) {
    var borderColor = canBeSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer;
    return widgetFactory.createCard(
      onTap: () {
        setState(() {
          selectedReward = reward;
        });
      },
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: borderColor),
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetFactory.createText(context, reward.name.localize(widget.selectedLanguage), style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 4),
                widgetFactory.createText(context, reward.redeemPointString(showMinus: true), style: Theme.of(context).textTheme.bodyMedium),
              ],
            ).withPaddingSymetric(vertical: 20, horizontal: 10),
          ),
          // if (reward.discountAmount != null)
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: BadgeList(
              values: [reward.getDiscountInfo(widget.selectedLanguage)],
              colors: [Theme.of(context).colorScheme.tertiary],
              widgetFactory: widgetFactory,
              width: 160,
              height: 15,
              textStyle: Theme.of(context).textTheme.bodySmall,
            ),
          )
        ],
      ),
    );
  }

  bool showApplyButton() {
    return selectedReward != null;
  }
}
