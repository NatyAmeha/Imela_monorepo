import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/app/app_constants.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/location_selector/components/location_list_modal.dart';
import 'package:imela/presentation/ui/location_selector/location_selector_page.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/addon_product_selector_modal.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/pos_product_addon_details.modal.dart';
import 'package:imela/presentation/ui/product/components/product_dynamic_pricing.dart';
import 'package:imela/presentation/ui/shared/qty_modifier.component.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/order/order.usecase.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/settings/model/location.model.dart';
import 'package:imela_core/settings/setting_usecase.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';

import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/date_utils.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_core/calendar/usecase/calendar.usecase.dart';

@injectable
class ProductAddonViewmodel extends GetxController with BaseViewmodel {
  // final Paymentusec businessUsecase;
  final OrderUsecase orderUsecase;
  final CalendarUsecase calendarUsecase;

  final SettingUsecase settingUsecase;
  final IExceptiionHandler exceptiionHandler;

  ProductAddonViewmodel({
    required this.settingUsecase,
    required this.orderUsecase,
    required this.calendarUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static ProductAddonViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<ProductAddonViewmodel>());
  }

  PageController pageController = PageController();

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var productAddons = <ProductAddon>[].obs;
  var selectedAddonOptions = <String, List<ProductAddonOption>>{}.obs;
  final orderConfigs = <String, OrderConfig>{}.obs;
  var selectedAddonConfigPageIndex = 0.obs;
  var canGoToNextAddonConfigPage = false.obs;

  var showProductQtyModifier = true.obs;

  var additionalProductOrderItems = <String, List<OrderItem>>{};
  var selectedProductQty = <String, double>{}.obs;

  var selectedQty = 1.0.obs;
  var requiredQtyAddonsId = <String>{}.obs;

  var savedLocations = <Location>[].obs;
  var selectedLocation = Rxn<Location>();

  var selectedCalendars = <Calendar>[].obs;
  var addonsWithDisabledDates = <String, CalendarDateSelectorInfo>{}.obs;
  // getters
  AppController get appViewmmodel => AppController.getInstance;
  String get selectedLanguage => appViewmmodel.selectedLanguage.name;
  String get selectedCurrency => appViewmmodel.selectedCurrency.name;

  BuildContext? context;
  Product? parentProduct;
  List<SelectedRewardInfo> selectedRewards = [];

  bool get isOrderconfigContainsRequiredAddon {
    if (requiredQtyAddonsId.isEmpty) return true;
    return requiredQtyAddonsId.every((addonId) => orderConfigs.containsKey(addonId));
  }

  List<ProductAddon> get quantityAddons {
    var qtyBasedAdons = productAddons.value.getNonDependentAddons(orderConfigs: orderConfigs.value.values.toList()).where((addon) => addon.inputType == AddonInputType.NUMBER_INPUT.name || addon.inputType == AddonInputType.QUANTITY_INPUT.name).toList();
    return [...qtyBasedAdons];
  }

  List<ProductAddon> get nonQtyAddons {
    var nonQtyAddons = productAddons.value.getNonDependentAddons(orderConfigs: orderConfigs.value.values.toList()).where((addon) => addon.inputType != AddonInputType.NUMBER_INPUT.name && addon.inputType != AddonInputType.QUANTITY_INPUT.name).toList();
    return [...nonQtyAddons];
  }

  int get pageLength {
    if (quantityAddons.isNotEmpty || showProductQtyModifier.value) {
      return 1 + nonQtyAddons.length;
    }
    return nonQtyAddons.length;
  }

  List<String> selectedAddonOptionsId(String addonId) => (selectedAddonOptions[addonId] ?? []).map((e) => e.id!).toList();

  double getSelectedProductQty(String productId) => selectedProductQty[productId] ?? 0;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    context = data?['context'];
    final resetQty = data?['resetQty'];
    parentProduct = data?['parentProduct'];
    selectedRewards = data?['selectedRewards'];
    showProductQtyModifier.value = data?['SHOW_PRODUCT_QTY_MODIFIER'] ?? true;
    final initialQty = data?['initialQty'] ?? 1;
    if (resetQty) {
      selectedQty.value = initialQty.toDouble();
    }
    Future.delayed(Duration.zero, () {
      addonsWithDisabledDates.clear();
      addProductAddon(data?['productAddons'], data?['INITIAL_ORDER_CONFIGS'] as List<OrderConfig> ?? []);
      listenOrderConfigChange();
      applyDefaultQtyBasedAddonsToOrderConfigs();
    });
  }

  int getAddonIndex(int index) {
    if (showProductQtyModifier.value) {
      return index - 1;
    } else {
      return quantityAddons.isEmpty ? index : index - 1;
    }
  }

  void listenOrderConfigChange() {
    everAll([selectedAddonConfigPageIndex, orderConfigs], (value) {
      controlAddonNavigation();
    });
  }

  void controlAddonNavigation() {
    if (selectedAddonConfigPageIndex.value == 0) {
      var requiredQtyAddons = requiredQtyAddonsId.where((addonId) => quantityAddons.map((e) => e.id).contains(addonId));
      if (requiredQtyAddons.isEmpty) {
        canGoToNextAddonConfigPage.value = true;
      } else {
        canGoToNextAddonConfigPage.value = requiredQtyAddonsId.every((addonId) => orderConfigs.containsKey(addonId));
      }
    } else {
      var selectedAddon = nonQtyAddons[getAddonIndex(selectedAddonConfigPageIndex.value)];
      if (!selectedAddon.isRequired) {
        canGoToNextAddonConfigPage.value = true;
      } else {
        if (selectedAddon.inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name || selectedAddon.inputType == AddonInputType.SINGLE_SELECTION_INPUT.name) {
          canGoToNextAddonConfigPage.value = canEnableOptionSelection.value;
        } else if (selectedAddon.inputType == AddonInputType.DATE_RANGE_INPUT.name) {
          var configuredDateRange = orderConfigs[selectedAddon.id]?.getConfigDateRange();
          canGoToNextAddonConfigPage.value = configuredDateRange != null;
        } else if (selectedAddon.inputType == AddonInputType.DATE_INPUT.name || selectedAddon.inputType == AddonInputType.DATE_TIME_INPUT.name) {
          var configuredDate = orderConfigs[selectedAddon.id]?.singleValue;
          canGoToNextAddonConfigPage.value = configuredDate != null;
        } else if (selectedAddon.inputType == AddonInputType.PRODUCT_SELECTION_INPUT.name || selectedAddon.inputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name) {
          var productSelected = selectedAddon.inputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name ? selectedDiscoungtedProductsFromAddons.value : selectedProductsFromAddon.value;
          var canEnable = productSelected.isNotEmpty && productSelected.length <= selectedAddon.maxAmount && productSelected.length >= selectedAddon.minAmount;
          canGoToNextAddonConfigPage.value = canEnable;
        }
      }
    }
  }

  bool isPassingMembershipCheck(ProductAddon addon) {
    if (addon.membershipIds == null || addon.membershipIds!.isEmpty) return true;
    return appViewmmodel.currentUserIsMember(addon.membershipIds);
  }

  void addProductAddon(List<ProductAddon>? addons, List<OrderConfig> initialConfigs) async {
    productAddons.clear();
    requiredQtyAddonsId.clear();
    selectedAddonConfigPageIndex.value = 0;
    if (addons == null) return;
    if (initialConfigs.isNotEmpty) {
      orderConfigs.value = initialConfigs.groupBy((e) => e.addonId!).map((key, value) => MapEntry(key, value.first));
    }
    productAddons.addAll(addons);
    requiredQtyAddonsId.addAll(addons.getRequiredQtyTypeAddonsId());
    getUserSavedLocations();
    await getAddonsCalendar();
  }

  Future<void> getAddonsCalendar() async {
    selectedCalendars.clear();
    try {
      isLoading(true);
      await Future.forEach(productAddons, (addon) async {
        if (addon.calendarId != null) {
          final calendarResponse = await calendarUsecase.getCalendar(addon.calendarId!);
          if (calendarResponse != null && calendarResponse.calendar != null) {
            selectedCalendars.add(calendarResponse.calendar!);
            await getDisabledDatesForProductAddon(context!);
          }
        }
      });
      isLoading(false);
    } catch (e) {
      appViewmmodel.getWidgetFactory(context!).showFlashMessage(context!, message: 'Unable to get data, please try again later', isPersistent: true, onActinClicked: () {
        getAddonsCalendar();
      });
    }
  }

  Future<void> getDisabledDatesForProductAddon(BuildContext context) async {
    try {
      isLoading.value = true;
      if (selectedCalendars.isEmpty) {
        return;
      }
      addonsWithDisabledDates.value = await CalendarDateSelectorInfo.getDisabledDatesForProductAddon(productAddons.value, selectedCalendars.value, (calendarId) => orderUsecase.getSchedulesByCalendarId(calendarId));
      isLoading(false);
    } catch (e) {
      appViewmmodel.getWidgetFactory(context).showFlashMessage(context, message: 'Unable to get data, please try again later', isPersistent: true, onActinClicked: () {
        getAddonsCalendar();
      });
    }
  }

  void applyDefaultQtyBasedAddonsToOrderConfigs() {
    for (var addon in quantityAddons) {
      if (addon.isRequired) {
        orderConfigs[addon.id!] = OrderConfig.createQtyOrderConfig(addon.minAmount, addon: addon);
        orderConfigs.refresh();
      }
    }
  }

  Future<void> getUserSavedLocations() async {
    var locationsFromDb = await settingUsecase.getUserSavedLocations(AppConstants.APP_DB_NAME);
    savedLocations.value = locationsFromDb;
  }

  void addInitialOrderConfigs(List<OrderConfig> initialOrderConfigs) {
    // orderConfigs.clear();
    for (var config in initialOrderConfigs) {
      orderConfigs[config.addonId!] = config;
    }
  }

  var canEnableOptionSelection = false.obs;

  void selectAddonOption(BuildContext context, ProductAddon addon, String? optionId) {
    final widgetFactory = appViewmmodel.getWidgetFactory(context);
    var option = addon.options.firstWhere((element) => element.id == optionId);
    if (!selectedAddonOptions.containsKey(addon.id)) {
      selectedAddonOptions[addon.id!] = [];
    }
    if (addon.inputType == AddonInputType.SINGLE_SELECTION_INPUT.name) {
      selectedAddonOptions[addon.id!] = [option];
      canEnableOptionSelection.value = true;
    } else if (addon.inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name) {
      final selectedOptions = selectedAddonOptions[addon.id!] ?? [];
      if (selectedAddonOptions[addon.id!]!.contains(option)) {
        if (selectedOptions.length > addon.minAmount) {
          selectedAddonOptions[addon.id!]!.remove(option);
        } else {
          widgetFactory.showFlashMessage(context, message: 'You must select at least ${addon.minAmount} options');
        }
      } else {
        if (selectedOptions.length < addon.maxAmount) {
          selectedAddonOptions[addon.id!]!.add(option);
        } else {
          widgetFactory.showFlashMessage(context, message: 'You can only select up to ${addon.maxAmount} options');
        }
      }
      canEnableOptionSelection.value = selectedAddonOptions.length.inRange(DoubleRange(addon.minAmount, addon.maxAmount));
    }

    final selectedAddonOptionsId = (List<ProductAddonOption>.from(selectedAddonOptions[addon.id!] ?? []).map((e) => e.id!)).distinct().toList();
    if (selectedAddonOptionsId.isEmpty) {
      if (addon.isRequired) {
        appViewmmodel.getWidgetFactory(context).showFlashMessage(context, message: 'This field is required');
        return;
      }
      orderConfigs.remove(addon.id!);
    } else {
      orderConfigs[addon.id!] = addon.inputType == AddonInputType.SINGLE_SELECTION_INPUT.name ? OrderConfig.createSingleSelectOrderConfig(addon.name!, selectedAddonOptionsId.first, addon) : OrderConfig.createMultipleSelectOrderConfig(addon.name!, selectedAddonOptionsId, addon);
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
        content: ProductAddonDetailsModal(
          addon: addon,
          selectedLanguage: selectedLanguage,
          widgetFactory: appViewmmodel.getWidgetFactory(context),
          onSelectionFinished: (context) {
            AppModalSheet.previousPage(context: context, pageIdtoremove: pageId);
          },
        ),
      ),
    );
  }

  // Addon's product list relted logics

  var selectedProductsFromAddon = <Product>[].obs;
  var selectedDiscoungtedProductsFromAddons = <Product>[].obs;

  void showProductSelectionDialog(BuildContext context, ProductAddon addon, {Product? parentProductInfo, String? pageId}) {
    // final addonDiscounts = parentProductInfo?.getAddonDiscounts(addonId: addon.id!, selectedLanguage: selectedLanguage, parentProduct: parentProductInfo!) ?? [];
    AppModalSheet.addPageToModal(
      context,
      ModalContent(
        id: pageId,
        title: const Text('Select Product'),
        content: Obx(
          () => AddonProductSelectorModal(
            addon: addon,
            qtyInfo: selectedProductQty.value,
            widgetFactory: appViewmmodel.getWidgetFactory(context),
            selectedProducts: addon.inputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name ? selectedDiscoungtedProductsFromAddons.value : selectedProductsFromAddon.value,
            isSelected: (product) => isProductdFromAddonIsSelected(addon.inputType, product),
            addOrRemoveProductFromAddon: (cont, addon, productOptionInfo) {
              addOrRemoveProductFromAddon(cont, addon, productOptionInfo);
            },
            onFinish: (modalContext) {
              AppModalSheet.previousPage(context: modalContext, pageIdtoremove: pageId);
              applySelectedProductFromAddon(addon, List.from(selectedProductsFromAddon));
            },
          ),
        ),
      ),
    );
  }

  bool isProductdFromAddonIsSelected(String addonInputType, Product product) {
    if (addonInputType == AddonInputType.PRODUCT_SELECTION_INPUT.name) {
      return selectedProductsFromAddon.map((e) => e.id).contains(product.id);
    } else if (addonInputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name) {
      return selectedDiscoungtedProductsFromAddons.map((e) => e.id).contains(product.id);
    }
    return false;
  }

  Future<void> addOrRemoveProductFromAddon(BuildContext context, ProductAddon addon, AddonProductOptionInfo productOptionInfo) async {
    if (isProductdFromAddonIsSelected(addon.inputType, productOptionInfo.product!)) {
      if (addon.inputType == AddonInputType.PRODUCT_SELECTION_INPUT.name) {
        selectedProductsFromAddon.remove(productOptionInfo.product!);
      } else if (addon.inputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name) {
        selectedDiscoungtedProductsFromAddons.remove(productOptionInfo.product!);
      }
    } else {
      final selectedQty = await showQtyModifierModal(context, selectedProduct: productOptionInfo.product!, minQty: productOptionInfo.minQty, maxQty: productOptionInfo.maxQty);
      selectedProductQty[productOptionInfo.product!.id!] = selectedQty;
      if (addon.inputType == AddonInputType.PRODUCT_SELECTION_INPUT.name) {
        selectedProductsFromAddon.add(productOptionInfo.product!);
      } else if (addon.inputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name) {
        selectedDiscoungtedProductsFromAddons.add(productOptionInfo.product!);
      }
    }
    applySelectedProductFromAddon(addon, addon.inputType == AddonInputType.PRODUCT_SELECTION_WITH_ADDON_DISCOUNT_INPUT.name ? selectedDiscoungtedProductsFromAddons.value : selectedProductsFromAddon.value);
  }

  EdgeInsets getAddonListItemPadding(ProductAddon addon) {
    return addon.membershipIds?.isNotEmpty == true ? const EdgeInsets.symmetric(horizontal: 8, vertical: 16) : const EdgeInsets.symmetric(horizontal: 8, vertical: 8);
  }

  Widget getAddonModifierUI(BuildContext context, ProductAddon addon, {Product? parentProduct, bool enabled = false}) {
    final widgetFactory = appViewmmodel.getWidgetFactory(context);
    if (addon.inputType == AddonInputType.SINGLE_SELECTION_INPUT.name || addon.inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name) {
      return Obx(() {
        String selectedAddonOptionNames = orderConfigs[addon.id]?.getSelectedAddonOptionNames(addon.options, selectedLanguage) ?? '';
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (selectedAddonOptionNames.isNotEmpty) ...[
              widgetFactory.createText(context, selectedAddonOptionNames, textAlign: TextAlign.end),
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
      });
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
              final pageId = UniqueKey().toString();
              showProductSelectionDialog(context, addon, parentProductInfo: parentProduct, pageId: pageId);
            },
          ),
        ],
      );
    } else if (addon.inputType == AddonInputType.QUANTITY_INPUT.name || addon.inputType == AddonInputType.NUMBER_INPUT.name) {
      final selectedAmount = double.tryParse(orderConfigs[addon.id]?.singleValue ?? '${addon.minAmount}') ?? addon.minAmount;
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
    } else if (addon.inputType == AddonInputType.DATE_RANGE_INPUT.name) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (orderConfigs[addon.id]?.multipleValue != null) ...[
            widgetFactory.createText(context, '${orderConfigs[addon.id]?.getConfigDateRangeString()}', textAlign: TextAlign.end),
          ],
          widgetFactory.createButton(
            context: context,
            content: Text(orderConfigs[addon.id]?.multipleValue != null ? 'Change Date' : 'Select Date'),
            style: AppButtonStyle.textButtonStyle(context),
            onPressed: () async {
              final disabledDatesForBooking = addonsWithDisabledDates[addon.id];
              final selectedDateRange = await widgetFactory.showDateRangePickerUI(
                context,
                firstDate: disabledDatesForBooking?.firstDate,
                lastDate: disabledDatesForBooking?.lastDate,
                initialDateRange: orderConfigs[addon.id]?.getConfigDateRange(),
                disabledDates: disabledDatesForBooking?.disabledDates ?? [],
              );
              applySelectedDateRange(addon, selectedDateRange);
            },
          ),
        ],
      );
    } else if (addon.inputType == AddonInputType.DATE_INPUT.name || addon.inputType == AddonInputType.DATE_TIME_INPUT.name) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (orderConfigs[addon.id]?.singleValue?.isNotEmpty ?? false) Text('${orderConfigs[addon.id]?.singleValue}', style: Theme.of(context).textTheme.bodyLarge),
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
              final disabledDatesForBooking = addonsWithDisabledDates[addon.id];
              final selectedDate = await widgetFactory.showDateTimePicker(
                context,
                firstDate: disabledDatesForBooking?.firstDate,
                lastDate: disabledDatesForBooking?.lastDate,
                disabledDates: disabledDatesForBooking?.disabledDates ?? [],
                showTiimePicker: addon.inputType == AddonInputType.DATE_TIME_INPUT.name,
              );
              // applySelectedDate(addon, selectedDate);
            },
          ),
        ],
      );
    } else if (addon.inputType == AddonInputType.LOCATION_PER_KM_INPUT.name || addon.inputType == AddonInputType.LOCATION_INPUT.name) {
      final selectedLocation = orderConfigs[addon.id]?.singleValue;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (selectedLocation != null) ...[
            widgetFactory.createText(context, selectedLocation, style: Theme.of(context).textTheme.bodySmall, maxLines: 2),
          ],
          widgetFactory.createButton(
            context: context,
            content: const Text('Choose Location'),
            style: AppButtonStyle.textButtonStyle(context, padding: const EdgeInsets.symmetric(vertical: 0)),
            onPressed: () async {
              showLocationSelectorModal(context, addon);
            },
          ),
        ],
      );
    }
    orderConfigs.refresh();
    return const SizedBox();
  }

  Widget showRewardOnAddon(ProductAddon addon) {
    final rewards = addon.getSelectedRewardsInfo(selectedRewards);
    if (rewards.isEmpty) return const SizedBox();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rewards.map((reward) => Text(reward.reward.name.localize(selectedLanguage))).toList(),
    );
  }

  void showLocationSelectorModal(BuildContext context, ProductAddon addon) {
    final locationSelecctionPageId = 'location_selection_${addon.id}';
    AppModalSheet.addPageToModal(
      context,
      ModalContent(
        id: locationSelecctionPageId,
        title: const Text('Choose Location'),
        content: Obx(
          () => LocationListModal(
            widgetFactory: appViewmmodel.getWidgetFactory(context),
            title: 'Saved Locations',
            locations: savedLocations.value,
            selectedLocation: selectedLocation.value,
            onLocationSelected: (cont, location) async {
              selectedLocation.value = location;
              applySelectedLocation(cont, addon, location);
              await settingUsecase.saveUserLocation(location, AppConstants.APP_DB_NAME);
            },
            onAddLocation: (comcontext) async {
              final locationSearchPageId = 'location_search_${addon.id}';
              AppModalSheet.addPageToModal(
                comcontext,
                ModalContent(
                  id: locationSearchPageId,
                  title: const Text('Search your locatioin'),
                  content: LocationSelectorPage(
                    onLocationSelected: (locationSearchContext, location) {
                      savedLocations.add(location);
                      AppModalSheet.previousPage(context: locationSearchContext);
                    },
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
    orderConfigs[addon.id!] = OrderConfig(
      name: addon.name,
      type: addon.inputType,
      singleValue: qty.toString(),
      addonId: addon.id,
      additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
    );
    orderConfigs.refresh();
  }

  void applySelectedDateRange(ProductAddon addon, DateTimeRange? dateRange) {
    orderConfigs[addon.id!] = OrderConfig.createDateRangeOrderConfig(addon.name!, dateRange, addon);
  }

  void applySelectedDate(ProductAddon addon, List<DateTime>? dates) {
    if (dates == null) return;
    orderConfigs[addon.id!] = OrderConfig.createDateOrderConfig(addon.name!, dates, addon);
  }

  void applySelectedLocation(BuildContext context, ProductAddon addon, Location? location) async {
    if (location == null) return;
    orderConfigs[addon.id!] = OrderConfig(
      name: addon.name,
      type: addon.inputType,
      singleValue: location.name,
      addonId: addon.id,
      additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
    );
    selectedLocation.value = location;
    await settingUsecase.saveUserLocation(location, AppConstants.APP_DB_NAME);
    orderConfigs.refresh();
    AppModalSheet.previousPage(context: context);
  }

  void applySelectedProductFromAddon(ProductAddon addon, List<Product> products) {
    // if (addon.inputType == AddonInputType.PRODUCT_SELECTION_INPUT.name) {
    //   orderConfigs[addon.id!] = OrderConfig(
    //     name: addon.name,
    //     type: addon.inputType,
    //     productIds: products.map((e) => e.id!).toList(),
    //     products: products,
    //     calendarId: addon.calendarId,
    //     addonId: addon.id,
    //     additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
    //   ).updateFinalPrice('ETB', addons: [addon]);
    // } else

    additionalProductOrderItems[addon.id!] = products.map((product) {
      final selectedQty = getSelectedProductQty(product.id!);
      final productAddonOptionInfo = addon.getProductAddonOptionInfo(product.id!, selectedLanguage);
      final discounts = productAddonOptionInfo?.discounts ?? [];
      return product.getOrderItem(
        selectedQty,
        discounts: discounts,
        minQty: productAddonOptionInfo?.minQty ?? 0,
        maxQty: productAddonOptionInfo?.maxQty ?? 0,
        defaultDiscountName: addon.name,
      );
    }).toList();
    orderConfigs.refresh();
  }

  void setProductQtyAddon(double selectedQty) {
    orderConfigs[OrderConfig.QTY_CONFIG_ID] = OrderConfig.createQtyOrderConfig(selectedQty, isQtyConfig: true);
  }

  Future<double> showQtyModifierModal(BuildContext context, {Product? selectedProduct, double minQty = 1, double maxQty = 10}) async {
    double? basePrice = selectedProduct?.getTotalPriceUpdated('ETB', qtyInput: 1, discounts: []);
    final qtyResult = await AppModalSheet.showModal(
      context,
      type: AppModalSheetType.DIALOG,
      pages: [
        ModalContent(
          title: const Text('Modify Quantity'),
          content: ProductDynamicPricing(
            dynamicPricingDiscounts: parentProduct?.sortedDynamicPricingDiscounts ?? selectedProduct?.sortedDynamicPricingDiscounts ?? [],
            basePrice: basePrice!,
            product: selectedProduct!,
            minQty: minQty,
            maxQty: maxQty,
            initialQty: minQty,
            showFinishBtn: true,
            onFinish: (modalContext, qty) {
              AppModalSheet.closeModal(context: modalContext, result: qty);
            },
          ),
        )
      ],
    );
    return qtyResult;
  }

  void closeAdddonConfigModalWithResult(BuildContext context, {double? selectedQty}) {
    if (selectedQty != null && showProductQtyModifier.value) {
      orderConfigs[OrderConfig.QTY_CONFIG_ID] = OrderConfig.createQtyOrderConfig(selectedQty, isQtyConfig: true);
    }

    var configs = orderConfigs.values.toList();
    final result = AddonConfig(orderConfigs: configs, additionalItems: additionalProductOrderItems.values.flattened.toList());
    appViewmmodel.router.goBack(context, returnValue: {'CONFIG_DATA': result});
    orderConfigs.clear();
    selectedProductsFromAddon.clear();
    additionalProductOrderItems.clear();
    selectedDiscoungtedProductsFromAddons.clear();
    refresh();
  }

  void updateQty(double qty) {
    selectedQty.value = qty;
  }

  void addLocationSearchPage(BuildContext context, ProductAddon addon) {
    final locationSearchPageId = 'location_search_${addon.id}';
    AppModalSheet.showModal(
      context,
      type: AppModalSheetType.DIALOG,
      pages: [
        ModalContent(
          id: locationSearchPageId,
          title: const Text('Search your locatioin'),
          content: LocationSelectorPage(
            onLocationSelected: (locationSearchContext, location) {
              savedLocations.add(location);
              AppModalSheet.closeModal();
            },
          ),
        ),
      ],
    );
  }

  void handleAddonConfigPageChange(BuildContext context, {bool showQtyModifier = false, double? selectedQty}) {
    if (selectedAddonConfigPageIndex.value >= pageLength - 1) {
      closeAdddonConfigModalWithResult(context, selectedQty: selectedQty);
    } else {
      pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      selectedAddonConfigPageIndex.value = selectedAddonConfigPageIndex.value + 1;
      // if (selectedAddonConfigPageIndex.value < pageLength - 1) {
      // }
    }
  }

  void backToPreviousAddonConfigPage(BuildContext context) {
    selectedAddonConfigPageIndex.value = selectedAddonConfigPageIndex.value - 1;
    pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void closeAddonConfigModal(BuildContext context) {
    appViewmmodel.router.goBack(context);
    orderConfigs.value = {};
    selectedProductsFromAddon.clear();
    additionalProductOrderItems.clear();
    selectedDiscoungtedProductsFromAddons.clear();
  }
}
