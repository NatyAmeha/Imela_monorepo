import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/domain/order/model/order.model.dart' as OrderModel;
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/domain/order/order.usecase.dart';
import 'package:melegna_customer/presentation/ui/order/order_details/order_details_page.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';
import 'package:melegna_customer/services/routing_service.dart';

@injectable
class OrderListViewmodel extends GetxController with BaseViewmodel {
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;
  OrderUsecase orderUsecase;

  OrderListViewmodel({
    required this.orderUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  // page state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;

  var orderList = <OrderModel.Order>[].obs;

  var orderListController = Get.put(CustomListController<OrderModel.Order>(), tag: 'OrderListController');

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    getUserOrders();
  }

  Future<void> getUserOrders() async {
    try {
      isLoading(true);
      final orderResponse = await orderUsecase.getOrders();
      if (orderResponse?.success == true) {
        orderList.value = orderResponse?.orders ?? [];
        orderListController.setItems(orderList.value);
      }
    } catch (ex) {
      exception.value = exceptiionHandler.getException(ex as Exception);
    } finally {
      isLoading(false);
    }
  }

  void navigateToOrderDetailPage(BuildContext context, OrderModel.Order order) {
    OrderDetailPage.navigate(context, router, order.id!);
  }
}
