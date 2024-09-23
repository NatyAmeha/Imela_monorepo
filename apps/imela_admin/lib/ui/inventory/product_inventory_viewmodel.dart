import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/shared/component/input_field.viewmodel.dart';
import 'package:imela_admin/ui/product/components/product_options_form.dart';
import 'package:imela_core/branch/model/inventory_location.model.dart';
import 'package:imela_core/product/product.usecase.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProductInventoryViewmodel extends GetxController with BaseViewmodel {
  final ProductUsecase productUsecase;
  final IExceptiionHandler exceptiionHandler;

  ProductInventoryViewmodel({
    required this.productUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var selecteProductVariants = <ProductVariant>[].obs;
  var inventoryLocations = <InventoryLocation>[].obs;

  // Map to hold the quantity controllers and availability checkboxes for each variant-location pair
  var quantityControllers = <String, TextEditingController>{}.obs;
  var availabilityCheckboxes = <String, bool>{}.obs;

  AppViewmodel get appViewmodel => AppViewmodel.getInstance();

  static ProductInventoryViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<ProductInventoryViewmodel>());
  }

  List<ProductVariant> getSelectedVariants(String productName) {
    if (selecteProductVariants.isNotEmpty) {
      return selecteProductVariants;
    } else {
      var defaultVariant = ProductVariant(name: productName, options: {}, isSelected: true, isMainProduct: true);
      selecteProductVariants.assign(defaultVariant);
      return selecteProductVariants;
    }
  }

  // Helper function to create a variant string key (e.g., "Size: Medium, Color: Red")
  String variantKey(ProductVariant variant) {
    return variant.options?.entries.map((e) => '${e.key}: ${e.value}').join(', ') ?? variant.name;
  }

  // Helper function to generate unique keys for each variant-location combination
  String generateKey(String variantKey, String location) {
    return '$variantKey-$location';
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    var locations = data?['LOCATIONS'] as List<InventoryLocation>;
    var variants = data?['VARIANTS'] as List<ProductVariant>;
    updateLocationandVariant(locations, variants);
  }

  void updateLocationandVariant(List<InventoryLocation> updatedLocations, List<ProductVariant> updatedVariants) {
    addInventoryLocation(updatedLocations, clear: true);
    addProductVariants(updatedVariants, clear: true);
    for (var variant in selecteProductVariants) {
      var vKey = variantKey(variant);
      for (var location in inventoryLocations) {
        var key = generateKey(vKey, location.name ?? '');
        quantityControllers[key] = TextEditingController();
        quantityControllers[key]?.addListener(() {
          var value = quantityControllers[key]?.text;
          if (value != null && value.isNotEmpty) {
            variant.branchQty?[location.name ?? ''] = double.tryParse(value) ?? 0.0;
          }
        });

        availabilityCheckboxes[key] = false;
      }
    }
  }

  void addInventoryLocation(List<InventoryLocation> location, {bool clear = false}) {
    if (clear) inventoryLocations.clear();
    inventoryLocations.addAll(location);
  }

  void addProductVariants(List<ProductVariant> variants, {bool clear = false}) {
    if (clear) selecteProductVariants.clear();
    selecteProductVariants.addAll(variants);
  }

  // Cleanup
  @override
  void onClose() {
    for (var controller in quantityControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }
}
