import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/graphql/order/__generated__/create_order.data.gql.dart';
import 'package:melegna_customer/data/network/graphql/order/__generated__/create_order.req.gql.dart';
import 'package:melegna_customer/data/network/graphql/order/__generated__/order_detail.data.gql.dart';
import 'package:melegna_customer/data/network/graphql/order/__generated__/order_detail.req.gql.dart';
import 'package:melegna_customer/data/network/graphql/order/__generated__/order_fetch_query.data.gql.dart';
import 'package:melegna_customer/data/network/graphql/order/__generated__/order_fetch_query.req.gql.dart';
import 'package:melegna_customer/data/network/graphql_datasource.dart';
import 'package:melegna_customer/domain/order/model/order.model.dart' as OrderModel;
import 'package:melegna_customer/domain/order/model/order.response.dart';
import 'package:melegna_customer/domain/order/model/order_item.model.dart';
import 'package:melegna_customer/presentation/utils/exception/graphql_exception.dart';
import 'package:melegna_customer/presentation/utils/graphql_input_utils.dart';

abstract class IOrderRepository {
  Future<OrderResponse?> getOrders({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
  Future<OrderResponse?> getOrderDetails(String orderId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
  Future<OrderResponse> createOrder({String? cartId, required OrderModel.Order orderInfo, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
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
  Future<OrderResponse> createOrder({String? cartId, required OrderModel.Order orderInfo, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork}) async {
    final request = GCreateOrderReq((b) => b
      ..vars.cartId = cartId
      ..vars.orderInput.update(
            (input) => input
              ..paymentType = orderInfo.paymentType.toPaymentOptionTypeInput
              ..branchId = orderInfo.branchId
              ..note = orderInfo.note
              ..orderNumber = orderInfo.orderNumber?.toDouble()
              ..remainingAmount = orderInfo.remainingAmount?.toDouble()
              ..subTotal = orderInfo.subTotal?.toDouble()
              ..totalAmount = orderInfo.totalAmount?.toDouble()
              ..items.addAll(orderInfo.items!.toOrderItemInput())
              ..discount.addAll(orderInfo.discount.toOrderDiscountInput()),
          )
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    final result = await _graphQLDataSource.request<GCreateOrderData>(request, type: 'CREATE_ORDER', isMainError: true);
    if (result?.placeOrderFromOnlineStore == null) {
      throw GraphqlException(message: 'Unable to create Order', type: 'CREATE_ORDER',);
    }
    return OrderResponse.fromJson(result!.placeOrderFromOnlineStore.toJson());
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
}
