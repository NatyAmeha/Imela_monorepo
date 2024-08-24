import 'package:get/get.dart';
import 'package:melegna_customer/domain/order/model/order.model.dart' as OrderModel;
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/domain/order/model/order_item.model.dart';
import 'package:melegna_customer/domain/order/order.usecase.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';
import 'package:melegna_customer/services/routing_service.dart';

@injectable
class OrderDetailviewmodel extends GetxController with BaseViewmodel {
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;
  OrderUsecase orderUsecase;

  OrderDetailviewmodel({
    required this.orderUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  // page state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;

  var orderInfo = Rxn<OrderModel.Order>();


  // controllers
  var orderItemsController = Get.put(CustomListController<OrderItem>(), tag: 'OrderItemsController');

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    var orderId = data?['orderId'] as String?;
    if (orderId != null) {
      getOrderDetails(orderId);
    }
  }

  Future<void> getOrderDetails(String orderId) async {
    try {
      isLoading(true);
      final orderResponse = await orderUsecase.getOrderDetails(orderId);
      if (orderResponse?.success == true) {
        orderInfo.value = orderResponse?.order;
        // orderList.value = orderResponse?.orders ?? [];
        // orderListController.setItems(orderList.value);
      }
    } catch (ex) {
      print("Exception: $ex");
      exception.value = exceptiionHandler.getException(ex as Exception);
    } finally {
      isLoading(false);
    }
  }
}
