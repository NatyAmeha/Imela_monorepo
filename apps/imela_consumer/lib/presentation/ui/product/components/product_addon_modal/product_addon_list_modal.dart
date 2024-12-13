import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/product/components/dynamic_price_viewmodel.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/addon_viewmodel.dart';
import 'package:imela/presentation/ui/product/components/product_dynamic_pricing.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductAddonModal extends StatefulWidget {
  final List<ProductAddon> productAddons;
  final List<OrderConfig> initialOrderConfigs;
  final bool showqtyModfier;
  final Product? productInfo;
  final Product? parentProductInfo;
  final List<Discount> discounts;
  final double totalPrice; // used to check if the addon can be enabled for cart config
  final List<Calendar>? productCalendars;
  // final List<DateTime>? disabledDatesForBooking;
  final double minQty;
  final double maxQty;
  final String callToAction;
  final bool resetQty;
  const ProductAddonModal({
    super.key,
    required this.productAddons,
    this.initialOrderConfigs = const [],
    this.parentProductInfo,
    this.showqtyModfier = false,
    this.productInfo,
    this.discounts = const [],
    this.totalPrice = 0,
    this.productCalendars,
    // this.disabledDatesForBooking = const [],
    this.minQty = 1,
    this.maxQty = 10,
    this.callToAction = 'Finish',
    this.resetQty = true,
  });

  @override
  State<ProductAddonModal> createState() => _ProductAddonModalState();
}

class _ProductAddonModalState extends State<ProductAddonModal> {
  final viewmodel = ProductAddonViewmodel.getInstance();
  final dynamicPriceViewmodel = DynamicPriceViewmodel.getInstance();
  late WidgetFactory widgetFactory;

  double? get basePrice => widget.productInfo?.getTotalPriceUpdated('ETB', qtyInput: 1, discounts: widget.discounts);

  @override
  void initState() {
    super.initState();
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
    viewmodel.initViewmodel(data: {
      'context': context,
      'productAddons': widget.productAddons,
      'parentProduct': widget.parentProductInfo,
      'resetQty': widget.resetQty,
      'initialQty': widget.minQty,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PageContentLoader(
        isDataLoading: viewmodel.isLoading.value,
        showContent: true,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Configurations', style: Theme.of(context).textTheme.titleLarge).withPaddingSymetric(horizontal: 16),
            if (widget.productInfo != null)
              widgetFactory.createCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: widgetFactory.createText(context, '${widget.productInfo?.name.localize(viewmodel.selectedLanguage)}', style: Theme.of(context).textTheme.titleSmall),
              ),
            const SizedBox(height: 10),
            if (widget.productInfo != null && widget.showqtyModfier == true)
              Obx(
                () => ProductDynamicPricing(
                  dynamicPricingDiscounts: widget.productInfo!.sortedDynamicPricingDiscounts,
                  basePrice: basePrice!,
                  initialQty: viewmodel.selectedQty.value,
                  product: widget.productInfo!,
                  minQty: widget.minQty,
                  maxQty: widget.maxQty,
                  onQtyChange: (qty) {
                    viewmodel.updateQty(qty);
                  },
                ),
              ),
            const Divider(height: 16),
            Obx(
              () => AppListView(
                primary: false,
                shrinkWrap: true,
                items: viewmodel.productAddons.value,
                separator: const Divider(),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, addon, index) {
                  return Obx(() {
                    final canEnableAddon = addon.canEnableAddon(selectedQty: viewmodel.selectedQty.value, totalPrice: widget.totalPrice, isUserMembershipvalid: viewmodel.appViewmmodel.currentUserIsMember(addon.membershipIds));
                    final borderColor = canEnableAddon ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondaryContainer;
                    return AbsorbPointer(
                      absorbing: !canEnableAddon, //||  !viewmodel.currentUserIsMember(addon.membershipIds),
                      child: SizedBox(
                        width: double.infinity,
                        child: Stack(
                          children: [
                            widgetFactory.createCard(
                              padding: viewmodel.getAddonListItemPadding(addon),
                              margin: addon.membershipIds?.isEmpty == true ? const EdgeInsets.symmetric(horizontal: 6) : null,
                              border: Border.all(color: borderColor),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(addon.name.localize(viewmodel.selectedLanguage), style: Theme.of(context).textTheme.titleSmall),
                                            if (addon.additionalPrice?.isNotEmpty == true) Text('Additional Price: ${addon.additionalPrice.toSelectedPriceString("ETB")}'),
                                          ],
                                        ),
                                      ),
                                      Expanded(child: viewmodel.getAddonModifierUI(context, addon, enabled: canEnableAddon, parentProduct: widget.parentProductInfo)),
                                    ],
                                  ),
                                  const Divider(),
                                  if (addon.description != null) Text(addon.description!.localize(viewmodel.selectedLanguage), style: Theme.of(context).textTheme.bodySmall),
                                  Row(
                                    children: [
                                      widgetFactory.createText(context, 'Minimum - ${addon.minAmount}'),
                                      const SizedBox(width: 16),
                                      widgetFactory.createText(context, 'Maximum - ${addon.maxAmount}'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              left: 0,
                              child: Row(
                                children: [
                                  if (addon.isRequired)
                                    widgetFactory.createCard(
                                      color: Theme.of(context).colorScheme.secondary,
                                      padding: const EdgeInsets.all(3),
                                      borderRadius: BorderRadius.only(topLeft: const Radius.circular(6)),
                                      child: widgetFactory.createText(context, addon.requiredString("ENGLISH"), style: Theme.of(context).textTheme.bodySmall),
                                    ),
                                  const Spacer(),
                                  if (!canEnableAddon) widgetFactory.createIcon(materialIcon: Icons.lock, color: Theme.of(context).colorScheme.primary, size: 20),
                                  if (addon.membershipIds?.isNotEmpty == true) getMembershipBanner(addon),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => widgetFactory
                  .createButton(
                    context: context,
                    content: Text(widget.callToAction),
                    onPressed: viewmodel.isOrderconfigContainsRequiredAddon
                        ? () {
                            final selectedQty = widget.showqtyModfier ? dynamicPriceViewmodel.selectedQty.value : null;
                            viewmodel.closeAdddonConfigModalWithResult(context, selectedQty: selectedQty);
                          }
                        : null,
                  )
                  .withPaddingSymetric(vertical: 16, horizontal: 16),
            )
          ],
        ),
      ),
    );
  }

  Widget getMembershipBanner(ProductAddon addon) {
    return widgetFactory.createCard(
      color: Theme.of(context).colorScheme.primary,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(4)),
      child: Row(
        children: [
          !viewmodel.appViewmmodel.currentUserIsMember(addon.membershipIds) ? widgetFactory.createIcon(materialIcon: Icons.lock, color: ColorManager.tertiary, size: 16) : widgetFactory.createIcon(materialIcon: Icons.check_circle, color: ColorManager.tertiary, size: 16),
          const SizedBox(width: 6),
          widgetFactory.createText(context, 'Members only', style: Theme.of(context).textTheme.bodySmall, color: Colors.white),
        ],
      ),
    );
  }
}
