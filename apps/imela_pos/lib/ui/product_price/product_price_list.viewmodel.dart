import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/product/dto/product_price.response.dart';
import 'package:imela_core/product/model/pricelist.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_price.model.dart';
import 'package:imela_core/product/product_price.usecase.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_pos/ui/product_price/components/price_list_editor_dialog.dart';
import 'package:imela_pos/ui/product_price/components/price_editor_dialog.dart';

@injectable
class ProductPriceListViewModel extends GetxController with BaseViewmodel {
  final ProductPriceUsecase _productPriceUsecase;
  final IExceptiionHandler _exceptionHandler;

  ProductPriceListViewModel({
    required ProductPriceUsecase productPriceUsecase,
    @Named(AppExceptionHandler.injectName) required IExceptiionHandler exceptionHandler,
  })  : _productPriceUsecase = productPriceUsecase,
        _exceptionHandler = exceptionHandler;

  static ProductPriceListViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<ProductPriceListViewModel>());
  }

  // State variables
  var isLoading = false.obs;
  var isPriceListsLoading = false.obs;
  var exception = Rxn<AppException>();
  var productPrices = <ProductPrice>[].obs;
  var priceLists = <PriceList>[].obs;
  var selectedPriceList = Rxn<PriceList>();

  // Search variable
  var searchQuery = ''.obs;
  var searchController = TextEditingController();

  // Editing state
  var isEditingPrice = false.obs;
  var editingProductId = Rxn<String>();
  var editingPriceListId = Rxn<String>();
  var editingPrice = Rxn<double>();
  var editingCurrency = 'ETB'.obs;
  var isSaving = false.obs;

  // Getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  String get selectedLanguage => appViewmodel.selectedLanguage;

  // Products list with price list information
  List<ProductWithPrices> get productsWithPrices {
    final allProducts = appViewmodel.allProducts;
    final List<ProductWithPrices> result = [];

    // First, filter by search query if needed
    final filteredProducts = _applySearchFilter(allProducts);

    // For each product, collect all its prices across price lists
    for (final product in filteredProducts) {
      // Find all prices for this product
      final prices = productPrices.value.where((pp) => pp.productId == product.id).toList();

      // Organize prices by price list ID
      final pricesByList = <String, ProductPrice>{};

      // Default price first
      final defaultPrice = prices.firstWhereOrNull((pp) => pp.isDefault == true);

      // Then add other prices by price list
      for (final price in prices) {
        if (price.priceListId != null) {
          pricesByList[price.priceListId!] = price;
        }
      }

      // Add to result
      result.add(ProductWithPrices(
        product: product,
        defaultPrice: defaultPrice,
        pricesByList: pricesByList,
      ));
    }

    return result;
  }

  // Filter products by search query
  List<Product> _applySearchFilter(List<Product> products) {
    if (searchQuery.value.isEmpty) {
      return products;
    }

    final query = searchQuery.value.toLowerCase();
    return products.where((product) {
      final name = product.name?.localize(selectedLanguage).toLowerCase() ?? '';
      final sku = product.sku?.toLowerCase() ?? '';
      return name.contains(query) || sku.contains(query);
    }).toList();
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    loadProductPricesAndLists();
  }

  Future<void> loadProductPricesAndLists({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    try {
      isLoading.value = true;
      exception.value = null;

      // Get product IDs from app viewmodel
      final productIds = appViewmodel.allProducts.map((product) => product.id!).where((id) => id.isNotEmpty).toList();

      if (productIds.isEmpty) {
        // No products to load prices for
        isLoading.value = false;
        return;
      }

      final response = await _productPriceUsecase.getProductsPriceAndPriceList(
        businessId: appViewmodel.selectedBusinessId,
        productIds: productIds,
        branchId: appViewmodel.selectedBranchId,
        fetchPolicy: fetchPolicy,
      );

      if (response != null) {
        if (response.isPriceListsSuccessful()) {
          priceLists.value = response.priceLists!;
        }

        if (response.isProductPricesSuccessful()) {
          productPrices.value = response.productPrices!;
        }

        if (!response.isPriceListsSuccessful() && !response.isProductPricesSuccessful()) {
          exception.value = AppException(
            message: response.message ?? 'Failed to load product prices and price lists',
            isMainError: true,
          );
        }
      } else {
        exception.value = AppException(
          message: 'Failed to load product prices and price lists',
          isMainError: true,
        );
      }
    } catch (e) {
      exception.value = _exceptionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  // Get price list name by ID
  String getPriceListName(String priceListId) {
    final priceList = priceLists.firstWhereOrNull((pl) => pl.id == priceListId);
    return priceList?.name?.localize(selectedLanguage) ?? 'Unknown Price List';
  }

  // Format price for display
  String formatPrice(ProductPrice? price) {
    if (price == null || price.price == null || price.price!.isEmpty) {
      return 'N/A';
    }

    // Find price in selected currency or first available
    final selectedPrice = price.price!.firstWhereOrNull((p) => p.currency == appViewmodel.selectedCurrency) ?? price.price!.first;

    return '${selectedPrice.currency} ${selectedPrice.amount.toStringAsFixed(2)}';
  }

  // Start editing price
  void startEditingPrice(BuildContext context, String productId, String priceListId, ProductPrice? currentPrice) {
    // Set product and price list IDs
    editingProductId.value = productId;
    editingPriceListId.value = priceListId;

    // Set initial values from existing price
    if (currentPrice != null && currentPrice.price != null && currentPrice.price!.isNotEmpty) {
      final price = currentPrice.price!.firstWhereOrNull((p) => p.currency == appViewmodel.selectedCurrency) ?? currentPrice.price!.first;

      editingPrice.value = price.amount;
      editingCurrency.value = price.currency;
    } else {
      // Default values for new price
      editingPrice.value = 0.0;
      editingCurrency.value = appViewmodel.selectedCurrency;
    }

    // Show modal with price editor

    AppModalSheet.showModal(
      context,
      type: AppModalSheetType.DIALOG,
      pages: [
        ModalContent(
          title: Text(currentPrice == null ? 'Add Price' : 'Edit Price'),
          content: PriceEditorDialog(
            viewmodel: this,
            onCancel: () {
              cancelEditing();
              AppModalSheet.closeModal();
            },
            onSave: (context) async {
              await savePrice(context);
              if (!isEditingPrice.value) {
                AppModalSheet.closeModal();
              }
            },
          ),
        ),
      ],
    );

    isEditingPrice.value = true;
  }

  // Cancel editing
  void cancelEditing() {
    isEditingPrice.value = false;
    editingProductId.value = null;
    editingPriceListId.value = null;
    editingPrice.value = null;
  }

  // Save edited price
  Future<void> savePrice(BuildContext context) async {
    if (editingProductId.value == null || editingPriceListId.value == null || editingPrice.value == null) {
      return;
    }

    final widgetFactory = AppViewmodel.getWidgetFactory(context);

    try {
      isSaving.value = true;
      exception.value = null;

      // Find existing price record
      final existingPrice = productPrices.firstWhereOrNull((pp) => pp.productId == editingProductId.value && pp.priceListId == editingPriceListId.value);

      final isDefault = editingPriceListId.value == 'default';

      final newPrice = Price(currency: editingCurrency.value, amount: editingPrice.value!);

      ProductPriceResponse? response;

      if (existingPrice != null) {
        // Update existing price
        response = await _productPriceUsecase.updateProductPrice(
          businessId: appViewmodel.selectedBusinessId,
          productId: editingProductId.value!,
          productPriceId: existingPrice.id!,
          priceListId: editingPriceListId.value!,
          branchId: appViewmodel.selectedBranchId,
          prices: [newPrice],
          isDefault: isDefault,
        );
      } else {
        // Create new price
        response = await _productPriceUsecase.createProductPrice(
          businessId: appViewmodel.selectedBusinessId,
          productId: editingProductId.value!,
          priceListId: editingPriceListId.value!,
          branchId: appViewmodel.selectedBranchId,
          prices: [newPrice],
          isDefault: isDefault,
        );
      }
      print('response: ${response}');
      if ((response?.isProductPricesSuccessful() ?? false)) {
        // Show success message
        widgetFactory.showFlashMessage(context, message: existingPrice != null ? 'Price updated successfully' : 'Price created successfully');
        // Reset editing state
        cancelEditing();
        loadProductPricesAndLists(fetchPolicy: ApiDataFetchPolicy.networkOnly);
      } else {
        widgetFactory.showFlashMessage(
          context,
          message: response?.message ?? 'Failed to save price',
          backgroundColor: Colors.red
        );
      }
    } catch (e) {
      print('Error saving price: ${e}');
      widgetFactory.showFlashMessage(
        context,
        message: 'Error saving price: ${exception.value?.message}',
        backgroundColor: Colors.red,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void refresh() {
    loadProductPricesAndLists(fetchPolicy: ApiDataFetchPolicy.networkOnly);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Show price list editor dialog
  void showPriceListEditor(BuildContext context, {PriceList? priceList}) {
    final availableBranchIds = [appViewmodel.selectedBranchId]; // You might want to fetch all branches
    AppModalSheet.showModal(context, type: AppModalSheetType.DIALOG, pages: [
      ModalContent(
          title: Text('Price List Editor'),
          content: PriceListEditorDialog(
            priceList: priceList,
            selectedLanguage: selectedLanguage,
            availableBranchIds: availableBranchIds,
            onSave: (id, name, description, branchIds) {
              // AppModalSheet.closeModal();
              if (priceList != null) {
                // Update existing price list
                updatePriceList(context, priceList.id!, name, description, branchIds);
              } else {
                // Create new price list
                createPriceList(context, name, description, branchIds);
              }
            },
          ))
    ]);
  }

  // Create a new price list
  Future<void> createPriceList(
    BuildContext context,
    List<LocalizedField> name,
    List<LocalizedField> description,
    List<String> branchIds,
  ) async {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);

    try {
      isLoading.value = true;
      exception.value = null;

      final response = await _productPriceUsecase.addPriceListToBusiness(
        businessId: appViewmodel.selectedBusinessId,
        name: name,
        description: description,
        branchIds: branchIds,
      );

      if (response?.success == true) {
        // Show success message
        widgetFactory.showFlashMessage(context, message: 'Price list created successfully');

        // Reload price lists or add the new one if returned
        // if (response?.priceLists != null && response!.priceLists!.isNotEmpty) {
        //   priceLists.addAll(response.priceLists!);
        // } else {
        //   // Just reload everything if we didn't get the new price list
        // }
        loadProductPricesAndLists(fetchPolicy: ApiDataFetchPolicy.networkOnly);
      } else {
        widgetFactory.showFlashMessage(
          context,
          message: response?.message ?? 'Failed to create price list',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      exception.value = _exceptionHandler.getException(e as Exception);

      widgetFactory.showFlashMessage(
        context,
        message: 'Error creating price list: ${exception.value?.message}',
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Update an existing price list
  Future<void> updatePriceList(
    BuildContext context,
    String priceListId,
    List<LocalizedField> name,
    List<LocalizedField> description,
    List<String> branchIds,
  ) async {
    final widgetFactory = AppViewmodel.getWidgetFactory(appViewmodel.getAppContext());

    try {
      isLoading.value = true;
      exception.value = null;

      final response = await _productPriceUsecase.updateBusinessPriceList(
        businessId: appViewmodel.selectedBusinessId,
        priceListId: priceListId,
        name: name,
        description: description,
        branchIds: branchIds,
      );

      if (response?.success == true) {
        // Show success message
        widgetFactory.showFlashMessage(context, message: 'Price list updated successfully');

        // Reload to get the updated price lists
        loadProductPricesAndLists(fetchPolicy: ApiDataFetchPolicy.networkOnly);
      } else {
        widgetFactory.showFlashMessage(
          context,
          message: response?.message ?? 'Failed to update price list',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      widgetFactory.showFlashMessage(context, message: 'Error updating price list: ${exception.value?.message}', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
}

// Helper class to organize product prices
class ProductWithPrices {
  final Product product;
  final ProductPrice? defaultPrice;
  final Map<String, ProductPrice> pricesByList;

  ProductWithPrices({
    required this.product,
    this.defaultPrice,
    required this.pricesByList,
  });

  ProductPrice? getPriceForList(String priceListId) {
    return pricesByList[priceListId];
  }
}
