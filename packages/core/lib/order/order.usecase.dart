import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/order/model/order.response.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/order/repo/cart.repository.dart';
import 'package:imela_core/order/repo/order.repository.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_utils/storage/storage_usecase.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_core/order/model/order.model.dart' as OrderModel;

@injectable
class OrderUsecase {
  final IOrderRepository _orderRepo;
  final ICartRepository _cartRepo;
  final StorageUseCase _storageUseCase;
  

  const OrderUsecase(
    this._storageUseCase,
    @Named(OrderRepository.injectName) this._orderRepo,
    @Named(CartRepository.injectName) this._cartRepo,
  );

  Future<OrderResponse?> getUserCartList() async {
    final result = await _cartRepo.getCarts(fetchPolicy: ApiDataFetchPolicy.networkOnly);
    return result;
  }

  Future<OrderResponse> removeItemsFromCart(String cartId, List<String> productIds) async {
    final result = await _cartRepo.removeItemsFromCart(cartId, productIds);
    return result;
  }

  Future<OrderResponse?> addToCart(String businessId, List<LocalizedField> cartName, List<OrderItem> items, {List<PaymentOption>? paymentOptions, List<OrderConfig> orderConfigs = const []}) async {
    final result = await _cartRepo.addtoCart(businessId, cartName, items, paymentOptions: paymentOptions, orderConfigs: orderConfigs);
    return result;
  }

  Future<OrderResponse> placeOrderForBusiness(List<String> businessIds, String? cartId, OrderModel.Order orderInfo) async {
    final paymentProofImageInfo = orderInfo.getPaymentProofImages();
    final uploadResult = await _storageUseCase.uploadOrderPaymentProof(businessIds.first, paymentProofImageInfo);
    OrderModel.Order updatedOrder = orderInfo;
    if (uploadResult.isNotEmpty) {
      updatedOrder = orderInfo.addPaymentProofImages(uploadResult);
    }

    final result = await _orderRepo.createBusinessOrder(businessIds: businessIds, cartId: cartId, orderInfo: updatedOrder);
    if (result.success ?? false) {
      _storageUseCase.removeCachedImageUrls();
    }
    return result;
  }

  Future<OrderResponse> placePOSBusiness(String businessId, OrderModel.Order orderInfo, {String? customerId, String? customerName, String? customerPhone}) async {
    final result = await _orderRepo.createPOSOrder(businessId: businessId, orderInfo: orderInfo, customerId: customerId, customerName: customerName, customerPhone: customerPhone);
    return result;
  }

  Future<OrderResponse?> getOrders({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _orderRepo.getOrders(fetchPolicy: fetchPolicy);
    if ((result?.success ?? false) && fetchPolicy == ApiDataFetchPolicy.cacheFirst) {
      result = await _orderRepo.getOrders(fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<OrderResponse?> getPOSOrders(String branchId) async {
    final result = await _orderRepo.getPOSOrders(branchId);
    return result;
  }

  Future<OrderResponse> updateOrderStatus(String businessId, String orderId, String statusId) async {
    final result = await _orderRepo.updateOrderStatus(businessId, orderId, statusId);
    return result;
  }

  Future<OrderResponse?> getOrderDetails(String orderId) async {
    final result = await _orderRepo.getOrderDetails(orderId);
    return result;
  }

  Future<OrderResponse?> getBranchOrderSchedules(String branchId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly}) async {
    final result = await _orderRepo.getBranchOrderSchedules(branchId, fetchPolicy: fetchPolicy);
    if (!(result.success ?? false) && fetchPolicy == ApiDataFetchPolicy.cacheFirst) {
      return await _orderRepo.getBranchOrderSchedules(branchId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }

    return result;
  }

  Future<OrderResponse?> getSchedulesByCalendarId(String calendarId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final result = await _orderRepo.getSchedulesByCalendarId(calendarId, fetchPolicy: fetchPolicy);
    return result;
  }
}
