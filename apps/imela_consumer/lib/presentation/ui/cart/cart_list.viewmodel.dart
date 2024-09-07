import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/cart/cart_detail_page.dart';
import 'package:imela/presentation/ui/shared/base_viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/order/order.usecase.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';

@injectable
class CartListViewmodel extends GetxController with BaseViewmodel {
  static const FETCH_CART_FROM_API_KEY = 'fetch_cart_from_api';

  // page state variables
  final isLoading = false.obs;
  final exception = Rxn<AppException>();

  final OrderUsecase orderUsecase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;
  CartListViewmodel({
    required this.orderUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  AppController get appController => AppController.getInstance;

  var isCartFetchSuccessfull = false.obs;

  List<Cart> get carts => appController.carts;

  late BuildContext context;

  //controller
  var cartListController = Get.put(CustomListController<Cart>(), tag: 'CART_LIST_CONTROLLER');

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    final fetchCartFromApi = data?[FETCH_CART_FROM_API_KEY] as bool? ?? true;
    context = data?['context'] as BuildContext;
    super.initViewmodel(data: data);
    if (fetchCartFromApi) {
      getCartsFromApi();
    }
  }

  Future<void> getCartsFromApi() async {
    try {
      isLoading(true);
      exception(null);

      final response = await orderUsecase.getUserCartList();
      if (response?.success == true) {
        isCartFetchSuccessfull(true);
        appController.addCartsToCartList(response?.carts ?? [], clearPrevious: true);
      }
      cartListController.setItems(appController.carts);
    } catch (ex) {
      exception.value = exceptiionHandler.getException(ex as Exception);
      if (exception.value!.isUnAuthorizedException) {
        appController.logout(context);
      }
    } finally {
      isLoading(false);
    }
  }

  void handleCartSelection(BuildContext context, Cart cart) {
    CartDetailPage.navigateToCartDetailPage(context, router, cart);
  }

  @override
  void dispose() {
    cartListController.dispose();
    super.dispose();
  }
}
