import 'package:imela_core/business/model/business_response.dart';
import 'package:imela_core/product/dto/product_price.response.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql/product_price/__generated__/get_products_price_and_price_list.data.gql.dart';
import 'package:imela_data/network/graphql/product_price/__generated__/get_products_price_and_price_list.req.gql.dart';
import 'package:imela_data/network/graphql/product_price/__generated__/update_product_price.data.gql.dart';
import 'package:imela_data/network/graphql/product_price/__generated__/update_product_price.req.gql.dart';
import 'package:imela_data/network/graphql/product_price/__generated__/add_price_list.data.gql.dart';
import 'package:imela_data/network/graphql/product_price/__generated__/add_price_list.req.gql.dart';
import 'package:imela_data/network/graphql/product_price/__generated__/update_price_list.data.gql.dart';
import 'package:imela_data/network/graphql/product_price/__generated__/update_price_list.req.gql.dart';
import 'package:imela_data/network/graphql/product_price/__generated__/create_product_price.data.gql.dart';
import 'package:imela_data/network/graphql/product_price/__generated__/create_product_price.req.gql.dart';
import 'package:injectable/injectable.dart';

abstract class IProductPriceRepository {
  Future<ProductPriceResponse?> getProductsPriceAndPriceList({
    required String businessId,
    required List<String> productIds,
    String? branchId,
    ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst,
  });

  Future<ProductPriceResponse?> updateProductPrice({required String businessId, required String productId, required String productPriceId, required String priceListId, required String branchId, required List<Price> prices, bool isDefault = false});

  Future<BusinessResponse?> addPriceListToBusiness({
    required String businessId,
    required List<LocalizedField> name,
    required List<LocalizedField> description,
    required List<String> branchIds,
  });

  Future<BusinessResponse?> updateBusinessPriceList({
    required String businessId,
    required String priceListId,
    required List<LocalizedField> name,
    required List<LocalizedField> description,
    required List<String> branchIds,
    bool? isActive,
  });

  Future<ProductPriceResponse?> createProductPrice({
    required String businessId,
    required String productId,
    required String priceListId,
    required String branchId,
    required List<Price> prices,
    bool isDefault = false,
  });
}

@Injectable(as: IProductPriceRepository)
@Named(ProductPriceRepository.injectName)
class ProductPriceRepository implements IProductPriceRepository {
  static const injectName = 'ProductPriceRepository';
  final IGraphQLDataSource _graphQLDataSource;

  ProductPriceRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);

  @override
  Future<ProductPriceResponse?> getProductsPriceAndPriceList({
    required String businessId,
    required List<String> productIds,
    String? branchId,
    ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst,
  }) async {
    final request = GGetProductsPriceAndPriceListReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.productIds.addAll(productIds)
        ..vars.branchId = branchId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );

    final result = await _graphQLDataSource.request<GGetProductsPriceAndPriceListData>(
      request,
      type: 'GET_PRODUCTS_PRICE_AND_PRICE_LIST',
      isMainError: true,
    );

    if (result?.getProductsPriceAndPriceList == null) {
      return null;
    }

    return ProductPriceResponse.fromJson(result!.getProductsPriceAndPriceList.toJson());
  }

  @override
  Future<ProductPriceResponse?> updateProductPrice({
    required String businessId,
    required String productId,
    required String productPriceId,
    required String priceListId,
    required String branchId,
    required List<Price> prices,
    bool isDefault = false,
  }) async {
    final request = GUpdateProductPriceReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.productId = productId
        ..vars.input.addAll(
          [
            GUpdateProductPriceInput(
              (b) => b
                ..id = productPriceId
                ..branchId = branchId
                ..priceListId = priceListId
                ..isDefault = isDefault
                ..price.addAll(prices.toPriceInput()),
            ),
          ],
        ),
    );

    final result = await _graphQLDataSource.request<GUpdateProductPriceData>(
      request,
      type: 'UPDATE_PRODUCT_PRICE',
      isMainError: true,
    );

    if (result?.updateProductPricing == null) {
      return null;
    }

    return ProductPriceResponse.fromJson(result!.updateProductPricing.toJson());
  }

  @override
  Future<BusinessResponse?> addPriceListToBusiness({
    required String businessId,
    required List<LocalizedField> name,
    required List<LocalizedField> description,
    required List<String> branchIds,
  }) async {
    final request = GAddPriceListToBusinessReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.input.addAll(
          [
            GCreatePriceListInput((b) => b
              ..name.addAll(name.toLocalizedFieldInput())
              ..description.addAll(description.toLocalizedFieldInput())
              ..branchIds.addAll(branchIds)
              ..isActive = true),
          ],
        ),
    );

    final result = await _graphQLDataSource.request<GAddPriceListToBusinessData>(
      request,
      type: 'ADD_PRICE_LIST_TO_BUSINESS',
      isMainError: true,
    );

    if (result?.addPriceListTobusiness == null) {
      return null;
    }

    return BusinessResponse.fromJson(result!.addPriceListTobusiness.toJson());
  }

  @override
  Future<BusinessResponse?> updateBusinessPriceList({
    required String businessId,
    required String priceListId,
    required List<LocalizedField> name,
    required List<LocalizedField> description,
    required List<String> branchIds,
    bool? isActive,
  }) async {
    final request = GUpdateBusinessPriceListReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.input.addAll(
          [
            GUpdatePriceListInput((b) => b
              ..id = priceListId
              ..name.addAll(name.toLocalizedFieldInput())
              ..description.addAll(description.toLocalizedFieldInput())
              ..branchIds.addAll(branchIds)
              ..isActive = isActive),
          ],
        ),
    );

    final result = await _graphQLDataSource.request<GUpdateBusinessPriceListData>(
      request,
      type: 'UPDATE_BUSINESS_PRICE_LIST',
      isMainError: true,
    );

    if (result?.updateBusinessPriceList == null) {
      return null;
    }

    return BusinessResponse.fromJson(result!.updateBusinessPriceList.toJson());
  }

  @override
  Future<ProductPriceResponse?> createProductPrice({
    required String businessId,
    required String productId,
    required String priceListId,
    required String branchId,
    required List<Price> prices,
    bool isDefault = false,
  }) async {
    final request = GCreateProductPriceReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.productId = productId
        ..vars.input.addAll(
          [
            GCreateProductPriceInput(
              (b) => b
                ..branchId = branchId
                ..priceListId = priceListId
                ..isDefault = isDefault
                ..price.addAll(prices.toPriceInput()),
            ),
          ],
        ),
    );

    final result = await _graphQLDataSource.request<GCreateProductPriceData>(
      request,
      type: 'CREATE_PRODUCT_PRICE',
      isMainError: true,
    );

    if (result?.createProductPrice == null) {
      return null;
    }

    return ProductPriceResponse.fromJson(result!.createProductPrice.toJson());
  }
}
