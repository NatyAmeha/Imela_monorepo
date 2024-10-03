import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/resources/values.dart';
import 'package:imela_admin/shared/component/input_field.viewmodel.dart';
import 'package:imela_admin/ui/branch/components/create_branch_componenet.dart';
import 'package:imela_admin/ui/product/components/main_product_info_form.dart';
import 'package:imela_admin/ui/product/components/product_creation_progress.dart';
import 'package:imela_admin/ui/product/components/product_options_form.dart';
import 'package:imela_admin/ui/product/create_product_page.dart';
import 'package:imela_admin/ui/product/product_section/create_product_section_page.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/branch/model/inventory_location.model.dart';
import 'package:imela_core/business/business.usecase.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/product/dto/create_product.input.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/product/product.usecase.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';
import 'package:dartx/dartx.dart';

@injectable
class CreateProductViewmodel extends GetxController with BaseViewmodel {
  final ProductUsecase productUsecase;
  final BusinessUsecase businessUsecase;
  final IExceptiionHandler exceptiionHandler;

  static const mainProductInfoFormStepId = 1;
  static const productOptionsFormStepId = 2;
  static const productInventoryFormStepId = 3;
  static const productAddonFormStepId = 4;
  static const productPaymentFormStepId = 5;

  CreateProductViewmodel({
    required this.productUsecase,
    required this.businessUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var allProductInputs = <CreateProductInput>[].obs;

  Business? selectedBusiness;
  var branches = <Branch>[].obs;

  var isMainProduct = true.obs;
  var canOrderOnline = true.obs;
  var hasOptions = false.obs;

  var allCategories = List<String>.from(categories).obs;
  var selectedCategories = <String>[].obs;
  var tags = <String>[].obs;
  var allBusinessSections = <BusinessSection>[].obs;
  var selectedSections = <BusinessSection>[].obs;

  var productCreatioSteps = <ProgressStep>[].obs;
  var selectedStepId = 1.obs;

  var inputOptions = <String, String>{AppLanguage.ENGLISH.name: '', AppLanguage.AMHARIC.name: ''};
  var selectedInputOptionKey = AppLanguage.ENGLISH.name.obs;

  final businessNameInputViewodel = TextInputViewmodel.getInstance(key: 'productName');
  final businessDescriptionInputViewodel = TextInputViewmodel.getInstance(key: 'productDescription');
  final callToaActionInputViewodel = TextInputViewmodel.getInstance(key: 'callToAction');
  final minOrderQtyController = TextEditingController(text: '1');

  // getter
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  List<InventoryLocation> get locations => branches.map((e) => e.inventoryLocations ?? []).toList().flatten();

  String get productDisplayName {
    return businessNameInputViewodel.options.toLocalizedFieldArray().localize(appViewmodel.selectedLanguage);
  }

  int get selectedStepIndex {
    return productCreatioSteps.indexWhere((element) => element.id == selectedStepId.value);
  }

  List<String> get allBusinessSectionNames => allBusinessSections.map((e) => e.name.localize(appViewmodel.selectedLanguage)).toList();
  List<String> get selectedSectionNames => selectedSections.map((e) => e.name.localize(appViewmodel.selectedLanguage)).toList();

  static CreateProductViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<CreateProductViewmodel>());
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    selectedBusiness = data![CreateProductPage.businessArgKey] as Business;
    allBusinessSections.value = selectedBusiness?.sections ?? [];
    getDefaultProductCreationSteps();
    updateSelectedCategories([allCategories.first]);
    // appViewmodel.getCurrentUser();
  }

  void getDefaultProductCreationSteps() {
    final defaultSteps = [
      ProgressStep(
        id: mainProductInfoFormStepId,
        title: 'Main Information',
        isCompleted: true,
        cotnent: MainProductInfoForm(onContinue: () {
          navigateToStep(1);
        }),
      ),
      ProgressStep(
          id: productOptionsFormStepId,
          title: 'Product Options',
          isCompleted: false,
          cotnent: ProductOptionsForm(
            onSkip: () {
              navigateToStep(2);
            },
            onContinue: () {
              navigateToStep(2);
            },
          )),
      ProgressStep(id: productInventoryFormStepId, title: 'Product Inventories', isCompleted: false),
      ProgressStep(id: productAddonFormStepId, title: 'Product Addons', isCompleted: false),
      ProgressStep(id: productPaymentFormStepId, title: 'Pricing and Payment', isCompleted: false),
    ];
    productCreatioSteps.clear();
    productCreatioSteps.addAll(defaultSteps);
  }

  void updateSelectedCategories(List<String> categories) {
    if (categories.isNotEmpty) {
      selectedCategories.assignAll(categories);
    }
  }

  void updateSelectedSections(List<String> section) {
    selectedSections.value = allBusinessSections.where((bs) => section.contains(bs.name.localize(appViewmodel.selectedLanguage))).toList();
  }

  void updateCanOrderOnline(bool? value) {
    if (value != null) {
      canOrderOnline.value = value;
    }
  }

  void openCreateProductSectionModal(BuildContext context) async {
    await AppModalSheet.showModal(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
      ModalContent(
        title: const Text('Create Product section'),
        content: SmallScreenProductSectionCreatePage(onSectionCreateFinished: (sections) async {
          allBusinessSections.value = sections;
          selectedSections.add(allBusinessSections.first);
          AppModalSheet.closeModal();
        }),
      ),
    ]);
  }

  void saveMainProductInfo() {
    final mainProductInfo = CreateProductInput.fromMainInfo(nameOptions: businessNameInputViewodel.options, descriptionOptions: businessDescriptionInputViewodel.options, callToActionOptions: callToaActionInputViewodel.options, canOrderOnline: canOrderOnline.value, minOrderQtyText: minOrderQtyController.text, categories: selectedCategories.value);
    print('main product info ${mainProductInfo.toJson()}');
    allProductInputs.assign(mainProductInfo);
    navigateToStep(1);
  }

  void createPRoduct(List<ProductVariant> variants) {
    final productInputs = variants.map((e) => e.converToProductCreateInput(allProductInputs.first, options)).toList();
    allProductInputs.assignAll(productInputs);
    print('product inputs ${allProductInputs.map((e) => e.defaultPrices)}');
    // print('product addons ${productAddons.map((e) => e.toJson())}');
  }
  // product options logic

  // List of available options (size, color, etc.)
  var options = <ProductOptionsGenerator>[].obs;
  var selectedOptions = <String, String>{}.obs; // To track the selected option values
  var selectedVariants = <ProductVariant>[].obs;
  var productAddons = <ProductAddon>[].obs;

  

  // Add new option (like adding "Size" or "Color")
  void addOption(ProductOptionsGenerator option) {
    options.add(option);
  }

  // Update selected option values when user selects a value
  void updateSelectedOption(String optionName, String value) {
    selectedOptions[optionName] = value;
  }

  // Update option (edit option name or values)
  void updateOption(int index, ProductOptionsGenerator updatedOption) {
    options[index] = updatedOption;
  }

  // Delete option
  void deleteOption(int index) {
    options.removeAt(index);
    selectedOptions.remove(options[index].name); // Clean up the selected options if deleted
  }

  // Delete individual value from an option
  void deleteOptionValue(int optionIndex, int valueIndex) {
    options[optionIndex].values.removeAt(valueIndex);
  }

  // Edit individual value from an option
  void editOptionValue(int optionIndex, int valueIndex, String newValue) {
    options[optionIndex].values[valueIndex].value = newValue;
  }

  // Get all possible variant combinations
  List<ProductVariant> getVariants() {
    var variants = <ProductVariant>[];

    if (options.isNotEmpty) {
      // Recursive function to get all combinations
      void generateVariants(int optionIndex, Map<String, String> currentVariant) {
        if (optionIndex == options.length) {
          final optionValue = Map<String, String>.from(currentVariant);
          final productVariantInfo = ProductVariant(name: productDisplayName, options: optionValue, isSelected: isProductVariantSelected(optionValue), isMainProduct: false);
          variants.add(productVariantInfo);
          return;
        }

        var currentOption = options[optionIndex];
        for (var value in currentOption.values) {
          currentVariant[currentOption.name] = value.value;
          generateVariants(optionIndex + 1, currentVariant);
        }
      }

      generateVariants(0, {});
      print("variants ${variants.length}");
      variants.removeWhere((e) => e.isMainProduct == true);
    } else {
      final defaultVariant = ProductVariant(name: productDisplayName, options: {}, isSelected: true, isMainProduct: isMainProduct.value);
      variants.add(defaultVariant);
    }

    return variants;
  }

  bool isProductVariantSelected(Map<String, String> optionValue) {
    final data = selectedVariants.any((map) => mapEquals(map.options, optionValue));
    return data;
  }

  void updateSelectedVariants(List<ProductVariant> variants) {
    selectedVariants.assignAll(variants);
    navigateToStep(3);
  }

  void addOrRemoveFromSelectedVariant(ProductVariant variantInfo, bool? isSelected, {bool isDefaultVariant = false}) {
    print('is selected ${variantInfo.variantName} ${selectedVariants.length}');
    if (isSelected == null) {
      return;
    }

    if (isSelected) {
      selectedVariants.add(variantInfo);
    } else {
      selectedVariants.removeWhere((variant) => (variant.options.toString() == variantInfo.options.toString()));
    }
    selectedVariants.refresh();
  }

  void showAddOptionDialog(BuildContext context, {ProductOptionsGenerator? existingOption, int? index}) {
    var nameController = TextEditingController(text: existingOption?.name ?? '');
    var valueController = TextEditingController(text: existingOption != null ? existingOption.values.map((e) => e.value).join(', ') : '');

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(existingOption == null ? 'Add Option' : 'Edit Option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Option Name'),
                ),
                TextField(
                  controller: valueController,
                  decoration: InputDecoration(labelText: 'Option Values (comma-separated)'),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    var name = nameController.text;
                    var values = valueController.text.split(',').map((e) => OptionValue(e.trim())).toList();
                    if (name.isNotEmpty && values.isNotEmpty) {
                      var option = ProductOptionsGenerator(name: name, values: values);
                      if (existingOption == null) {
                        addOption(option);
                      } else {
                        updateOption(index!, option);
                      }
                    }
                    Get.back();
                  },
                  child: Text(existingOption == null ? 'Add' : 'Update')),
            ],
          );
        });
  }

  void updateProductAddons(List<ProductAddon> addons) {
    productAddons.assignAll(addons);
    navigateToStep(4);
  }

  void navigateToInventoryStep() {
    if (selectedVariants.isEmpty == true) {
      final defaultVariant = ProductVariant(name: productDisplayName, options: {}, isSelected: true, isMainProduct: true);
      selectedVariants.assign(defaultVariant);
    }
    else{
      selectedVariants.removeWhere((e) => e.isMainProduct == true);
    }
    navigateToStep(2);
  }

  void navigateToStep(int index) {
    if (index <= productCreatioSteps.length) {
      selectedStepId.value = productCreatioSteps[index].id;
    }
  }

  double getFormWidth(BuildContext context) {
    if (Responsive.isSmallScreen(context)) {
      return MediaQuery.sizeOf(context).width;
    } else if (Responsive.isMediumScreen(context))
      return MediaQuery.sizeOf(context).width * 0.7;
    else
      return MediaQuery.sizeOf(context).width * 0.5;
  }

  double getProgressCardWidth(BuildContext context) {
    if (Responsive.isSmallScreen(context)) {
      return MediaQuery.sizeOf(context).width;
    } else if (Responsive.isMediumScreen(context))
      return MediaQuery.sizeOf(context).width * 0.3;
    else
      return MediaQuery.sizeOf(context).width * 0.2;
  }

  void showBranchCreateModal(BuildContext context) async {
    await AppModalSheet.showModal(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
      ModalContent(
        title: const Text('Create Branch'),
        content: CreateBranchComponenet(onCreateBranch: (branch) {
          createBranch(context, branch);
        }),
      ),
    ]);
  }

  Future<void> createBranch(BuildContext context, Branch branch) async {
    branches.add(branch);
    AppModalSheet.closeModal();
  }
}
