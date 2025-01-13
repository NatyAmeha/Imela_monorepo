import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/app/app_constants.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/location_selector/components/location_list_modal.dart';
import 'package:imela/presentation/ui/product/components/dynamic_price_viewmodel.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/addon_product_selector_modal.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/addon_viewmodel.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/pos_product_addon_details.modal.dart';
import 'package:imela/presentation/ui/product/components/product_dynamic_pricing.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/components/calendar/date_range_picker.dart';
import 'package:imela_ui_kit/components/calendar/date_time_picker.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/helpers/number_utils.dart';

class ProductAddonModal extends StatefulWidget {
  final List<ProductAddon> productAddons;
  final List<OrderConfig> initialOrderConfigs;
  final bool showqtyModfier;
  final Product? productInfo;
  final Product? parentProductInfo;
  final List<Discount> discounts;
  final double totalPrice; // used to check if the addon can be enabled for cart config
  final List<Calendar>? productCalendars;
  final List<SelectedRewardInfo> selectedRewards;
  // final List<DateTime>? disabledDatesForBooking;
  final double minQty;
  final double maxQty;
  final String callToAction;
  final bool resetQty;
  final Function? onPageChange;
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
    this.selectedRewards = const [],
    // this.disabledDatesForBooking = const [],
    this.minQty = 1,
    this.maxQty = 10,
    this.callToAction = 'Finish',
    this.resetQty = true,
    this.onPageChange,
  });

  @override
  State<ProductAddonModal> createState() => _ProductAddonModalState();
}

class _ProductAddonModalState extends State<ProductAddonModal> {
  final viewmodel = ProductAddonViewmodel.getInstance();
  final dynamicPriceViewmodel = DynamicPriceViewmodel.getInstance();
  late WidgetFactory widgetFactory;
  late var currentPage = 0.obs;

  // Group addons by type

  @override
  void initState() {
    super.initState();
    print('widget init started');
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
    viewmodel.initViewmodel(data: {
      'context': context,
      'productAddons': widget.productAddons,
      'parentProduct': widget.parentProductInfo,
      'selectedRewards': widget.selectedRewards,
      'resetQty': widget.resetQty,
      'initialQty': widget.minQty,
      'SHOW_PRODUCT_QTY_MODIFIER': widget.showqtyModfier,
      'INITIAL_ORDER_CONFIGS': widget.initialOrderConfigs,
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Configurations'),
          leading: Obx(
            () => viewmodel.selectedAddonConfigPageIndex.value > 0
                ? IconButton(
                    onPressed: () {
                      viewmodel.backToPreviousAddonConfigPage(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                  )
                : const SizedBox.shrink(),
          ),
          actions: [
            IconButton(
              onPressed: () {
                viewmodel.closeAddonConfigModal(context);
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        body: Column(
          children: [
            Obx(() => viewmodel.isLoading.value ? const LinearProgressIndicator() : const SizedBox.shrink()),

            // PageView content
            Expanded(
              child: Obx(
                () => PageView.builder(
                  controller: viewmodel.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    currentPage.value = page;
                  },
                  itemCount: viewmodel.pageLength,
                  itemBuilder: (context, index) {
                    if (index == 0 && viewmodel.showProductQtyModifier.value) {
                      return buildQtyAddonsList();
                    }
                    return IgnorePointer(
                      ignoring: !viewmodel.isPassingMembershipCheck(viewmodel.nonQtyAddons[viewmodel.getAddonIndex(index)]),
                      child: buildNonQtyAddonsList(viewmodel.getAddonIndex(index)),
                    );
                  },
                ),
              ),
            ),

            // Bottom navigation
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // if (currentPage.value > 0)
                  //   Expanded(
                  //     child: widgetFactory.createButton(
                  //       context: context,
                  //       content: const Text('Previous'),
                  //       onPressed: () {
                  //         _pageController.previousPage(
                  //           duration: const Duration(milliseconds: 300),
                  //           curve: Curves.easeInOut,
                  //         );
                  //       },
                  //     ),
                  //   ),

                  Expanded(
                    child: Obx(
                      () => widgetFactory.createButton(
                        context: context,
                        content: const Text('Continue'),
                        onPressed: !viewmodel.isLoading.value && viewmodel.canGoToNextAddonConfigPage.value
                            ? () {
                                viewmodel.handleAddonConfigPageChange(context, showQtyModifier: true, selectedQty: dynamicPriceViewmodel.selectedQty.value);
                              }
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQtyAddonsList() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            if (viewmodel.showProductQtyModifier.value)
              ProductDynamicPricing(
                dynamicPricingDiscounts: widget.parentProductInfo?.sortedDynamicPricingDiscounts ?? widget.productInfo?.sortedDynamicPricingDiscounts ?? [],
                basePrice: widget.productInfo?.getTotalPriceUpdated('ETB', qtyInput: 1, discounts: []) ?? 0,
                product: widget.productInfo!,
                minQty: widget.minQty,
                maxQty: widget.maxQty,
                initialQty: widget.minQty,
                onQtyChange: (qty) {
                  viewmodel.setProductQtyAddon(qty);
                },
              ),
            const Divider(height: 24),
            AppListView(
              items: viewmodel.quantityAddons,
              shrinkWrap: true,
              separator: const SizedBox(height: 16),
              itemBuilder: (context, item, index) {
                return Obx(() => _buildPageContent(item));
              },
            ),
          ],
        ).paddingSymmetric(horizontal: 10));
  }

  Widget buildNonQtyAddonsList(int index) {
    var selectedAddon = viewmodel.nonQtyAddons[index];
    late Widget addonWidget;
    if (selectedAddon.inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name || selectedAddon.inputType == AddonInputType.SINGLE_SELECTION_INPUT.name) {
      addonWidget = ProductAddonDetailsModal(
        addon: selectedAddon,
        selectedLanguage: viewmodel.selectedLanguage,
        widgetFactory: widgetFactory,
        onSelectionFinished: (context) {
          widget.onPageChange?.call();
        },
      );
    } else if (selectedAddon.inputType == AddonInputType.DATE_RANGE_INPUT.name) {
      addonWidget = buildDateRangePicker(selectedAddon);
    } else if (selectedAddon.inputType == AddonInputType.DATE_INPUT.name || selectedAddon.inputType == AddonInputType.DATE_TIME_INPUT.name) {
      addonWidget = buildDatePicker(selectedAddon);
    } else if (selectedAddon.inputType == AddonInputType.PRODUCT_SELECTION_INPUT.name || selectedAddon.inputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name) {
      addonWidget = buildProductSelection(selectedAddon);
    } else if (selectedAddon.inputType == AddonInputType.LOCATION_INPUT.name || selectedAddon.inputType == AddonInputType.LOCATION_PER_KM_INPUT.name) {
      addonWidget = buildLocationAddonList(selectedAddon);
    } else {
      addonWidget = const SizedBox();
    }
    final additionalPrice = selectedAddon.getAddonPriceUpdated(viewmodel.selectedCurrency, orderConfigs: viewmodel.orderConfigs.value, selectedRewards: widget.selectedRewards);
    return Column(
      children: [
        const SizedBox(height: 16),
        buildAddonHeader(selectedAddon),
        const SizedBox(height: 16),
        addonWidget,
        if (additionalPrice > 0) ...[
          const SizedBox(height: 4),
          buildAdditionalPrice(additionalPrice).paddingSymmetric(horizontal: 8),
        ]
      ],
    ).paddingSymmetric(horizontal: 10);
  }

  Widget buildDateRangePicker(ProductAddon addon) {
    final disabledDatesForBooking = viewmodel.addonsWithDisabledDates[addon.id];
    return Expanded(
      child: DateRangePicker(
        firstDate: disabledDatesForBooking?.firstDate,
        lastDate: disabledDatesForBooking?.lastDate,
        initialDateRange: viewmodel.orderConfigs.value[addon.id]?.getConfigDateRange(),
        disabledDates: disabledDatesForBooking?.disabledDates ?? [],
        minDays: addon.minAmount.toInt(),
        maxDays: addon.maxAmount.toInt(),
        showHeader: false,
        enablePastDates: false,
        showTodayButton: false,
        onError: (error) {
          viewmodel.applySelectedDateRange(addon, null);
          widgetFactory.showFlashMessage(context, message: error);
        },
        onConfirm: (dateRange) {
          viewmodel.applySelectedDateRange(addon, dateRange);
          widget.onPageChange?.call(currentPage.value);
        },
      ),
    );
  }

  Widget buildDatePicker(ProductAddon addon) {
    final disabledDatesForBooking = viewmodel.addonsWithDisabledDates[addon.id];
    return Expanded(
      child: DateTimePicker(
        firstDate: disabledDatesForBooking?.firstDate,
        lastDate: disabledDatesForBooking?.lastDate,
        enableMultiSelect: addon.inputType == AddonInputType.MULTIPLE_DATE_INPUT.name,
        initialDate: viewmodel.orderConfigs.value[addon.id]?.getConfigDate(),
        minSelections: addon.minAmount.toInt(),
        maxSelections: addon.maxAmount.toInt(),
        disabledDates: disabledDatesForBooking?.disabledDates ?? [],
        showTimePicker: addon.inputType == AddonInputType.DATE_TIME_INPUT.name,
        showHeader: false,
        showTodayButton: false,
        onError: (error) {
          widgetFactory.showFlashMessage(context, message: error);
        },
        onConfirm: (dates) {
          viewmodel.applySelectedDate(addon, dates);
        },
      ),
    );
  }

  Widget buildProductSelection(ProductAddon addon) {
    return Obx(
      () => AddonProductSelectorModal(
        addon: addon,
        qtyInfo: viewmodel.selectedProductQty.value,
        widgetFactory: widgetFactory,
        selectedProducts: addon.inputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name ? viewmodel.selectedDiscoungtedProductsFromAddons.value : viewmodel.selectedProductsFromAddon.value,
        isSelected: (product) => viewmodel.isProductdFromAddonIsSelected(addon.inputType, product),
        addOrRemoveProductFromAddon: (cont, addon, productOptionInfo) {
          viewmodel.addOrRemoveProductFromAddon(cont, addon, productOptionInfo);
        },
        onFinish: (modalContext) {
          // viewmodel.applySelectedProductFromAddon(addon, List.from(viewmodel.selectedProductsFromAddon.value));
        },
      ),
    );
  }

  Widget buildLocationAddonList(ProductAddon addon) {
    return Obx(
      () => Expanded( 
        child: LocationListModal(
          widgetFactory: widgetFactory,
          title: 'Saved Locations',
          locations: viewmodel.savedLocations.value,
          selectedLocation: viewmodel.selectedLocation.value,
          onLocationSelected: (cont, location) async {
            viewmodel.applySelectedLocation(cont, addon, location);
          },
          onAddLocation: (comcontext) async {
            viewmodel.addLocationSearchPage(comcontext, addon);
          },
        ),
      ),
    );
  }

  Widget buildAddonHeader(ProductAddon addon) {
    return widgetFactory.createCard(
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      elevation: 4,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: widgetFactory.createText(context, addon.name.localize(viewmodel.selectedLanguage), style: Theme.of(context).textTheme.titleMedium)),
              const SizedBox(width: 8),
              BadgeListTile(
                widgetFactory: widgetFactory,
                color: Theme.of(context).colorScheme.tertiary,
                height: 25,
                value: addon.isOptionalOrRequiredString(viewmodel.selectedLanguage),
              ),
            ],
          ),
          const Divider(),
          if (addon.description != null) widgetFactory.createText(context, addon.description!.localize(viewmodel.selectedLanguage), style: Theme.of(context).textTheme.bodySmall),
          if (addon.maxAmount > 1)
            Row(
              children: [
                widgetFactory.createText(context, 'Minimum - ${addon.minAmount}'),
                const SizedBox(width: 16),
                widgetFactory.createText(context, 'Maximum - ${addon.maxAmount}'),
              ],
            ),
          if (addon.membershipIds?.isNotEmpty == true) getMembershipBanner(addon),
        ],
      ),
    );
  }

  Widget buildAdditionalPrice(double additionalPrice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        widgetFactory.createText(context, 'Additional Price', style: Theme.of(context).textTheme.titleSmall),
        widgetFactory.createText(
          context,
          '+ ${viewmodel.selectedCurrency} ${additionalPrice.getPresisionString(precision: 2)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildPageContent(ProductAddon addon) {
    final canEnableAddon = addon.canEnableAddon(selectedQty: viewmodel.selectedQty.value, totalPrice: widget.totalPrice, isUserMembershipvalid: viewmodel.appViewmmodel.currentUserIsMember(addon.membershipIds));
    final borderColor = canEnableAddon ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer;
    final addonPrice = addon.getAddonPriceUpdated("ETB", orderConfigs: viewmodel.orderConfigs.value, selectedRewards: widget.selectedRewards);
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
                            if (addonPrice > 0)
                              widgetFactory.createText(
                                context,
                                '+ ${viewmodel.selectedCurrency} ${addonPrice.getPresisionString(precision: 2)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
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
                  const Divider(),
                  viewmodel.showRewardOnAddon(addon),
                ],
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: Row(
                children: [
                  if (addon.membershipIds?.isNotEmpty == true) getMembershipBanner(addon),
                ],
              ),
            ),
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
