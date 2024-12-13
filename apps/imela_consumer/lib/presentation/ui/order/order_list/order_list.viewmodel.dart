import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/order/order_details/order_details_page.dart';
import 'package:imela/presentation/ui/order/order_list/order_list_page.dart';
import 'package:imela/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/order/model/order.model.dart' as OrderModel;
import 'package:imela_core/order/order.usecase.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

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

  static OrderListViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<OrderListViewmodel>());
  }

  // page state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;

  var orderList = <OrderModel.Order>[].obs;

  var orderListController = Get.put(CustomListController<OrderModel.Order>(), tag: 'OrderListController');

  // getters
  AppController get appViewmodel => AppController.getInstance;
  List<OrderModel.Order> get sortedOrderList => orderList.value.sortedByDescending((order) => order.createdAt ?? DateTime.now());

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    var context = data?['context'] as BuildContext;
    getUserOrders(context);
  }

  Future<void> getUserOrders(BuildContext context) async {
    try {
      isLoading(true);
      exception.value = null;
      final orderResponse = await orderUsecase.getOrders(fetchPolicy: appViewmodel.refetchOrderList.value ? ApiDataFetchPolicy.networkOnly : ApiDataFetchPolicy.cacheFirst);
      if (orderResponse?.success == true) {
        appViewmodel.setRefetchOrderList(false);
        orderList.value = orderResponse?.orders ?? [];
        orderListController.setItems(sortedOrderList);
      }
    } catch (e) {
      var ex = exceptiionHandler.getException(e as Exception);
      if (ex.isUnAuthorizedException == true) {
        await appViewmodel.refreshTokenOrLogout(context, moveToLogin: true, showLoginMessage: true, redirectUrl: OrderListPage.routeName, redirectExtra: {});
      }
      exception.value = ex;
    } finally {
      isLoading(false);
    }
  }

  void navigateToOrderDetailPage(BuildContext context, OrderModel.Order order) {
    OrderDetailPage.navigate(context, router, order.id!);
  }
}
