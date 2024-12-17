import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/product/components/addon_viewmodel.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

import 'package:imela_ui_kit/components/qty_modifier/product_dynamic_pricing.dart';

class PosProductAddonModal extends StatefulWidget {
  final Product? product;
  final List<ProductAddon> productAddons;
  final List<OrderConfig> initialConfigs;
  final Customer? customer;
  final String callToAction;
  const PosProductAddonModal({
    super.key,
    this.product,
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
    viewmodel.initViewmodel(data: {'PRODUCT_ADDONS': widget.productAddons, 'parentProduct': widget.product});
    viewmodel.addInitialOrderConfigs(widget.initialConfigs);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => AbsorbPointer(
          absorbing: viewmodel.isLoading.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Product Add-ons/Configurations', style: Theme.of(context).textTheme.titleLarge),
              if (viewmodel.isLoading.value) ...[
                const LinearProgressIndicator(),
              ],
              if (widget.product != null) ...[
                ProductDynamicPricing(
                  product: widget.product!,
                  widgetFactory: widgetFactory,
                  initialQty: widget.product!.minimumOrderQty.toDouble(),
                  selectedCurrency: viewmodel.appViewmmodel.selectedCurrency,
                  basePrice: widget.product!.getTotalPriceUpdated(viewmodel.appViewmmodel.selectedCurrency),
                  dynamicPricingDiscounts: widget.product!.sortedDynamicPricingDiscounts,
                  haveDynamicPricing: widget.product!.haveDynamicPricing,
                  width: double.infinity,
                  onQtyChange: (qty) {
                    viewmodel.updateQty(qty);
                  },
                ),
              ],
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
                              viewmodel.closeAdddonConfigModalWithResult(context, selectedQty: viewmodel.selectedQty.value);
                            }
                          : null,
                    )
                    .withPaddingSymetric(horizontal: 16, vertical: 24),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddonListItem(BuildContext context, ProductAddon addon) {
    var ismembershipValid = widget.customer?.isCustomerAMember(addon.membershipIds?.firstOrNull, viewmodel.appViewmmodel.allMemberships) ?? false;
    final canEnableAddon = addon.canEnableAddon(selectedQty: viewmodel.selectedQty.value, isUserMembershipvalid: ismembershipValid);
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Expanded(child: viewmodel.getAddonModifierUI(context, addon)),
                  ],
                ),
              ),
              if (addon.description?.isNotEmpty == true) ...[
                widgetFactory.createText(context, addon.description.localize(viewmodel.selectedLanguage), style: Theme.of(context).textTheme.bodySmall),
              ],
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
              height: 20,
              widgetFactory: widgetFactory,
              widgets: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ismembershipValid ? Icons.check : Icons.lock_open,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    widgetFactory.createText(context, 'For members only', style: Theme.of(context).textTheme.labelSmall, color: Colors.white),
                  ],
                ),
              ],
              colors: [ismembershipValid ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onTertiary],
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
