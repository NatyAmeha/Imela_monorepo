import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/product/components/product_addon_modal/pos_product_addon_details.modal.dart';
import 'package:imela/presentation/ui/shared/qty_modifier.component.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';

import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/date_utils.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';

@injectable
class ProductAddonViewmodel extends GetxController with BaseViewmodel {
  // final Paymentusec businessUsecase;
  final IExceptiionHandler exceptiionHandler;

  ProductAddonViewmodel({
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

  // getters
  AppController get appViewmmodel => AppController.getInstance;
  String get selectedLanguage => appViewmmodel.selectedLanguage.name;

  List<String> selectedAddonOptionsId(String addonId) => (selectedAddonOptions[addonId] ?? []).map((e) => e.id!).toList();

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () {
      final addons = data?['productAddons'] ?? [];
      addProductAddon(addons);
    });
  }

  void addProductAddon(List<ProductAddon> addons) {
    productAddons.clear();
    productAddons.addAll(addons);
  }

  void addInitialOrderConfigs(List<OrderConfig> initialOrderConfigs) {
    orderConfigs.clear();
    for (var config in initialOrderConfigs) {
      orderConfigs[config.addonId!] = config;
    }
  }

  void selectAddonOption(ProductAddon addon, String? optionId) {
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

    final selectedAddonOptionsId = selectedAddonOptions[addon.id!]?.map((e) => e.id!).toList() ?? [];
    if (selectedAddonOptionsId.isNotEmpty) {
      orderConfigs[addon.id!] = OrderConfig(
        name: addon.name,
        type: addon.inputType,
        singleValue: addon.inputType == AddonInputType.SINGLE_SELECTION_INPUT.name ? selectedAddonOptionsId.first : null,
        multipleValue: addon.inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name ? selectedAddonOptionsId : null,
        addonId: addon.id,
        additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
      );
    }
    selectedAddonOptions.refresh();
  }

  bool isAddonSelectable(ProductAddon addon) {
    return addon.inputType == AddonInputType.SINGLE_SELECTION_INPUT.name || addon.inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name;
  }

  void showAddonOptionsDialog(BuildContext context, ProductAddon addon) {
    final pageId = UniqueKey().toString();
    AppModalSheet.addPageToModal(
      context,
      ModalContent(
        id: pageId,
        title: const Text('Select options'),
        content: ProductAddonDetailsModal(
            addon: addon,
            onSelectionFinished: () {
              AppModalSheet.previousPage(pageIdtoremove: pageId);
            }),
      ),
    );
  }

  Widget getAddonModifierUI(BuildContext context, ProductAddon addon) {
    final widgetFactory = appViewmmodel.getWidgetFactory(context);
    if (addon.inputType == AddonInputType.SINGLE_SELECTION_INPUT.name || addon.inputType == AddonInputType.MULTIPLE_SELECTION_INPUT.name) {
      if (orderConfigs[addon.id]?.singleValue != null || orderConfigs[addon.id]?.multipleValue != null) {
        return Text('${orderConfigs[addon.id]?.singleValue ?? ''} ${orderConfigs[addon.id]?.multipleValue?.join(' - ') ?? ''}');
      }
      return widgetFactory.createButton(
        context: context,
        content: const Text('Select Options'),
        style: AppButtonStyle.textButtonStyle(context),
        onPressed: () {
          showAddonOptionsDialog(context, addon);
        },
      );
    } else if (addon.inputType == AddonInputType.QUANTITY_INPUT.name || addon.inputType == AddonInputType.NUMBER_INPUT.name) {
      return QuantityModifierComponent(
        currentQty: double.tryParse(orderConfigs.value[addon.id]?.singleValue ?? '${addon.minAmount}') ?? addon.minAmount,
        width: 150,
        widgetFactory: widgetFactory,
        onQtyChange: (qty) {
          applySelectedQty(addon, qty);
        },
      );
    } else if (addon.inputType == AddonInputType.DATE_RANGE_INPUT.name) {
      if (orderConfigs[addon.id]?.multipleValue != null) {
        return Text('${orderConfigs[addon.id]?.multipleValue?.first} - ${orderConfigs[addon.id]?.multipleValue?.last}');
      }
      return widgetFactory.createButton(
        context: context,
        content: const Text('Select Date Range'),
        style: AppButtonStyle.textButtonStyle(context),
        onPressed: () {
          return widgetFactory.createButton(
            context: context,
            content: const Text('Select'),
            style: AppButtonStyle.textButtonStyle(context),
            onPressed: () async {
              final selectedDateRange = await widgetFactory.showDateRangePickerUI(context);
              applySelectedDateRange(addon, selectedDateRange);
            },
          );
        },
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
              final selectedDate = await widgetFactory.showDateTimePicker(context, DateTime.now(), DateTime.now(), null, null, null, true);
              applySelectedDate(addon, selectedDate);
            },
          ),
        ],
      );
    }
    orderConfigs.refresh();
    return const SizedBox();
  }

  void applySelectedQty(ProductAddon addon, double qty) {
    orderConfigs[addon.id!] = OrderConfig(
      name: addon.name,
      type: addon.inputType,
      singleValue: qty.toString(),
      addonId: addon.id,
      additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
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
      additionalPrice: addon.additionalPrice?.toSelectedPrice('ETB')?.amount ?? 0,
    );
  }

  void closeAdddonConfigModalWithResult() {
    var configs = orderConfigs.values.toList();
    AppModalSheet.closeModal(result: configs);
    orderConfigs.clear();
  }
}
