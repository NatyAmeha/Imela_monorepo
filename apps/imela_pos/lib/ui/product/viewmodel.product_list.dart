import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProductListViewModel extends GetxController with BaseViewmodel {
  // Constructor and singleton pattern
  ProductListViewModel();

  static ProductListViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<ProductListViewModel>());
  }

  // State variables
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var searchController = TextEditingController();
  
  // Filter variables
  var showOnStoreFilter = true.obs;
  var showInPOSFilter = true.obs;
  var isActiveFilter = true.obs;
  
  // Sort variables
  var sortBy = Rx<ProductSortOption>(ProductSortOption.nameAsc);

  // Getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  String get selectedLanguage => appViewmodel.selectedLanguage;
  
  // Get products with applied filters and search
  List<Product> get filteredProducts {
    final allProducts = appViewmodel.allProducts;
    
    if (allProducts.isEmpty) {
      return [];
    }
    
    return allProducts
      .where((product) => _applyFilters(product))
      .where((product) => _applySearch(product))
      .toList()
      .sorted((a, b) => _applySorting(a, b));
  }
  
  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    // Additional initialization if needed
  }
  
  // Filter methods
  bool _applyFilters(Product product) {
    // Only show products that match all selected filters
    if (!showOnStoreFilter.value && (product.showOnStore ?? false)) return false;
    if (!showInPOSFilter.value && product.availableInPOS) return false;
    if (!isActiveFilter.value && product.isActive) return false;
    
    return true;
  }
  
  // Search method
  bool _applySearch(Product product) {
    if (searchQuery.value.isEmpty) {
      return true;
    }
    
    final query = searchQuery.value.toLowerCase();
    final name = product.name?.localize(selectedLanguage).toLowerCase() ?? '';
    final sku = product.sku?.toLowerCase() ?? '';
    
    return name.contains(query) || sku.contains(query);
  }
  
  // Sort method
  int _applySorting(Product a, Product b) {
    switch (sortBy.value) {
      case ProductSortOption.nameAsc:
        return (a.name?.localize(selectedLanguage) ?? '')
          .compareTo(b.name?.localize(selectedLanguage) ?? '');
      case ProductSortOption.nameDesc:
        return (b.name?.localize(selectedLanguage) ?? '')
          .compareTo(a.name?.localize(selectedLanguage) ?? '');
      case ProductSortOption.priceAsc:
        return (a.getPrice()?.toSelectedPrice('ETB')?.amount ?? 0)
          .compareTo(b.getPrice()?.toSelectedPrice('ETB')?.amount ?? 0);
      case ProductSortOption.priceDesc:
        return (b.getPrice()?.toSelectedPrice('ETB')?.amount ?? 0)
          .compareTo(a.getPrice()?.toSelectedPrice('ETB')?.amount ?? 0);
    }
  }
  
  // Update methods
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }
  
  void toggleShowOnStoreFilter() {
    showOnStoreFilter.value = !showOnStoreFilter.value;
  }
  
  void toggleShowInPOSFilter() {
    showInPOSFilter.value = !showInPOSFilter.value;
  }
  
  void toggleIsActiveFilter() {
    isActiveFilter.value = !isActiveFilter.value;
  }
  
  void setSortOption(ProductSortOption option) {
    sortBy.value = option;
  }
  
  void refreshProducts() {
    // This will trigger a rebuild of the UI
    update();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

enum ProductSortOption {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
}

extension ProductSortOptionExtension on ProductSortOption {
  String get label {
    switch (this) {
      case ProductSortOption.nameAsc:
        return 'Name (A-Z)';
      case ProductSortOption.nameDesc:
        return 'Name (Z-A)';
      case ProductSortOption.priceAsc:
        return 'Price (Low to High)';
      case ProductSortOption.priceDesc:
        return 'Price (High to Low)';
    }
  }
}
