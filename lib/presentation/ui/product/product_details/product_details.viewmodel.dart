import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/product_response.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/domain/product/model/product_addon.model.dart';
import 'package:melegna_customer/domain/product/product.usecase.dart';
import 'package:melegna_customer/domain/shared/gallery.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/product/components/product_addon_modal.dart';
import 'package:melegna_customer/presentation/ui/product/components/product_features_list.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';
import 'package:melegna_customer/services/routing_service.dart';

@injectable
class ProductDetailsViewmodel extends GetxController with BaseViewmodel {
  final ProductUsecase productUsecase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;

  ProductDetailsViewmodel({
    required this.productUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  // page state variables
  final isLoading = false.obs;
  final exception = Rxn<AppException>();

  final productDetails = Rxn<ProductResponse>();
  Product get selectedProduct => selectedProductOption.value ?? productDetails.value!.product!;
  String get productName => productDetails.value?.product?.name.localize() ?? '';
  String get getProductDescription => productDetails.value?.product?.description?.localize() ?? '';
  List<String> get getProductImage => productDetails.value!.product?.gallery?.getImages() ?? [];

  var isAppbarExpanded = true.obs;

  var selectedProductOption = Rxn<Product>();
  bool get isOptionSelected => productOptions.isNotEmpty ? selectedProductOption.value != null : true;
  bool isProductOptionSelected(Product product) => selectedProductOption.value?.id == product.id;

  var selectedAddonDateRange = <String, DateTimeRange>{}.obs;
  DateTimeRange? getSelectedDateRange(String addonId) => selectedAddonDateRange[addonId];

  var selectedSingleOptions = <String, String>{}.obs;
  String? getSelectedSingleOptionOfAddon(String addonId) => selectedSingleOptions[addonId];

  var addonsSelectedQtyChange = <String, double>{}.obs;
  double? getSelectedAddonQty(String addonId) => addonsSelectedQtyChange[addonId];

  void selectDefaultAddons() {
    productInfo?.addons?.where((addon) => addon.isRequired == true).forEach((addon) {
      if (addon.isNumberInput) {
        addonsSelectedQtyChange.addAll({addon.id!: addon.minAmount});
      } else if (addon.isSingleSelectionInput && addon.options.isNotEmpty == true) {
        selectedSingleOptions.addAll({addon.id!: addon.options.first.name.localize()});
      }
    });
  }

  bool get canEnableAddonContinueBtn {
    bool isDateSelected = false;
    final requiredAddons = productInfo?.addons?.where((addon) => addon.isRequired);
    requiredAddons?.forEach((addon) {
      if (addon.isDateInput || addon.isDateTimeInput || addon.isTimeINput) {
        isDateSelected = selectedAddonDateRange.containsKey(addon.id);
      } 
    });
    return isDateSelected;
  }

  List<Product> get productOptions => productDetails.value?.variants ?? [];
  Product? get productInfo => productDetails.value?.product;

  void selectProductOption(Product product) {
    selectedProductOption.value = product; 
  }

  // widget Controllers
  final productOptionListController = Get.put(CustomListController<Product>(), tag: 'productOptionList');
  late ScrollController productHeaderScrollController;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    print("bundle detail product viewmodel called");
    super.initViewmodel(data: data);
    productHeaderScrollController = ScrollController();
    final productId = data!['id'] as String;
    getProductDetails(productId);
  }

  void listenAppbarHeaderScroll() {
    productHeaderScrollController.addListener(() {
      if (productHeaderScrollController.offset > 250) {
        isAppbarExpanded(false);
      } else if (productHeaderScrollController.offset <= 250) {
        isAppbarExpanded(true);
      }
    });
  }

  // data fetching
  Future<void> getProductDetails(String productId) async {
    try {
      isLoading(true);
      productDetails.value = await productUsecase.getProductDetails(productId);
      if (productOptions.isNotEmpty) {
        productOptionListController.addItems(productOptions);
      }
      selectDefaultAddons();
    } on AppException catch (e) {
      exception.value = e;
    } catch (e) {
      exception.value = AppException.unexpectedError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // view helper methods

  List<ProductFeature> getProductFeatures() {
    var list = <ProductFeature>[
      ProductFeature(name: "Order online"),
      ProductFeature(name: "Free delivery", icon: Icons.delivery_dining),
      ProductFeature(name: "Cash on delivery", icon: Icons.money_rounded),
      ProductFeature(name: "Pay online"),
    ];
    return list;
  }

  void handleJourney(BuildContext context, WidgetFactory widgetFactory) async {
    if (productInfo?.addons?.isNotEmpty == true) {
      double screenHeight = MediaQuery.sizeOf(context).height;
      const double addonWidgetHeight = 100.0;

      // Calculate the total height required for all addons
      double totalHeight = productInfo!.addons!.length * addonWidgetHeight + 200;

      // Normalize the height to a value between 0 and 1
      double normalizedHeight = totalHeight / screenHeight;
      normalizedHeight = normalizedHeight.clamp(0.0, 1.0);
      print("normalized height $normalizedHeight");
      normalizedHeight = normalizedHeight <= 0.5 ? 0.52 : normalizedHeight;
      var initialHeight = normalizedHeight <= 0.85 ? normalizedHeight : 0.5;

      await widgetFactory.createModalBottomSheet(
        context,
        content: (scrollController) => ProductAddonModal(
          widgetFactory: widgetFactory,
          addons: productInfo!.addons!,
          scrollController: scrollController,
          productDetailsViewmodel: this,
          onContinue: () {
            router.goBack(context);
          },
        ),
        initialHeight: initialHeight,
        maxHeight: normalizedHeight,
      );
    }
  }

  void handleAddonDateSelection(BuildContext context, ProductAddon addon, WidgetFactory widgetFactory) async {
    final pickedDate = await widgetFactory.showDateRangePickerUI(context, initialDateRange: getSelectedDateRange(addon.id!));
    if (pickedDate != null) {
      selectedAddonDateRange.addAll({addon.id!: pickedDate});
    }
  }

  void handleProductAddonsingleSelection(BuildContext context, ProductAddon addon, {required String value, required WidgetFactory widgetFactory}) async {
    selectedSingleOptions.addAll({addon.id!: value});
  }

  void handleProductAddonQtyChange(BuildContext context, ProductAddon addon, {required double value, required WidgetFactory widgetFactory}) async {
    addonsSelectedQtyChange.addAll({addon.id!: value});
  }

  void cleanup() {
    selectedAddonDateRange.clear();
    selectedSingleOptions.clear();
    addonsSelectedQtyChange.clear();
    productDetails(null);
    selectedProductOption(null);
    exception.value = null;
  }

  @override
  void dispose() {
    print("disposing product details viewmodel");
    exception.value = null;
    productDetails.value = null;
    selectedProductOption.value = null;
    isLoading(false);
    productOptionListController.dispose();
    super.dispose();
  }
}
