import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/shared/component/input_field.viewmodel.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/product/product.usecase.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProductAddonViewmodel extends GetxController with BaseViewmodel {
  final ProductUsecase productUsecase;
  final IExceptiionHandler exceptiionHandler;

  ProductAddonViewmodel({
    required this.productUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static ProductAddonViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<ProductAddonViewmodel>());
  }
  

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  
  var createdAddons = <ProductAddon>[].obs;
  var isAddonCreateModalVisible = false.obs;

  // Input fields state
  var selectedInputType = AddonInputType.SINGLE_SELECTION_INPUT.obs;
  var options = <ProductAddonOption>[].obs;
  var minAmount = 0.0.obs;
  var maxAmount = 0.0.obs;
  var isRequired = false.obs;

  // Input state variables
  var inputOptions = <String, String>{AppLanguage.ENGLISH.name: '', AppLanguage.AMHARIC.name: ''};
  var selectedInputOptionKey = AppLanguage.ENGLISH.name.obs;

  var priceInputOptions = <String, String>{Currency.ETB.name: '', Currency.USD.name: ''};
  var selectedPriceInputKey = Currency.ETB.name.obs;

  final addonNameInputViewodel = TextInputViewmodel.getInstance(key: 'addonName');
  final addonAdditionalPriceInputViewmodel = TextInputViewmodel.getInstance(key: 'additionalPrice');
  final addonMinInputViewmodel = TextInputViewmodel.getInstance(key: 'minAmount');
  final addonMaxAmountInputViewodel = TextInputViewmodel.getInstance(key: 'maxAmount');

  // getter
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();

  List<String> get getInputTypes {
    return AddonInputType.values.map((e) => e.name).toList();
  }

  void addAddon() {
    createdAddons.add(ProductAddon(
      name: addonNameInputViewodel.options.toLocalizedFieldArray(),
      inputType: selectedInputType.value.name,
      options: List.from(options),
      additionalPrice: addonAdditionalPriceInputViewmodel.options.toPriceArray(),
      minAmount: minAmount.value, //selectedInputType.value == AddonInputType.SINGLE_SELECTION_INPUT || selectedInputType.value == AddonInputType.MULTIPLE_SELECTION_INPUT ? minAmount.value : 0.0,
      maxAmount: maxAmount.value, // selectedInputType.value == AddonInputType.SINGLE_SELECTION_INPUT || selectedInputType.value == AddonInputType.MULTIPLE_SELECTION_INPUT ? maxAmount.value : null,
      isRequired: isRequired.value,
    ));

    // Reset form after adding
    resetForm();
  }

  void showAddonCreateModal(BuildContext context) {
    isAddonCreateModalVisible.value = true;
  }

  // Method to reset form

  void resetForm() {
    selectedInputType.value = AddonInputType.SINGLE_SELECTION_INPUT;
    options.clear();
    minAmount.value = 0.0;
    maxAmount.value = 0.0;
    isRequired.value = false;
  }

  void updateSelectedInputType(String? value) {
    if (value == null) return;
    selectedInputType.value = AddonInputType.values.firstWhere((element) => element.name == value);
  }

  // Method to add options
  void addOption(String name, String imageUrl) {
    options.add(ProductAddonOption(name: [LocalizedField(key: AppLanguage.ENGLISH.name, value: name)], images: [imageUrl]));
  }
}
