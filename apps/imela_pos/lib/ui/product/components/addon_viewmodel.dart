import 'dart:ffi';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/product/components/pos_product_addon_details.modal.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

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
  final Map<String, OrderConfig> orderConfigs = {};

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  String get selectedLanguage => appViewmodel.selectedLanguage;

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

  void selectAddonOption(ProductAddon addon, String? optionId) {
    var option = addon.options.firstWhere((element) => element.id == optionId);
    if (!selectedAddonOptions.containsKey(addon.id)) {
      selectedAddonOptions[addon.id!] = [];
    }
    if (addon.inputType == AddonInputType.SINGLE_SELECTION_INPUT.name) {
      selectedAddonOptions[addon.id!] = [option];
      print('selectedAddonOptions: $selectedAddonOptions');
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
        title: const Text('Selected platform services'),
        content: PosProductAddonDetailsModal(
            addon: addon,
            onSelectionFinished: () {
              AppModalSheet.previousPage(pageIdtoremove: pageId);
            }),
      ),
    );
  }

  void closeAdddonConfigModalWithResult() {
    var configs = orderConfigs.values.toList();
    AppModalSheet.closeModal(result: configs);
    orderConfigs.clear();
  }
}
