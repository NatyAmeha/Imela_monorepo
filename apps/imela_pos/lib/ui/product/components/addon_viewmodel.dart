import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/settings/model/location.model.dart';
import 'package:imela_core/settings/setting_usecase.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/customer/component/search_customer_list_modal.dart';
import 'package:imela_pos/ui/product/components/location_selector/location.viewmodel.dart';
import 'package:imela_pos/ui/product/components/pos_product_addon_details.modal.dart';
import 'package:imela_ui_kit/components/location_selector/location_list_modal.dart';
import 'package:imela_ui_kit/components/location_selector/location_search.dart';
import 'package:imela_ui_kit/components/qty_modifier.component.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';

import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/date_utils.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';

@injectable
class ProductAddonViewmodel extends GetxController with BaseViewmodel {
  // final Paymentusec businessUsecase;
  final SettingUsecase settingUsecase;
  final IExceptiionHandler exceptiionHandler;

  ProductAddonViewmodel({
    required this.settingUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static ProductAddonViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<ProductAddonViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var productAddons = <ProductAddon>[].obs;
  var selectedAddonOptions = <String, List<ProductAddonOption>>{}.obs;
  final orderConfigs = <String, OrderConfig>{}.obs;

  var additionalProductOrderItems = <String, List<OrderItem>>{};
  var selectedProductQty = <String, double>{}.obs;

  var savedLocations = <Location>[].obs;
  var selectedLocation = Rxn<Location>();

  var selectedQty = 1.0.obs;
  var requiredAddonsId = <String>{}.obs;

  // getters
  AppViewmodel get appViewmmodel => AppViewmodel.getInstance();
  LocationViewmodel get locationSelectorViewmodel => getIt<LocationViewmodel>();
  String get selectedLanguage => appViewmmodel.selectedLanguage;

  List<ProductAddon> get noDefaultAddons => productAddons.value.where((e) => e.inputType != AddonInputType.NONE.name).toList();

  bool get isOrderconfigContainsRequiredAddon {
    if (requiredAddonsId.isEmpty) return true;
    return requiredAddonsId.every((addonId) => orderConfigs.containsKey(addonId));
  }

  BuildContext? context;
  Product? parentProduct;

  List<String> selectedAddonOptionsId(String addonId) => (selectedAddonOptions[addonId] ?? []).map((e) => e.id).toList().whereType<String>().toList();

  double getSelectedProductQty(String productId) => selectedProductQty[productId] ?? 0;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () {
      context = data?['context'];
      parentProduct = data?['parentProduct'];
      requiredAddonsId.clear();
      addProductAddon(data?['PRODUCT_ADDONS']);
    });
  }

  void addProductAddon(List<ProductAddon>? addons) {
    productAddons.clear();
    if (addons == null) return;
    productAddons.addAll(addons);
    requiredAddonsId.addAll(addons.getRequiredAddonsId());
    getUserSavedLocations();
  }

  Future<void> getUserSavedLocations() async {
    var locationsFromDb = await settingUsecase.getUserSavedLocations("POS_DB"); // AppConstants.APP_DB_NAME);
    savedLocations.value = locationsFromDb;
  }

  void addInitialOrderConfigs(List<OrderConfig> initialOrderConfigs) {
    // orderConfigs.clear();

    for (var config in initialOrderConfigs) {
      orderConfigs[config.addonId!] = config;
    }
  }

  void selectAddonOption(BuildContext context, ProductAddon addon, String? optionId) {
    print('selectAddonOption ${addon.id} ${optionId}');
    var option = addon.options.firstWhere((element) => element.id == optionId);
    if (!selectedAddonOptions.containsKey(addon.id)) {
      selectedAddonOptions[addon.id!] = [];
    }
    if (addon.inputType == AddonInputType.SINGLE_SELECTION_INPUT.name) {
      selectedAddonOptions[addon.id!] = [option];
    } else if (addon.inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name) {
      if (selectedAddonOptions[addon.id!]!.contains(option)) {
        selectedAddonOptions[addon.id!]!.remove(option);
      } else {
        selectedAddonOptions[addon.id!]!.add(option);
      }
    }

    final selectedAddonOptionsId = (List<ProductAddonOption>.from(selectedAddonOptions[addon.id!] ?? []).map((e) => e.id)).whereType<String>().distinctBy((e) => e).toList();
    if (selectedAddonOptionsId.isEmpty) {
      if (addon.isRequired) {
        AppViewmodel.getWidgetFactory(context).showFlashMessage(context, message: 'This field is required');
        return;
      }
      orderConfigs.remove(addon.id!);
    } else {
      orderConfigs[addon.id!] = OrderConfig(
        name: addon.name,
        type: addon.inputType,
        calendarId: addon.calendarId,
        singleValue: addon.inputType == AddonInputType.SINGLE_SELECTION_INPUT.name ? selectedAddonOptionsId.first : null,
        multipleValue: addon.inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name ? selectedAddonOptionsId : null,
        addonId: addon.id,
        additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
      );
    }

    orderConfigs.refresh();
    selectedAddonOptions.refresh();
  }

  bool isAddonSelectable(ProductAddon addon) {
    return addon.inputType == AddonInputType.SINGLE_SELECTION_INPUT.name || addon.inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name;
  }

  void showAddonOptionsDialog(BuildContext context, ProductAddon addon) {
    const pageId = 'product_option_dialog';
    AppModalSheet.addPageToModal(
      context,
      ModalContent(
        id: pageId,
        title: const Text('Select options'),
        content: PosProductAddonDetailsModal(
          addon: addon,
          selectedLanguage: selectedLanguage,
          widgetFactory: AppViewmodel.getWidgetFactory(context),
          onSelectionFinished: () {
            AppModalSheet.previousPage(pageIdtoremove: pageId);
          },
        ),
      ),
    );
  }

  // Addon's product list relted logics

  var selectedProductsFromAddon = <Product>[].obs;
  var selectedDiscoungtedProductsFromAddons = <Product>[].obs;

  void showProductSelectionDialog(BuildContext context, ProductAddon addon, {Product? parentProductInfo}) {
    // const pageId = 'product_list_addon_dialog';
    // final addonDiscounts = parentProductInfo?.getAddonDiscounts(addon.id!) ?? [];
    // AppModalSheet.addPageToModal(
    //   context,
    //   ModalContent(
    //     id: pageId,
    //     title: const Text('Select Product'),
    //     content: Obx(
    //       () => AddonProductSelectorModal(
    //         addon: addon,
    //         qtyInfo: selectedProductQty.value,
    //         widgetFactory: appViewmmodel.getWidgetFactory(context),
    //         selectedProducts: addon.inputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name ? selectedDiscoungtedProductsFromAddons.value : selectedProductsFromAddon.value,
    //         discounts: addonDiscounts,
    //         isSelected: (product) => isProductdFromAddonIsSelected(addon.inputType, product),
    //         addOrRemoveProductFromAddon: (cont, addon, product) {
    //           addOrRemoveProductFromAddon(cont, addon, product);
    //         },
    //         onFinish: (modalContext) {
    //           AppModalSheet.previousPage(context: modalContext, pageIdtoremove: pageId);
    //         },
    //       ),
    //     ),
    //   ),
    // );
  }

  bool isProductdFromAddonIsSelected(String addonInputType, Product product) {
    if (addonInputType == AddonInputType.PRODUCT_SELECTION_INPUT.name) {
      return selectedProductsFromAddon.map((e) => e.id).contains(product.id);
    } else if (addonInputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name) {
      return selectedDiscoungtedProductsFromAddons.map((e) => e.id).contains(product.id);
    }
    return false;
  }

  Future<void> addOrRemoveProductFromAddon(BuildContext context, ProductAddon addon, Product product) async {
    if (isProductdFromAddonIsSelected(addon.inputType, product)) {
      if (addon.inputType == AddonInputType.PRODUCT_SELECTION_INPUT.name) {
        selectedProductsFromAddon.remove(product);
      } else if (addon.inputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name) {
        selectedDiscoungtedProductsFromAddons.remove(product);
      }
      applySelectedProductFromAddon(addon, selectedProductsFromAddon.value);
    } else {
      final selectedQty = await showQtyModifierModal(context, selectedProduct: product);
      selectedProductQty[product.id!] = selectedQty;
      if (addon.inputType == AddonInputType.PRODUCT_SELECTION_INPUT.name) {
        selectedProductsFromAddon.add(product);
      } else if (addon.inputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name) {
        selectedDiscoungtedProductsFromAddons.add(product);
      }
      applySelectedProductFromAddon(addon, selectedDiscoungtedProductsFromAddons.value);
    }
  }

  EdgeInsets getAddonListItemPadding(ProductAddon addon) {
    return addon.membershipIds?.isNotEmpty == true ? const EdgeInsets.symmetric(horizontal: 8, vertical: 16) : const EdgeInsets.symmetric(horizontal: 8, vertical: 8);
  }

  double getAddonAdditionalPriceMultiplier(ProductAddon addon) {
    if (addon.inputType == AddonInputType.QUANTITY_INPUT.name) {
      var selectedAmount = double.tryParse(orderConfigs.value[addon.id]?.singleValue ?? '${addon.minAmount}') ?? addon.minAmount;
      return selectedAmount;
    }
    return 1;
  }

  Widget getAddonModifierUI(BuildContext context, ProductAddon addon, {Product? parentProduct, bool enabled = false, Calendar? productCalendar, List<DateTime> disabledDatesForBooking = const []}) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    if (addon.inputType == AddonInputType.SINGLE_SELECTION_INPUT.name || addon.inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name) {
      final selectedAddonOptionNames = orderConfigs[addon.id]?.getSelectedAddonOptionNames(addon.options, selectedLanguage) ?? '';
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (orderConfigs[addon.id]?.singleValue != null || orderConfigs[addon.id]?.multipleValue != null) ...[
            widgetFactory.createText(context, selectedAddonOptionNames),
            const SizedBox(height: 2),
          ],
          widgetFactory.createButton(
            context: context,
            content: const Text('Select Options'),
            style: AppButtonStyle.textButtonStyle(context),
            onPressed: () {
              showAddonOptionsDialog(context, addon);
            },
          )
        ],
      );
    } else if ((addon.inputType == AddonInputType.PRODUCT_SELECTION_INPUT.name) || (addon.inputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          widgetFactory.createText(context, '${addon.inputType == AddonInputType.PRODUCT_SELECTION_INPUT.name ? selectedProductsFromAddon.length : selectedDiscoungtedProductsFromAddons.length}  selected'),
          const SizedBox(height: 2),
          widgetFactory.createButton(
            context: context,
            content: const Text('Choose'),
            style: AppButtonStyle.textButtonStyle(context),
            onPressed: () {
              showProductSelectionDialog(context, addon, parentProductInfo: parentProduct);
            },
          ),
        ],
      );
    } else if (addon.inputType == AddonInputType.QUANTITY_INPUT.name || addon.inputType == AddonInputType.NUMBER_INPUT.name) {
      return Obx(() {
        var selectedAmount = double.tryParse(orderConfigs.value[addon.id]?.singleValue ?? '${addon.minAmount}') ?? addon.minAmount;
        return QuantityModifierComponent(
          currentQty: selectedAmount,
          width: 150,
          widgetFactory: widgetFactory,
          addQtyDisabled: selectedAmount >= addon.maxAmount,
          deductQtyDisabled: selectedAmount <= addon.minAmount,
          onQtyChange: (qty) {
            applySelectedQtyToAddon(addon, qty);
          },
        );
      });
    } else if (addon.inputType == AddonInputType.DATE_RANGE_INPUT.name) {
      return Column(
        children: [
          Obx(() {
            if (orderConfigs[addon.id]?.multipleValue != null) {
              return widgetFactory.createText(context, '${orderConfigs[addon.id]?.multipleValue?.first} - ${orderConfigs[addon.id]?.multipleValue?.last}');
            }
            return const SizedBox();
          }),
          widgetFactory.createButton(
            context: context,
            content: const Text('Select Date Range'),
            style: AppButtonStyle.textButtonStyle(context),
            onPressed: () {
              return widgetFactory.createButton(
                context: context,
                content: const Text('Select'),
                style: AppButtonStyle.textButtonStyle(context),
                onPressed: () async {
                  final selectedDateRange = await widgetFactory.showDateRangePickerUI(
                    context,
                    firstDate: productCalendar?.fromDate,
                    lastDate: productCalendar?.toDate,
                  );
                  applySelectedDateRange(addon, selectedDateRange);
                },
              );
            },
          ),
        ],
      );
    } else if (addon.inputType == AddonInputType.DATE_INPUT.name || addon.inputType == AddonInputType.DATE_TIME_INPUT.name) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Obx(() {
            return orderConfigs[addon.id]?.singleValue?.isNotEmpty ?? false ? widgetFactory.createText(context, '${orderConfigs[addon.id]?.singleValue}', style: Theme.of(context).textTheme.bodyLarge) : const SizedBox();
          }),
          widgetFactory.createButton(
            context: context,
            content: widgetFactory.createText(
              context,
              orderConfigs[addon.id]?.singleValue != null ? 'Change Date' : 'Select Date',
              style: Theme.of(context).textTheme.bodySmall,
              color: Theme.of(context).colorScheme.secondary,
            ),
            style: AppButtonStyle.textButtonStyle(
              context,
              padding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onPressed: () async {
              final selectedDate = await widgetFactory.showDateTimePicker(context, initialDate: productCalendar?.fromDate ?? DateTime.now(), firstDate: productCalendar?.fromDate, lastDate: productCalendar?.toDate, disabledDates: disabledDatesForBooking, showTiimePicker: addon.inputType == AddonInputType.DATE_TIME_INPUT.name);
              applySelectedDate(addon, selectedDate);
            },
          ),
        ],
      );
    } else if (addon.inputType == AddonInputType.LOCATION_PER_KM_INPUT.name || addon.inputType == AddonInputType.LOCATION_INPUT.name) {
      return widgetFactory.createButton(
        context: context,
        content: widgetFactory.createText(
          context,
          orderConfigs[addon.id]?.singleValue?.isNotEmpty ?? false ? '${orderConfigs[addon.id]?.singleValue}' : 'Choose Location',
          style: Theme.of(context).textTheme.bodySmall,
          color: Theme.of(context).colorScheme.secondary,
          maxLines: 2,
        ),
        style: AppButtonStyle.textButtonStyle(
          context,
          padding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onPressed: () async {
          showLocationSelectorModal(context, addon);
        },
      );
    }
    orderConfigs.refresh();
    return const SizedBox();
  }

  void showLocationSelectorModal(BuildContext context, ProductAddon addon) {
    final locationSelecctionPageId = UniqueKey().toString();
    AppModalSheet.addPageToModal(
      context,
      ModalContent(
        id: locationSelecctionPageId,
        title: const Text('Choose Location'),
        content: Obx(
          () => LocationListModal(
            widgetFactory: AppViewmodel.getWidgetFactory(context),
            title: 'Saved Locations',
            locations: savedLocations.value,
            selectedLocation: selectedLocation.value,
            onLocationSelected: (cont, location) async {
              selectedLocation.value = location;
              applySelectedLocation(cont, addon, location);
              await settingUsecase.saveUserLocation(location, "POS_DB");
            },
            onAddLocation: (comcontext) async {
              final locationSearchPageId = UniqueKey().toString();
              AppModalSheet.addPageToModal(
                comcontext,
                ModalContent(
                  id: locationSearchPageId,
                  title: const Text('Search your locatioin'),
                  content: Obx(
                    () => LocationSearch(
                      widgetFactory: AppViewmodel.getWidgetFactory(comcontext),
                      locationInputController: TextEditingController(),
                      onLocationSelected: (location) {},
                      isLoading: locationSelectorViewmodel.isLoading.value,
                      searchResults: locationSelectorViewmodel.searchResults.value,
                      onLocationInputChange: (query) {
                        locationSelectorViewmodel.searchPlaces(query);
                      },
                      onLocationInfoSelected: (context, locationInfo) {
                        savedLocations.add(Location(name: locationInfo.name, latLng: locationInfo.location));
                        AppModalSheet.previousPage(context: context);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void applySelectedQtyToAddon(ProductAddon addon, double qty) {
    selectedQty.value = qty;
    orderConfigs[addon.id!] = OrderConfig(
      name: addon.name,
      type: addon.inputType,
      singleValue: qty.toString(),
      addonId: addon.id,
      calendarId: addon.calendarId,
      additionalPrice: addon.getTotalAdditionalPrice('ETB', qty: qty),
    );
  }

  void applySelectedDateRange(ProductAddon addon, DateTimeRange? dateRange) {
    if (dateRange == null) return;
    orderConfigs[addon.id!] = OrderConfig(
      name: addon.name,
      type: addon.inputType,
      multipleValue: [dateRange!.start.toFormattedString(), dateRange.end.toFormattedString()],
      addonId: addon.id,
      additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
    );
  }

  void applySelectedDate(ProductAddon addon, DateTime? date) {
    if (date == null) return;
    orderConfigs[addon.id!] = OrderConfig(
      name: addon.name,
      type: addon.inputType,
      singleValue: date.toFormattedString(),
      addonId: addon.id,
      calendarId: addon.calendarId,
      additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
    );
  }

  void applySelectedLocation(BuildContext context, ProductAddon addon, Location? location) {
    if (location == null) return;
    orderConfigs[addon.id!] = OrderConfig(
      name: addon.name,
      type: addon.inputType,
      singleValue: location.name,
      addonId: addon.id,
      calendarId: addon.calendarId,
      additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
    );
    orderConfigs.refresh();
    AppModalSheet.previousPage(context: context);
  }

  void applySelectedProductFromAddon(ProductAddon addon, List<Product> products) {
    if (addon.inputType == AddonInputType.PRODUCT_SELECTION_INPUT.name) {
      orderConfigs[addon.id!] = OrderConfig(
        name: addon.name,
        type: addon.inputType,
        productIds: products.map((e) => e.id!).toList(),
        calendarId: addon.calendarId,
        addonId: addon.id,
        additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
      );
    } else if (addon.inputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name) {
      final addonDiscounts = parentProduct!.getAddonDiscounts(addonId: addon.id!, selectedLanguage: selectedLanguage, parentProduct: parentProduct!);
      additionalProductOrderItems[addon.id!] = products.map((product) {
        final selectedQty = getSelectedProductQty(product.id!);
        return product.getOrderItem(selectedQty, discounts: addonDiscounts);
      }).toList();
    }
  }

  Future<double> showQtyModifierModal(BuildContext context, {Product? selectedProduct, int minQty = 1, int maxQty = 10}) async {
    double? basePrice = selectedProduct?.getTotalPriceUpdated('ETB', qtyInput: 1, discounts: []);
    // final qtyResult = await AppModalSheet.showModal(
    //   context,
    //   type: AppModalSheetType.DIALOG,
    //   pages: [
    //     ModalContent(
    //       title: const Text('Modify Quantity'),
    //       content: ProductDynamicPricing(
    //         dynamicPricingDiscounts: parentProduct!.sortedDynamicPricingDiscounts,
    //         basePrice: basePrice!,
    //         product: selectedProduct!,
    //         minQty: minQty.toDouble(),
    //         maxQty: maxQty.toDouble(),
    //         showFinishBtn: true,
    //         onFinish: (modalContext, qty) {
    //           AppModalSheet.closeModal(context: modalContext, result: qty);
    //         },
    //       ),
    //     )
    //   ],
    // );
    // return qtyResult;
    return 1;
  }

  void closeAdddonConfigModalWithResult(BuildContext context, {double? selectedQty}) {
    if (selectedQty != null) {
      orderConfigs[OrderConfig.QTY_CONFIG_ID] = OrderConfig.createQtyOrderConfig(selectedQty);
    }

    var configs = orderConfigs.values.toList();
    final result = AddonConfig(orderConfigs: configs, additionalItems: additionalProductOrderItems.values.flattened.toList());
    AppModalSheet.closeModal(context: context, result: result);
    orderConfigs.clear();
    selectedProductsFromAddon.clear();
    additionalProductOrderItems.clear();
    selectedDiscoungtedProductsFromAddons.clear();
    refresh();
  }

  void updateQty(double qty) {
    selectedQty.value = qty;
  }

  void membershipCustomersDialog(BuildContext context, String membershipId) {
    const pageId = 'membership_customers_dialog';
    AppModalSheet.addPageToModal(
      context,
      ModalContent(
        id: pageId,
        title: const Text('Members'),
        content: SearchCustomerListModal(
          showCustomerCreate: false,
          customers: appViewmmodel.getMemberCustomers(membershipId),
          selectedCustomer: appViewmmodel.selectedCustomer.value,
          onCustomerSelected: (modalContext, selectedCustomer) {
            appViewmmodel.setSelectedCustomer(selectedCustomer);
            AppModalSheet.previousPage(context: modalContext, pageIdtoremove: pageId);
          },
        ),
      ),
    );
  }
}
