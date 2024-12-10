import 'package:flutter/material.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
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
              const SizedBox(height: 16),
              if (widget.customerMemberships.isNotEmpty) ...[
                _buildMembershipSection(context),
                const SizedBox(height: 16),
                // _buildRewardsSection(context),
              ],
              Align(
                alignment: Alignment.bottomCenter,
                child: widgetFactory.createButton(
                  context: context,
                  content: widgetFactory.createText(context, 'Select Customer', style: Theme.of(context).textTheme.labelMedium),
                  onPressed: () {
                    widget.onCustomerSelected(context, selectedReward);
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoSection(BuildContext context, WidgetFactory widgetFactory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widgetFactory.createText(
          context,
          'Customer Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(context, widgetFactory, 'Name', '${widget.customer.name}}'),
        _buildInfoRow(context, widgetFactory, 'Phone', widget.customer.phoneNumber ?? 'N/A'),
        _buildInfoRow(context, widgetFactory, 'Email', widget.customer.email ?? 'N/A'),
        // _buildInfoRow(context, widgetFactory, 'Address', customer.address ?? 'N/A'),
        if (widget.customerLoyalty?.currentPoints != null) ...[
          const SizedBox(height: 8),
          _buildInfoRow(context, widgetFactory, 'Loyalty Points', widget.customerLoyalty!.currentPointsString('ENGLISH')),
        ]
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, WidgetFactory widgetFactory, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: widgetFactory.createText(
              context,
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: widgetFactory.createText(context, value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessRewardsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widgetFactory.createText(
          context,
          'Eligible Rewards',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (widget.eligableRewards.isEmpty)
          widgetFactory.createText(
            context,
            'No eligible rewards available.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          AppGridView(
            shrinkWrap: true,
            primary: false,
            itemExtent: 120,
            crossAxisCount: Responsive.getGridCount(context, itemWidth: 500),
            items: widget.eligableRewards,
            itemBuilder: (context, item, index) => _buildRewardItem(context, widgetFactory, item),
          ),
      ],
    );
  }

  Widget _buildMembershipSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widgetFactory.createText(
          context,
          'Customer Memberships',
          style: Theme.of(context).textTheme.titleLarge,
        ),
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
                widgetFactory.createText(context, item.membership.name.localize('ENGLISH'), style: Theme.of(context).textTheme.bodyMedium),
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
        widgetFactory.createText(
          context,
          'Available Rewards',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (widget.businessRewards.isEmpty)
          widgetFactory.createText(
            context,
            'No eligible rewards available.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          AppGridView(
            shrinkWrap: true,
            primary: false,
            itemExtent: 120,
            crossAxisCount: Responsive.getGridCount(context, itemWidth: 500),
            items: widget.businessRewards,
            itemBuilder: (context, item, index) => _buildRewardItem(context, widgetFactory, item),
          ),
      ],
    );
  }

  Widget _buildRewardItem(BuildContext context, WidgetFactory widgetFactory, Reward reward) {
    var borderColor = selectedReward?.id == reward.id ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline;
    return widgetFactory.createCard(
      onTap: () {
        setState(() {
          selectedReward = reward;
        });
      },
      borderRadius: BorderRadius.circular(8),
      padding: const EdgeInsets.all(12),
      border: Border.all(color: borderColor),
      child: Stack(
        children: [
          Positioned.fill(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widgetFactory.createText(context, reward.name.localize(widget.selectedLanguage), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              widgetFactory.createText(
                context,
                reward.discountAmount?.toString() ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ).withPaddingSymetric(vertical: 16)),
          Positioned(top: 0, right: 4, child: widgetFactory.createText(context, reward.redeemPointString(showMinus: true)))
        ],
      ),
    );
  }

  bool showApplyButton() {
    return selectedReward != null;
  }
}
