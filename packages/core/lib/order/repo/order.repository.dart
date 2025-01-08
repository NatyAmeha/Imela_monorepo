import 'package:imela_core/order/model/order.response.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql/order/__generated__/create_order.data.gql.dart';
import 'package:imela_data/network/graphql/order/__generated__/create_order.req.gql.dart';
import 'package:imela_data/network/graphql/order/__generated__/create_pos_order.data.gql.dart';
import 'package:imela_data/network/graphql/order/__generated__/create_pos_order.req.gql.dart';
import 'package:imela_data/network/graphql/order/__generated__/get_branch_order_schedule.data.gql.dart';
import 'package:imela_data/network/graphql/order/__generated__/get_branch_order_schedule.req.gql.dart';
import 'package:imela_data/network/graphql/order/__generated__/get_pos_order.data.gql.dart';
import 'package:imela_data/network/graphql/order/__generated__/get_pos_order.req.gql.dart';
import 'package:imela_data/network/graphql/order/__generated__/order_detail.data.gql.dart';
import 'package:imela_data/network/graphql/order/__generated__/order_detail.req.gql.dart';
import 'package:imela_data/network/graphql/order/__generated__/order_fetch_query.data.gql.dart';
import 'package:imela_data/network/graphql/order/__generated__/order_fetch_query.req.gql.dart';
import 'package:imela_data/network/graphql/order/__generated__/update_order_status.data.gql.dart';
import 'package:imela_data/network/graphql/order/__generated__/update_order_status.req.gql.dart';
import 'package:imela_data/network/graphql_exception.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_core/order/model/order.model.dart' as OrderModel;

abstract class IOrderRepository {
  Future<OrderResponse?> getOrders({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<OrderResponse?> getOrderDetails(String orderId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
  Future<OrderResponse> createPOSOrder({required String businessId, required OrderModel.Order orderInfo, String? customerId, String? customerName, String? customerPhone});
  Future<OrderResponse?> getPOSOrders(String branchId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
  Future<OrderResponse> createBusinessOrder({required List<String> businessIds, String? cartId, required OrderModel.Order orderInfo, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
  Future<OrderResponse> updateOrderStatus(String businessId, String orderId, String statusId);
  Future<OrderResponse> getBranchOrderSchedules(String branchId, {required ApiDataFetchPolicy fetchPolicy});
  Future<OrderResponse?> getSchedulesByCalendarId(String calendarId, {required ApiDataFetchPolicy fetchPolicy});
}

@Injectable(as: IOrderRepository)
@Named(OrderRepository.injectName)
class OrderRepository implements IOrderRepository {
  static const injectName = 'OrderRepository';
  final IGraphQLDataSource _graphQLDataSource;

  OrderRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);

  @override
  Future<OrderResponse?> getOrders({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork}) async {
    final request = GGetOrdersReq((b) => b..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));

    final result = await _graphQLDataSource.request<GGetOrdersData>(request, type: 'GET_USER_ORDERS', isMainError: true);
    if (result?.getUserOrders == null) {
      return null;
    }
    return OrderResponse.fromJson(result!.getUserOrders.toJson());
  }

  @override
  Future<OrderResponse> createBusinessOrder({required List<String> businessIds, String? cartId, required OrderModel.Order orderInfo, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly}) async {
    print('orderInfo repo: ${orderInfo.config}');
    final request = GCreateOrderReq((b) => b
      ..vars.cartId = cartId
      ..vars.businessIds.addAll(businessIds)
      ..vars.orderInput.update(
            (input) => input
              ..paymentType = orderInfo.paymentType.toPaymentOptionTypeInput
              ..branchId = orderInfo.branchId
              ..note = orderInfo.note
              ..orderNumber = orderInfo.orderNumber?.toDouble()
              ..paidAmount = orderInfo.paidAmount?.toDouble()
              ..remainingAmount = orderInfo.remainingAmount?.toDouble()
              ..subTotal = orderInfo.subTotal?.toDouble()
              ..totalAmount = orderInfo.totalAmount?.toDouble()
              ..config.addAll(orderInfo.config.toOrderConfigInput())
              ..appliedRewards.addAll(orderInfo.appliedRewards ?? [])
              ..usedRewardsPoints = orderInfo.usedRewardsPoints?.toDouble()
              ..paymentMethods.addAll(orderInfo.paymentMethods.toPaymentMethodInput())
              ..branchId = orderInfo.branchId
              ..items.addAll(orderInfo.items!.toOrderItemInput())
              ..discount.addAll(orderInfo.discount.toOrderDiscountInput()),
          )
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    final result = await _graphQLDataSource.request<GCreateOrderData>(request, type: 'CREATE_ORDER', isMainError: true);
    if (result?.placeOrderFromOnlineStore == null) {
      throw GraphqlException(
        message: 'Unable to create Order',
        type: 'CREATE_ORDER',
      );
    }
    return OrderResponse.fromJson(result!.placeOrderFromOnlineStore.toJson());
  }

  @override
  Future<OrderResponse> createPOSOrder({required String businessId, required OrderModel.Order orderInfo, String? customerId, String? customerName, String? customerPhone}) async {

    final request = GCreatePOSOrderReq((b) => b
      ..vars.businessId = businessId
      ..vars.customerId = customerId
      ..vars.orderInput.update(
            (input) => input
              ..paymentType = orderInfo.paymentType.toPaymentOptionTypeInput
              ..branchId = orderInfo.branchId
              ..note = orderInfo.note
              ..orderNumber = orderInfo.orderNumber?.toDouble()
              ..paidAmount = orderInfo.paidAmount?.toDouble()
              ..note = orderInfo.note
              ..remainingAmount = orderInfo.remainingAmount.toDouble()
              ..subTotal = orderInfo.subTotal?.toDouble()
              ..totalAmount = orderInfo.totalAmount?.toDouble()
              ..customerName = customerName
              ..customerPhoneNumber = customerPhone
              ..items.addAll(orderInfo.items!.toOrderItemInput())
              ..paymentMethods.addAll(orderInfo.paymentMethods.toPaymentMethodInput())
              ..discount.addAll(orderInfo.discount.toOrderDiscountInput()),
          ));
    final result = await _graphQLDataSource.request<GCreatePOSOrderData>(request, type: 'CREATE_POS_ORDER', isMainError: true);
    if (result?.placeOrderFromPOS == null) {
      throw GraphqlException(message: 'Unable to create Order', type: 'CREATE_POS_ORDER');
    }
    return OrderResponse.fromJson(result!.placeOrderFromPOS.toJson());
  }

  @override
  Future<OrderResponse?> getOrderDetails(String orderId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork}) async {
    final request = GOrderDetailReq(
      (b) => b
        ..vars.orderId = orderId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GOrderDetailData>(request, type: 'GET_ORDER_DETAILS', isMainError: true);
    if (result?.getOrderDetails == null) {
      return null;
    }
    return OrderResponse.fromJson(result!.getOrderDetails.toJson());
  }

  @override
  Future<OrderResponse?> getPOSOrders(String branchId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork}) async {
    final request = GGetPOSOrdersReq((b) => b
      ..vars.branchId = branchId
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    final result = await _graphQLDataSource.request<GGetPOSOrdersData>(request, type: 'GET_POS_ORDERS', isMainError: true);
    if (result?.getBranchOrders == null) {
      return null;
    }
    return OrderResponse.fromJson(result!.getBranchOrders.toJson());
  }

  @override
  Future<OrderResponse> updateOrderStatus(String businessId, String orderId, String statusId) async {
    final request = GUpdateOrderStatusReq((b) => b
      ..vars.businessId = businessId
      ..vars.orderId = orderId
      ..vars.status = statusId);
    final result = await _graphQLDataSource.request<GUpdateOrderStatusData>(request, type: 'UPDATE_ORDER_STATUS', isMainError: true);
    if (result?.updateOrderStatus == null) {
      throw GraphqlException(message: 'Unable to update Order Status', type: 'UPDATE_ORDER_STATUS');
    }
    return OrderResponse.fromJson(result!.updateOrderStatus.toJson());
  }

  @override
  Future<OrderResponse> getBranchOrderSchedules(String branchId, {required ApiDataFetchPolicy fetchPolicy}) async {
    final request = GGetBranchOrderSchedulesReq((b) => b
      ..vars.branchId = branchId
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    final result = await _graphQLDataSource.request<GGetBranchOrderSchedulesData>(request, type: 'GET_BRANCH_ORDER_SCHEDULES', isMainError: true);
    if (result?.getBranchOrderSchedules == null) {
      throw GraphqlException(message: 'Unable to get Branch Order Schedules', type: 'GET_BRANCH_ORDER_SCHEDULES');
    }
    if (result?.getBranchOrderSchedules.toJson() == null) {
      throw GraphqlException(message: 'Unable to get Branch Order Schedules', type: 'GET_BRANCH_ORDER_SCHEDULES');
    }
    return OrderResponse.fromJson(result?.getBranchOrderSchedules.toJson() ?? {});
  }

  @override
  Future<OrderResponse?> getSchedulesByCalendarId(String calendarId, {required ApiDataFetchPolicy fetchPolicy}) async {
    return null;
    // final request = GGetSchedulesByCalendarIdReq((b) => b
    //   ..vars.calendarId = calendarId
    //   ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    // final result = await _graphQLDataSource.request<GGetSchedulesByCalendarIdData>(request, type: 'GET_SCHEDULES_BY_CALENDAR_ID', isMainError: true);
    // return OrderResponse.fromJson(result?.getSchedulesByCalendarId.toJson() ?? {});
  }
}
