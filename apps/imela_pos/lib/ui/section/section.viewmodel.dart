import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/business/business.usecase.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_core/shared/utils/filter_models.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class SectionViewModel extends GetxController with BaseViewmodel {
  final BusinessUsecase _businessUsecase;
  final IExceptiionHandler _exceptionHandler;

  SectionViewModel({
    required BusinessUsecase businessUsecase,
    @Named(AppExceptionHandler.injectName) required IExceptiionHandler exceptionHandler,
  })  : _businessUsecase = businessUsecase,
        _exceptionHandler = exceptionHandler;

  static SectionViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<SectionViewModel>());
  }

  // State variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var section = Rxn<BusinessSection>();
  var products = <Product>[].obs;

  // Search variable
  var searchQuery = ''.obs;
  var searchController = TextEditingController();
  
  // Filter variables
  var filterCategories = <FilterCategory>[].obs;
  var showFilterOverlay = false.obs;
  var priceRangeCategory = Rxn<PriceRangeFilterCategory>();
  var sortCategory = Rxn<FilterCategory>();

  // Getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  String get selectedLanguage => appViewmodel.selectedLanguage;
  
  // Check if any filter is applied
  bool get isFilterApplied {
    // Check normal filter categories
    for (final category in filterCategories) {
      if (category.hasSelection) return true;
    }
    
    // Check price range category
    if (priceRangeCategory.value?.hasRangeFilter == true) return true;
    
    // Check sort category (all options except default)
    if (sortCategory.value?.selectedOptions.isNotEmpty == true) {
      final selectedOption = sortCategory.value!.selectedOptions.first;
      if (selectedOption.id != 'nameAsc') return true; // If not default sort
    }
    
    return false;
  }

  // Filtered and sorted products
  List<Product> get filteredProducts {
    // Start with all products or search filtered products
    List<Product> filtered = [];
    
    if (searchQuery.value.isEmpty) {
      filtered = List<Product>.from(products);
    } else {
      final query = searchQuery.value.toLowerCase();
      filtered = products.where((product) {
        final name = product.name?.localize(selectedLanguage).toLowerCase() ?? '';
        return name.contains(query);
      }).toList();
    }
    
    // Apply tag filters if any are selected
    for (final category in filterCategories) {
      final selectedOptions = category.selectedOptions;
      if (selectedOptions.isEmpty) continue;
      
      filtered = filtered.where((product) {
        // Check if product has any of the selected tags
        final productTags = product.tag ?? [];
        for (final option in selectedOptions) {
          if (productTags.contains(option.id)) {
            return true;
          }
        }
        return false;
      }).toList();
    }
    
    // Apply price range filter if set
    if (priceRangeCategory.value?.hasRangeFilter == true) {
      final range = priceRangeCategory.value!.currentRange!;
      filtered = filtered.where((product) {
        final price = product.getPrice()?.toSelectedPrice('ETB')?.amount ?? 0;
        return price >= range.start && price <= range.end;
      }).toList();
    }
    
    // Apply sorting
    final List<Product> sortedList = List<Product>.from(filtered);
    
    if (sortCategory.value?.selectedOptions.isNotEmpty == true) {
      final sortOption = sortCategory.value!.selectedOptions.first;
      switch (sortOption.id) {
        case 'nameAsc':
          sortedList.sort((a, b) => (a.name?.localize(selectedLanguage) ?? '')
              .compareTo(b.name?.localize(selectedLanguage) ?? ''));
          break;
        case 'nameDesc':
          sortedList.sort((a, b) => (b.name?.localize(selectedLanguage) ?? '')
              .compareTo(a.name?.localize(selectedLanguage) ?? ''));
          break;
        case 'priceAsc':
          sortedList.sort((a, b) => (a.getPrice()?.toSelectedPrice('ETB')?.amount ?? 0)
              .compareTo(b.getPrice()?.toSelectedPrice('ETB')?.amount ?? 0));
          break;
        case 'priceDesc':
          sortedList.sort((a, b) => (b.getPrice()?.toSelectedPrice('ETB')?.amount ?? 0)
              .compareTo(a.getPrice()?.toSelectedPrice('ETB')?.amount ?? 0));
          break;
      }
    } else {
      // Default sort - name ascending
      sortedList.sort((a, b) => (a.name?.localize(selectedLanguage) ?? '')
          .compareTo(b.name?.localize(selectedLanguage) ?? ''));
    }
    
    return sortedList;
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    final businessId = data?['businessId'];
    final sectionId = data?['sectionId'];

    if (businessId != null && sectionId != null) {
      getBusinessSectionDetails(businessId, sectionId);
    }
    
    // Initialize filters
    _initFilters();
  }

  // Initialize filter categories
  void _initFilters() {
    // Sort Category (single select)
    sortCategory.value = FilterCategory(
      id: 'sort',
      name: [LocalizedField(key: 'ENGLISH', value: 'Sort By')],
      selectionType: FilterSelectionType.single.name,
      options: [
        FilterOption(
          id: 'nameAsc',
          name: [LocalizedField(key: 'ENGLISH', value: 'Name (A-Z)')],
          isSelected: true
        ),
        FilterOption(
          id: 'nameDesc',
          name: [LocalizedField(key: 'ENGLISH', value: 'Name (Z-A)')],
        ),
        FilterOption(
          id: 'priceAsc',
          name: [LocalizedField(key: 'ENGLISH', value: 'Price (Low to High)')],
        ),
        FilterOption(
          id: 'priceDesc',
          name: [LocalizedField(key: 'ENGLISH', value: 'Price (High to Low)')],
        ),
      ],
    );
    
    // Set default filter categories
    filterCategories.value = [
      FilterCategory(
        id: 'age',
        name: [LocalizedField(key: 'ENGLISH', value: 'Age Group')],
        options: [
          FilterOption(
            id: 'age_18_24',
            name: [LocalizedField(key: 'ENGLISH', value: '18-24')],
          ),
          FilterOption(
            id: 'age_25_30',
            name: [LocalizedField(key: 'ENGLISH', value: '25-30')],
          ),
          FilterOption(
            id: 'age_31_40',
            name: [LocalizedField(key: 'ENGLISH', value: '31-40')],
          ),
          FilterOption(
            id: 'age_41_plus',
            name: [LocalizedField(key: 'ENGLISH', value: '41+')],
          ),
        ],
      ),
      FilterCategory(
        id: 'gender',
        name: [LocalizedField(key: 'ENGLISH', value: 'Gender')],
        options: [
          FilterOption(
            id: 'gender_male',
            name: [LocalizedField(key: 'ENGLISH', value: 'Male')],
          ),
          FilterOption(
            id: 'gender_female',
            name: [LocalizedField(key: 'ENGLISH', value: 'Female')],
          ),
        ],
      ),
      FilterCategory(
        id: 'type',
        name: [LocalizedField(key: 'ENGLISH', value: 'Product Type')],
        options: [
          FilterOption(
            id: 'type_new', 
            name: [LocalizedField(key: 'ENGLISH', value: 'New Arrival')],
          ),
          FilterOption(
            id: 'type_popular',
            name: [LocalizedField(key: 'ENGLISH', value: 'Popular')],
          ),
          FilterOption(
            id: 'type_limited',
            name: [LocalizedField(key: 'ENGLISH', value: 'Limited Edition')],
          ),
        ],
      ),
    ];
  }
  
  // Toggle filter option - properly handles immutable Freezed objects
  void toggleFilterOption(FilterCategory category, FilterOption option) {
    if (category.selectionType == FilterSelectionType.single.name) {
      // For single selection, create new options with only the selected one
      final updatedOptions = category.options.map((opt) => 
        opt.copyWith(isSelected: opt.id == option.id)
      ).toList();
      
      if (category.id == sortCategory.value?.id) {
        // Update sort category
        sortCategory.value = sortCategory.value!.copyWith(options: updatedOptions);
      } else {
        // Update normal filter category
        final index = filterCategories.indexWhere((c) => c.id == category.id);
        if (index >= 0) {
          final updatedList = List<FilterCategory>.from(filterCategories);
          updatedList[index] = category.copyWith(options: updatedOptions);
          filterCategories.value = updatedList;
        }
      }
    } else {
      // For multi selection, toggle just the target option
      final updatedOptions = category.options.map((opt) => 
        opt.id == option.id ? opt.copyWith(isSelected: !opt.isSelected) : opt
      ).toList();
      
      // Update the category with new options
      final index = filterCategories.indexWhere((c) => c.id == category.id);
      if (index >= 0) {
        final updatedList = List<FilterCategory>.from(filterCategories);
        updatedList[index] = category.copyWith(options: updatedOptions);
        filterCategories.value = updatedList;
      }
    }
  }
  
  // Update price range - properly handles immutable Freezed objects
  void updatePriceRange(RangeValues rangeValues) {
    if (priceRangeCategory.value != null) {
      priceRangeCategory.value = priceRangeCategory.value!.copyWith(
        currentRange: PriceRange.fromRangeValues(rangeValues)
      );
    }
  }

  Future<void> getBusinessSectionDetails(String businessId, String sectionId) async {
    try {
      isLoading.value = true;
      exception.value = null;

      final response = await _businessUsecase.getBusinessSectionDetails(
        businessId, 
        sectionId, 
        branchId: appViewmodel.selectedBranchId
      );

      if (response?.success == true) {
        section.value = response?.sections?.first;
        products.value = response?.products ?? [];
        
        // If section defines custom filter categories, use those
        if (section.value?.filterCategories?.isNotEmpty == true) {
          filterCategories.value = section.value!.filterCategories!;
        }
        
        // Update price range based on actual product prices
        if (products.isNotEmpty) {
          double minPrice = double.infinity;
          double maxPrice = 0;
          
          for (final product in products) {
            final price = product.getPrice()?.toSelectedPrice('ETB')?.amount ?? 0;
            if (price > 0) {
              if (price < minPrice) minPrice = price;
              if (price > maxPrice) maxPrice = price;
            }
          }
          
          if (minPrice < maxPrice) {
            priceRangeCategory.value = PriceRangeFilterCategory.withStringName(
              id: 'priceRange',
              name: 'Price Range',
              min: minPrice,
              max: maxPrice,
            );
          }
        }
      } else {
        exception.value = AppException(
          message: response?.message ?? 'Failed to load section details', 
          isMainError: true
        );
      }
    } catch (e) {
      exception.value = _exceptionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  void openProductDetails(BuildContext context, Product product) {
    // Implementation for product details
  }

  void refresh() {
    if (section.value != null) {
      final businessId = appViewmodel.selectedBusinessId;
      final sectionId = section.value!.id!;
      getBusinessSectionDetails(businessId, sectionId);
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }
  
  // Clear all filters - properly handles immutable Freezed objects
  void clearAllFilters() {
    // Clear tag-based filters - create new instances with cleared selections
    final updatedCategories = filterCategories.map((category) {
      final clearedOptions = category.options.map(
        (option) => option.copyWith(isSelected: false)
      ).toList();
      
      return category.copyWith(options: clearedOptions);
    }).toList();
    
    filterCategories.value = updatedCategories;
    
    // Clear price range filter
    if (priceRangeCategory.value != null) {
      priceRangeCategory.value = priceRangeCategory.value!.copyWith(
        currentRange: null
      );
    }
    
    // Reset sort to default (Name A-Z)
    if (sortCategory.value != null) {
      final updatedOptions = sortCategory.value!.options.map((option) => 
        option.copyWith(isSelected: option.id == 'nameAsc')
      ).toList();
      
      sortCategory.value = sortCategory.value!.copyWith(options: updatedOptions);
    }
    
    // Also ensure searchQuery is cleared
    clearSearch();
  }
  
  // Toggle filter overlay
  void toggleFilterOverlay() {
    showFilterOverlay.value = !showFilterOverlay.value;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
