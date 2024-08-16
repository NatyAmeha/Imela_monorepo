import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/graphql/__generated__/schema.schema.gql.dart';
import 'package:melegna_customer/data/network/graphql/cart/__generated__/add_to_business_cart.data.gql.dart';
import 'package:melegna_customer/data/network/graphql/cart/__generated__/add_to_business_cart.req.gql.dart';
import 'package:melegna_customer/data/network/graphql/cart/__generated__/get_user_cart.data.gql.dart';
import 'package:melegna_customer/data/network/graphql/cart/__generated__/get_user_cart.req.gql.dart';
import 'package:melegna_customer/data/network/graphql/cart/__generated__/remove_item_from_cart.data.gql.dart';
import 'package:melegna_customer/data/network/graphql/cart/__generated__/remove_item_from_cart.req.gql.dart';
import 'package:melegna_customer/data/network/graphql_datasource.dart';
import 'package:melegna_customer/domain/order/model/order.response.dart';
import 'package:melegna_customer/domain/order/model/order_item.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/utils/exception/graphql_exception.dart';
import 'package:melegna_customer/presentation/utils/graphql_input_utils.dart';

abstract class ICartRepository {
  Future<OrderResponse?> getCarts({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
  Future<OrderResponse> addtoCart(String businessId, List<LocalizedField> cartName, List<OrderItem> items);
  Future<OrderResponse> removeItemsFromCart(String cartId, List<String> productIds);
}

@Injectable(as: ICartRepository)
@Named(CartRepository.injectName)
class CartRepository implements ICartRepository {
  static const injectName = 'CartRepository';
  final IGraphQLDataSource _graphQLDataSource;

  CartRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);
  @override
  Future<OrderResponse?> getCarts({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork}) async {
    final result = await _graphQLDataSource.request<GGetUserCartData>(GGetUserCartReq((b) => b..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy)), type: 'GET_USER_CART', isMainError: true);
    if (result == null) {
      return null;
    }
    return OrderResponse.fromJson(result.getUserCarts.toJson());
  }

  @override
  Future<OrderResponse> addtoCart(String businessId, List<LocalizedField> cartName, List<OrderItem> items, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly}) async {
    final request = GAddToBusinessCartReq((b) => b
      ..vars.businessId = businessId
      ..vars.cartInput.update((input) {
        input.name.addAll(cartName.toLocalizedFieldInput());
        input.items.addAll(items.toOrderItemInput());
      })
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    final result = await _graphQLDataSource.request<GAddToBusinessCartData>(request, type: 'ADD_TO_CART', isMainError: false);
    if (result == null) {
      throw GraphqlException(message: 'Failed to add to cart', type: 'ADD_TO_CART', );
    }
    return OrderResponse.fromJson(result.addToBusinessCart.toJson());
  }

  @override
  Future<OrderResponse> removeItemsFromCart(String cartId, List<String> productIds, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork}) async {
    final request = GRemoveItemsFromCartReq((b) => b
      ..vars.cartId = cartId
      ..vars.productIds.addAll(productIds)
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    final result = await _graphQLDataSource.request<GRemoveItemsFromCartData>(request, type: 'REMOVE_FROM_CART', isMainError: false);
    if (result?.removeItemsFromCart == null) {
      throw GraphqlException(
        message: 'Failed to remove items from cart',
      );
    }
    return OrderResponse.fromJson(result!.removeItemsFromCart.toJson());
  }
}
