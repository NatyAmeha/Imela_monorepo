import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import 'package:imela/domain/business/model/payment_method.model.dart';
import 'package:imela/domain/business/model/payment_option.model.dart';
import 'package:imela/domain/order/model/cart.model.dart';
import 'package:imela/domain/order/model/order.model.dart' as OrderModel;
import 'package:imela/domain/order/order.usecase.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/home/home.page.dart';
import 'package:imela/presentation/ui/order/order_confirmation/order_confirmation_page.dart';

import 'package:imela/presentation/ui/shared/base_viewmodel.dart';
import 'package:imela/presentation/utils/exception/app_exception.dart';
import 'package:imela/services/routing_service.dart';

@injectable
class OrderConfigureViewmodel extends GetxController with BaseViewmodel {
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;
  OrderUsecase orderUsecase;

  OrderConfigureViewmodel({
    required this.orderUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  AppController get appController => AppController.getInstance;

  // page state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;

  var cartInfo = Rxn<Cart>();
  var selectedPaymentMethod = Rxn<PaymentMethod>();

  var selectedPaymentOption = Rxn<PaymentOption>();
  String get selectedPaymentOptionId => selectedPaymentOption.value!.id!;

  double get totalAmount {
    return selectedPaymentOption.value?.currentPayment(cartInfo.value!.getTotalPrice) ?? 0.0;
  }
 

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    cartInfo.value = data?['cart'] as Cart?;
    selectedPaymentOption.value = cartInfo.value?.paymentOptions?.firstOrNull ?? PaymentOption.defaultPaymentOption();
    super.initViewmodel(data: data);
  }

  void selectPaymentOption(PaymentOption paymentOption) {
    selectedPaymentOption.value = paymentOption;
  }

  void selectPaymentMethod(PaymentMethod paymentMethod) {
    selectedPaymentMethod.value = paymentMethod;
  }

  Future<void> placeOrder(BuildContext context) async {
    try {
      if (cartInfo.value == null || selectedPaymentOption.value == null) {
        return;
      }
      isLoading(true);
      final orderInfo = OrderModel.Order.createOrderInfo(cartInfo.value!, selectedPaymentOption.value!);
      var placeOrderResult = await orderUsecase.placeOrder(cartInfo.value!.id!, orderInfo);
      if (placeOrderResult.success == true) {
        appController.removeCart(cartInfo!.value!.id!);
        OrderConfirmationPage.navigate(context, router, placeOrderResult.order!);
      } else {
        errorMessage(placeOrderResult.message);
      }
    } catch (e) {
      print("exception ${e.toString()}");
      exceptiionHandler.getException(e as Exception);
    } finally {
      isLoading(false);
    }
  }

  void navigateToHome(BuildContext context) {
    HomePage.navigate(context, router, replace: true);
  }
}
