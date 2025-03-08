import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/inventory/inventory.usecase.dart';
import 'package:imela_core/inventory/model/inventory.model.dart';
import 'package:imela_core/inventory/model/inventory_location.model.dart';
import 'package:imela_core/inventory/model/inventory_response.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/inventory/components/inventory_editor_dialog.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class InventoryViewModel extends GetxController with BaseViewmodel {
  final InventoryUsecase _inventoryUsecase;
  final IExceptiionHandler _exceptionHandler;

  InventoryViewModel({
    required InventoryUsecase inventoryUsecase,
    @Named(AppExceptionHandler.injectName) required IExceptiionHandler exceptionHandler,
  })  : _inventoryUsecase = inventoryUsecase,
        _exceptionHandler = exceptionHandler;

  static InventoryViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<InventoryViewModel>());
  }

  // State variables
  var isLoading = false.obs;
  var isLocationsLoading = false.obs;
  var exception = Rxn<AppException>();
  var inventoryItems = <Inventory>[].obs;
  var locations = <InventoryLocation>[].obs;
  var selectedLocation = Rxn<InventoryLocation>();

  // Search variable
  var searchQuery = ''.obs;
  var searchController = TextEditingController();

  // Sort/Filter variables
  var sortByName = true.obs;
  var sortAscending = true.obs;
  var showOutOfStock = true.obs;

  // Add these state variables for editing
  var isEditing = false.obs;
  var isSaving = false.obs;
  var editingProductId = Rxn<String>();
  var editingInventoryId = Rxn<String>();
  var editingQty = 0.0.obs;
  var editingUnit = 'Unit'.obs;
  var editingIsAvailable = true.obs;

  // Getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  String get selectedLanguage => appViewmodel.selectedLanguage;

  // Get inventory with filters and search applied
  List<Inventory> get filteredInventory {
    if (inventoryItems.isEmpty) {
      return [];
    }

    var filtered = List<Inventory>.from(inventoryItems.value);

    // Apply search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((item) {
        final name = item.name?.toLowerCase() ?? '';
        final sku = item.sku?.toLowerCase() ?? '';
        return name.contains(query) || sku.contains(query);
      }).toList();
    }

    // Apply out of stock filter
    if (!showOutOfStock.value) {
      filtered = filtered.where((item) => (item.qty ?? 0) > 0).toList();
    }

    // Apply sorting
    if (sortByName.value) {
      filtered.sort((a, b) {
        final result = (a.name ?? '').compareTo(b.name ?? '');
        return sortAscending.value ? result : -result;
      });
    } else {
      // Sort by quantity
      filtered.sort((a, b) {
        final result = (a.qty ?? 0).compareTo(b.qty ?? 0);
        return sortAscending.value ? result : -result;
      });
    }

    return filtered;
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);

    // Initial loading of inventory locations
    selectedLocation.value = appViewmodel.selectedBranch.value?.inventoryLocations?.first;
    getInventoryLocations();
  }

  Future<void> getInventoryLocations() async {
    try {
      isLocationsLoading.value = true;
      exception.value = null;

      final response = await _inventoryUsecase.getInventoryLocations(
        businessId: appViewmodel.selectedBusinessId,
        branchId: appViewmodel.selectedBranchId,
      );

      if (response?.isLocationsFetchSuccessful() == true) {
        locations.value = response!.locations!;

        // Select the first location by default if none selected yet
        if (selectedLocation.value == null && locations.isNotEmpty) {
          selectedLocation.value = locations.first;
          // Load inventory for the selected location
        }
        await getInventory();
      } else {
        exception.value = AppException(
          message: response?.message ?? 'Failed to load inventory locations',
          isMainError: true,
        );
      }
    } catch (e) {
      exception.value = _exceptionHandler.getException(e as Exception);
    } finally {
      isLocationsLoading.value = false;
    }
  }

  Future<void> getInventory({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    try {
      isLoading.value = true;
      exception.value = null;
      var productIds = appViewmodel.allProducts.map((e) => e.id!).toList();
      final response = await _inventoryUsecase.getProductInventory(
        businessId: appViewmodel.selectedBusinessId,
        inventoryLocationId: selectedLocation.value?.id ?? appViewmodel.selectedBranch.value?.inventoryLocations?.first.id ?? '',
        productListIds: productIds,
        fetchPolicy: fetchPolicy,
      );
      if ((!(response?.success ?? false)) || response?.inventories?.isEmpty == true) {
        exception.value = AppException(
          message: response?.message ?? 'No Inventory found',
          isMainError: true,
        );
      }
      inventoryItems.value = response?.inventories ?? [];
    } catch (e) {
      print(e);
      exception.value = _exceptionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedLocation(InventoryLocation location) {
    selectedLocation.value = location;
    getInventory();
  }

  void refresh() {
    getInventory(fetchPolicy: ApiDataFetchPolicy.networkOnly);
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void toggleSortByName() {
    sortByName.value = true;
  }

  void toggleSortByQuantity() {
    sortByName.value = false;
  }

  void toggleSortDirection() {
    sortAscending.value = !sortAscending.value;
  }

  void toggleShowOutOfStock() {
    showOutOfStock.value = !showOutOfStock.value;
  }

  // Add this method to get products without inventory
  List<Product> get productsWithoutInventory {
    final allProducts = appViewmodel.allProducts;
    final existingProductIds = inventoryItems.map((item) => item.productId ?? '').toSet();

    return allProducts.where((product) => !existingProductIds.contains(product.id)).toList();
  }

  // Get product name by ID
  String getProductName(String? productId) {
    if (productId == null) return 'Unknown Product';

    final product = appViewmodel.allProducts.firstWhereOrNull((product) => product.id == productId);

    return product?.name?.localize(selectedLanguage) ?? 'Unknown Product';
  }

  // Start editing inventory
  void startEditingInventory(BuildContext context, Product product, Inventory? inventory) {
    editingProductId.value = product.id;
    editingInventoryId.value = inventory?.id;

    // Set initial values
    if (inventory != null) {
      editingQty.value = inventory.qty ?? 0;
      editingUnit.value = inventory.unit ?? 'Unit';
      editingIsAvailable.value = inventory.isAvailable;
    } else {
      editingQty.value = 0;
      editingUnit.value = 'Unit';
      editingIsAvailable.value = true;
    }

    // Show modal
    final widgetFactory = AppViewmodel.getWidgetFactory(context);

    AppModalSheet.showModal(
      context,
      type: AppModalSheetType.SIDESHEET,
      pages: [
        ModalContent(
          title: Text(inventory == null ? 'Add Inventory' : 'Edit Inventory'),
          content: InventoryEditorDialog(
            viewmodel: this,
            product: product,
            inventory: inventory,
            onCancel: () {
              cancelEditing();
              AppModalSheet.closeModal();
            },
            onSave: (context) async {
              await saveInventory(context);
              if (!isEditing.value) {
                AppModalSheet.closeModal();
              }
            },
          ),
        ),
      ],
    );

    isEditing.value = true;
  }

  // Cancel editing
  void cancelEditing() {
    isEditing.value = false;
    editingProductId.value = null;
    editingInventoryId.value = null;
    editingQty.value = 0;
    editingUnit.value = 'Unit';
    editingIsAvailable.value = true;
  }

  // Save edited inventory
  Future<void> saveInventory(BuildContext context) async {
    if (editingProductId.value == null) {
      return;
    }

    final widgetFactory = AppViewmodel.getWidgetFactory(context);

    try {
      isSaving.value = true;
      exception.value = null;

      InventoryResponse? response;

      if (editingInventoryId.value != null) {
        // Update existing inventory
        response = await _inventoryUsecase.updateProductInventory(
          businessId: appViewmodel.selectedBusinessId,
          productId: editingProductId.value!,
          inventoryId: editingInventoryId.value!,
          qty: editingQty.value,
          isAvailable: editingIsAvailable.value,
          unit: editingUnit.value,
        );
      } else {
        // Create new inventory
        response = await _inventoryUsecase.createInventory(
          businessId: appViewmodel.selectedBusinessId,
          productId: editingProductId.value!,
          inventoryLocationId: selectedLocation.value?.id ?? '',
          qty: editingQty.value,
          isAvailable: editingIsAvailable.value,
          unit: editingUnit.value,
        );
      }

      if (response?.success == true) {
        // Show success message
        widgetFactory.showFlashMessage(context, message: editingInventoryId.value != null ? 'Inventory updated successfully' : 'Inventory added successfully');

        // Reset editing state
        cancelEditing();

        // Refresh inventory data
        getInventory(fetchPolicy: ApiDataFetchPolicy.networkOnly);
      } else {
        widgetFactory.showFlashMessage(
          context,
          message: response?.message ?? 'Failed to save inventory',
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      print('Error saving inventory: $e');
      exception.value = _exceptionHandler.getException(e as Exception);

      widgetFactory.showFlashMessage(
        context,
        message: 'Error saving inventory: ${exception.value?.message}',
        backgroundColor: Colors.red,
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
