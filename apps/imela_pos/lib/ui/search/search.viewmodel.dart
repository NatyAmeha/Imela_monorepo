import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:get/get.dart';
import 'package:imela_core/branch/branch.usecase.dart';
import 'package:imela_core/loyalty/loyalty_usecase.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/cart/component/cart_list_component.dart';
import 'package:imela_pos/ui/home/home_page.viewmodel.dart';
import 'package:imela_pos/ui/search/components/search_result_list_item.dart';
import 'package:imela_pos/ui/search/search.model.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/material.dart';

@injectable
class SearchViewmodel extends GetxController with BaseViewmodel {
  final BranchUsecase branchUsecase;
  final LoyaltyUsecase loyaltyUsecase;
  final IExceptiionHandler exceptiionHandler;

  SearchViewmodel({
    required this.branchUsecase,
    required this.loyaltyUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static SearchViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<SearchViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var categories = <String>[].obs;
  var selectedCategory = 'All'.obs;

  // Add new state variables
  var searchType = SearchType.product.obs;
  var searchQuery = ''.obs;
  var searchResults = <SearchModel>[].obs;
  var sortOption = 'name'.obs;
  var sortOptions = const ['name', 'date', 'price'].obs;
  var filterOptions = <String, List<dynamic>>{}.obs;
  var selectedFilterOptions = <String, List<dynamic>>{}.obs;

  var searchController = TextEditingController();

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  HomePageViewmodel get homePageViewmodel => HomePageViewmodel.getInstance();
  String get selectedLanguage => appViewmodel.selectedLanguage;
  String get selectedCurrency => appViewmodel.selectedCurrency;
  Set<String> get productCategories => appViewmodel.allProducts.flatMap((e) => e.category ?? <String>[]).toSet()..removeWhere((element) => element.isEmpty);

  List<String> get selectedOptionValues => selectedFilterOptions.values.map((value) => value.map((e) => e.toString())).flattened.toList();
  List<String> getFilterOptions(String key) => (filterOptions[key] ?? []).map((e) => e.toString()).toList();

  Map<SearchType, Widget> get searchTypeOptionsMap {
    return SearchType.values.asMap().map((key, value) {
      if (value == SearchType.product) {
        return MapEntry(value, const Text('Products'));
      } else if (value == SearchType.order) {
        return MapEntry(value, const Text('Orders'));
      }
      return MapEntry(value, Text(value.name));
    });
  }

  List<Product> get allBranchProducts {
    if (selectedCategory.value == 'All') {
      return appViewmodel.selectedBranch.value?.products ?? [];
    } else {
      return appViewmodel.selectedBranch.value?.products?.where((product) => product.category!.contains(selectedCategory.value)).toList() ?? [];
    }
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    filterOptions.clear();
    selectedFilterOptions.clear();
    Future.delayed(Duration.zero, () {
      if (searchType.value == SearchType.product) {
        filterOptions.value = <String, List<dynamic>>{
          SearchFilterType.CATEGORY.name: [...productCategories],
          SearchFilterType.STATUS.name: ['Pending', 'Completed', 'Cancelled'],
        };
      }
    });
  }

  // Add new methods
  void setSearchType(SearchType type) {
    searchType.value = type;
    performSearch();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    searchController.text = query;
    performSearch();
  }

  void setSortOption(String option) {
    sortOption.value = option;
    performSearch();
  }

  void setFilterOptions(Map<String, List<dynamic>> options) {
    selectedFilterOptions.addAll(options);
    performSearch();
  }

  Map<String, Widget> getSortOptionsMap(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return sortOptions.asMap().map((key, value) => MapEntry(value, widgetFactory.createText(context, value, style: Theme.of(context).textTheme.bodyMedium)));
  }

  Future<void> performSearch({bool filter = true}) async {
    isLoading.value = true;
    exception.value = null;

    try {
      // Determine which search method to use based on searchType
      switch (searchType.value) {
        case SearchType.product:
          searchResults.value = await _searchProducts();
          break;

        case SearchType.order:
          searchResults.value = await _searchOrders();
          break;
        default:
          throw Exception('Invalid search type');
      }

      // // Apply sorting
      // _sortResults();

      // Apply filtering
      if (filter) _filterResults();
    } catch (e) {
      exception.value = exceptiionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods for search, sort, and filter
  Future<List<SearchModel>> _searchProducts({bool resetToAll = false}) async {
    final products = (resetToAll || searchQuery.value.isEmpty) ? allBranchProducts : allBranchProducts.where((product) => product.name.containsValue(searchQuery.value)).toList();
    final searchResult = products
        .map(
          (product) => SearchModel(
            type: SearchType.product,
            id: product.id!,
            category: product.category,
            name: product.name.localize(selectedLanguage),
            image: product.getImageUrl(),
            price: product.getPrice()?.toSelectedPrice(selectedCurrency)?.amount,
          ),
        )
        .toList();
    return searchResult;
  }

  // Future<List<dynamic>> _searchCustomers() async {
  //   // Implement customer search logic using loyaltyUsecase
  //   return await loyaltyUsecase.searchCustomers(searchQuery.value);
  // }

  Future<List<SearchModel>> _searchOrders() async {
    return ['SEarch order one'].map((e) => SearchModel(type: SearchType.order, id: e, name: e)).toList();
  }

  void _sortResults() {
    searchResults.sort((a, b) {
      switch (sortOption.value) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'price':
          return a.price?.compareTo(b.price ?? 0) ?? 0;
        case 'date':
          return a.date?.compareTo(b.date ?? DateTime.now()) ?? 0;
        default:
          return 0;
      }
    });
  }

  void _filterResults() async {
    print('selectedFilterOptions: ${selectedFilterOptions.values} --- ${selectedFilterOptions.values.map((e) => e.isEmpty).all((e) => e)}');
    if (selectedFilterOptions.values.map((e) => e.isEmpty).all((e) => e)) {
      performSearch(filter: false);
      return;
    }

    searchResults.value = searchResults.where(
      (result) {
        bool passesFilter = true;

        selectedFilterOptions.forEach((key, value) {
          if (result.type == SearchType.product) {
            if (key == SearchFilterType.CATEGORY.name) {
              print('filterOptions: $key $value ${result.category}');
              passesFilter = result.category?.any((category) => value.contains(category)) ?? false;
            }
          }
        });
        return passesFilter;
      },
    ).toList();
  }

  Widget buildUI(BuildContext context) {
    if (searchType.value == SearchType.product) {
      return Expanded(
        child: AppGridView(
          items: searchResults,
          isStaggered: true,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          crossAxisCount: Responsive.getGridCount(context, itemWidth: 200),
          itemBuilder: (context, item, index) {
            return SearchResultListItem(
                searchInfo: item,
                imageHeight: 175,
                imageWidth: 200,
                widgetFactory: AppViewmodel.getWidgetFactory(context),
                onTap: () {
                  final productInfo = item.getProductInfo(products: allBranchProducts);
                  if (productInfo != null) {
                    homePageViewmodel.addProductToCartOrUpdateQty(context, product: productInfo);
                  } 
                });
          },
        ),
      );
    }
    return const SizedBox();
  }

  void showSearchResults(BuildContext context, SearchModel searchModel) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    if (searchModel.type == SearchType.product) {
      Row(children: [
        widgetFactory.createText(context, searchModel.name),
        widgetFactory.createText(context, searchModel.price.toString()),
      ]);
    } else if (searchModel.type == SearchType.order) {}
  }

  void removeFilterOption(String key, List<dynamic> remainingSelectedOptions) {
    selectedFilterOptions[key] = remainingSelectedOptions;
    performSearch();
  }

  bool isSelectedFilterOption(String key, List<dynamic> options) {
    return selectedFilterOptions[key]?.any((value) => options.contains(value)) ?? false;
  }

  void navigateToHompage(BuildContext context) {
    if (Responsive.isSmallScreen(context)) {
      CartListPage.navigate(context);
    } else {
      appViewmodel.appRouter.goBack(context);
    }
  }
}
