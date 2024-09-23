import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/ui/product/create_product_page.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_core/product/product.usecase.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';

@injectable
class ProductListViewModel extends GetxController with BaseViewmodel {
  final ProductUsecase productUsecase;
  final IExceptiionHandler exceptionHandler;

  ProductListViewModel({
    required this.productUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptionHandler,
  });

  AppViewmodel get appviewmodel => AppViewmodel.getInstance();

  static ProductListViewModel getInstance() => BaseViewmodel.isViewmodelRegistered(getIt<ProductListViewModel>());

  // state variables
  var isLoading = false.obs;
  var products = <Product>[].obs;
  var exception = Rxn<AppException>();

  var page = 1.obs;
  var limit = 10.obs;

  var selectedTabIndex = 0.obs;
  var searchQuery = ''.obs;

  // Initialize some products for example purposes

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      exception.value = null;
      isLoading.value = true;
      products.value = [];
      
      final result = await productUsecase.getBusinessProducts(appviewmodel.selectedBusinessId!, page: page.value, pageSize: limit.value);
      print('result: ${result?.products?.length}');
      if (result?.success == true) {
        final productResult = result!.products ?? [];
        if (page.value == 1) {
          products.assignAll(productResult);
        } else {
          products.addAll(products);
        }
      } 
    } catch (e) {
      print('Error fetching products: $e');
      exception.value = exceptionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  // Filter products based on the selected tab and search query
  List<Product> get filteredProducts {
    return products.where((product) {
      // Search filter
      if (product.name?.containsValue(searchQuery.value.toLowerCase()) == false) {
        return false;
      }

      // Tab filter (0: All, 1: Featured, 2: Active)
      if (selectedTabIndex.value == 1 && !product.featured) {
        return false;
      }
      if (selectedTabIndex.value == 2 && !product.isActive) {
        return false;
      }

      return true;
    }).toList();
  }

  // Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Update selected tab index
  void updateTabIndex(int index) {
    selectedTabIndex.value = index;
  }

  void navigateToCreateProductPage(BuildContext context) {
    final businessInfo = appviewmodel.selectedBusiness.value;
    if (businessInfo != null) {
      CreateProductPage.navigate(context, businessInfo);
    }
  }
}
