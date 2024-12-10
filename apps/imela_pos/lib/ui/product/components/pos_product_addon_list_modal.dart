import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/product/components/addon_viewmodel.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class PosProductAddonModal extends StatefulWidget {
  final List<ProductAddon> productAddons;
  final List<OrderConfig> initialConfigs;
  final Customer? customer;
  final String callToAction;
  const PosProductAddonModal({
    super.key,
    required this.productAddons,
    this.initialConfigs = const [],
    this.customer,
    this.callToAction = 'Finish',
  });

  @override
  State<PosProductAddonModal> createState() => _PosProductAddonModalState();
}

class _PosProductAddonModalState extends State<PosProductAddonModal> {
  final viewmodel = ProductAddonViewmodel.getInstance();
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewmodel.initViewmodel(data: {'PRODUCT_ADDONS': widget.productAddons});
    viewmodel.addInitialOrderConfigs(widget.initialConfigs);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Product Add-ons/Configurations', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Obx(() {
            return AppListView(
              shrinkWrap: true,
              items: viewmodel.noDefaultAddons,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              itemBuilder: (context, addon, index) {
                return Obx(() => _buildAddonListItem(context, addon));
              },
            );
          }),
          Obx(
            () => widgetFactory
                .createButton(
                  context: context,
                  content: Text(widget.callToAction),
                  onPressed: viewmodel.isOrderconfigContainsRequiredAddon
                      ? () {
                          viewmodel.closeAdddonConfigModalWithResult(context);
                        }
                      : null,
                )
                .withPaddingSymetric(horizontal: 16, vertical: 24),
          )
        ],
      ),
    );
  }

  Widget _buildAddonListItem(BuildContext context, ProductAddon addon) {
    final canEnableAddon = addon.canEnableAddon(
      selectedQty: viewmodel.selectedQty.value,
      isUserMembershipvalid: widget.customer?.isCustomerAMember(addon.membershipIds?.firstOrNull, viewmodel.appViewmmodel.allMemberships) ?? false
    );
    final borderColor = canEnableAddon ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer;
    final addonMultiplier = viewmodel.getAddonAdditionalPriceMultiplier(addon);
    return Stack(
      children: [
        widgetFactory.createCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AbsorbPointer(
                absorbing: !canEnableAddon,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widgetFactory.createText(context, addon.name.localize(viewmodel.selectedLanguage), style: Theme.of(context).textTheme.bodyLarge),
                          widgetFactory.createText(context, addon.getTotalAdditionalPriceString(viewmodel.appViewmmodel.selectedCurrency, qty: addonMultiplier)),
                        ],
                      ), 
                    ),
                    viewmodel.getAddonModifierUI(context, addon),
                  ],
                ),
              ),
              if (addon.membershipIds?.isNotEmpty == true) ...[
                const Divider(height: 24),
                _buildCustomerSelectionButton(context, addon),
                const SizedBox(height: 16),
              ]
            ],
          ),
        ),
        if (addon.membershipIds?.isNotEmpty == true)
          Positioned(
            left: 1,
            bottom: 1,
            child: BadgeList(
              height: 16,
              widgetFactory: widgetFactory,
              values: const ['For members only'],
              colors: [Theme.of(context).colorScheme.tertiary],
            ),
          ),
      ],
    );
  }

  Widget _buildCustomerSelectionButton(BuildContext context, ProductAddon addon) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widgetFactory.createText(context, 'Selected customer', style: Theme.of(context).textTheme.labelSmall),
              if (widget.customer != null) widgetFactory.createText(context, widget.customer!.name, style: Theme.of(context).textTheme.titleSmall) else widgetFactory.createText(context, 'Select customer to continue', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        widgetFactory.createButton(
          context: context,
          content: const Text('Select'),
          style: AppButtonStyle.textButtonStyle(context, color: Theme.of(context).colorScheme.secondary),
          onPressed: () {
            viewmodel.membershipCustomersDialog(context, addon.membershipIds!.first);
          },
        ),
      ],
    );
  }
}
