import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/branch/branch.usecase.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/branch/model/branch.response.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/cart/cart.viewmodel.dart';
import 'package:imela_pos/ui/payment/payment_page.dart';
import 'package:imela_pos/ui/product/components/pos_product_addon_list_modal.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomePageViewmodel extends GetxController with BaseViewmodel {
  final BranchUsecase branchUsecase;
  final IExceptiionHandler exceptiionHandler;

  HomePageViewmodel({
    required this.branchUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static HomePageViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<HomePageViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var categories = <String>[].obs;
  var selectedCategory = 'All'.obs;

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  final cartViewmodel = CartViewmodel.getInstance();

  Cart? get cart {
    return appViewmodel.cartInfo.value;
  }

  Branch? get selectedBranch => appViewmodel.selectedBranch.value;

  List<Product> get allBranchProducts {
    return appViewmodel.selectedBranch.value?.products ?? [];
  }

  List<Product> get getProductsByCategory {
    if (selectedCategory.value == 'All') {
      return allBranchProducts;
    } else {
      return allBranchProducts.where((product) => product.category!.contains(selectedCategory.value)).toList();
    }
  }

  late TabController businessSectionTabControllers;
  ScrollController businessHeaderScrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initViewmodel({Map<String, dynamic>? data}) async {
    super.initViewmodel(data: data);
    final tickerProvider = data?['tickerProvider'];
    assignCategoryTabController(categories.length, tickerProvider);
  }

  void assignCategoryTabController(int length, TickerProvider vsync) {
    var productCategories = allBranchProducts.map((e) => e.category?.firstOrNull ?? '').toSet()..removeWhere((element) => element.isEmpty);
    categories.addAll(['All', ...productCategories]);
    selectedCategory.value = categories[0];
    businessSectionTabControllers = TabController(length: categories.length, vsync: vsync);
    businessSectionTabControllers.addListener(() {
      selectedCategory.value = categories[businessSectionTabControllers.index];
    });
  }

  Future<void> syncPOS(BuildContext context) async {
    try {
      isLoading.value = true;
      final result = await branchUsecase.getPosBranchDetails(appViewmodel.selectedBusinessId, appViewmodel.selectedBranchId);
      if (!result.isPosBranchFetchSuccessfull) {
        exception.value = AppException(message: result!.message ?? 'Unable to get branch details', isMainError: false);
        return;
      }
      appViewmodel.selectBranch(selectedBranch);
    } catch (e) {
      print('error syncing pos: $e');
      exception.value = exceptiionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  List<Widget> geCategoryTabs() {
    return categories.map((e) => Tab(text: e)).toList();
  }

  void navigateToPaymentPage(BuildContext context) {
    PaymentPage.navigate(context);
  }

  void addProductToCartOrUpdateQty(BuildContext context, {double qty = 1, required Product product}) async {
    try {
      List<OrderConfig> orderConfigs = [];
      if (product.hasAddons()) {
        orderConfigs = await showAddonModal(context, product.addons!);
      }
      final isProductInCart = cartViewmodel.isCartContainsProduct(product.id!);
      if (isProductInCart) {
        cartViewmodel.updateProductQty(product.id!, qty: qty);
      } else {
        final orderItem = product.getOrderItem(qty, config: orderConfigs);
        cartViewmodel.addProductToCart(orderItem);
      }
    } catch (ex) {
      print('error adding product to cart: $ex');
    }
  }

  Future<List<OrderConfig>> showAddonModal(BuildContext context, List<ProductAddon> productAddons) async {
    final configResult = await AppModalSheet.showModal<List<OrderConfig>>(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
      ModalContent(title: Text("Addos"), content: PosProductAddonModal(productAddons: productAddons)),
    ]);
    return configResult;
  }

  void updateProductQty(OrderItem item, double qty) {
    cartViewmodel.updateProductQty(item.productId!, qty: qty, reset: true);
  }

  void removeProductFromCart(String productId) {
    cartViewmodel.removeProductFromCart(productId);
  }

  void clearCart() {
    cartViewmodel.clearCart();
  }
}
