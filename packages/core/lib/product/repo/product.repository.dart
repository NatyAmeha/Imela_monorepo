import 'package:imela_core/product/dto/create_product.input.dart';
import 'package:imela_core/product/dto/product_to_entity_extension.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/product/model/product_price.model.dart';
import 'package:imela_core/product/model/product_response.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';
import 'package:imela_data/network/graphql/graphql_config.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql/product/__generated__/business_products.data.gql.dart';
import 'package:imela_data/network/graphql/product/__generated__/business_products.req.gql.dart';
import 'package:imela_data/network/graphql/product/__generated__/create_product.data.gql.dart';
import 'package:imela_data/network/graphql/product/__generated__/create_product.req.gql.dart';
import 'package:imela_data/network/graphql/product/__generated__/create_product_addon.data.gql.dart';
import 'package:imela_data/network/graphql/product/__generated__/create_product_addon.req.gql.dart';
import 'package:imela_data/network/graphql/product/__generated__/create_product_price.data.gql.dart';
import 'package:imela_data/network/graphql/product/__generated__/create_product_price.req.gql.dart';
import 'package:imela_data/network/graphql/product/__generated__/membership_products.data.gql.dart';
import 'package:imela_data/network/graphql/product/__generated__/membership_products.req.gql.dart';
import 'package:imela_data/network/graphql/product/__generated__/product_detail_queries.data.gql.dart';
import 'package:imela_data/network/graphql/product/__generated__/product_detail_queries.req.gql.dart';
import 'package:injectable/injectable.dart';

abstract class IProductRepository {
  Future<ProductResponse?> getProductDetails(String id, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
  Future<ProductResponse?> getBusinessProducts(String businessId, {int page = 1, int limit = 10, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
  Future<ProductResponse?> createProduct(String businessId, List<CreateProductInput> productInputs);
  Future<ProductResponse?> createProductAddon(String businessId, String productId, List<ProductAddon> addonInputs);
  Future<ProductResponse?> createProductPrice(String businessId, String productId, List<ProductPrice> priceInputs);
  Future<ProductResponse?> getMembershipProducts(String membershipId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});

  Future<List<int>> savePOSProductsToDb({required String dbName, required String businessId, required String branchId,  required List<Product> products});
}

@Injectable(as: IProductRepository)
@Named(ProductRepository.injectName)
class ProductRepository implements IProductRepository {
  static const injectName = 'PRODUCT_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;
  // final IDBDataSource _dbDataSource;

  const ProductRepository(
    @Named(GraphqlDatasource.injectName) this._graphQLDataSource,
    // @Named(POSDBDataSource.injectName) this._dbDataSource,
  );
  @override
  Future<ProductResponse?> getProductDetails(String id, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    final request = GGetProductDetailsReq(
      (b) => b
        ..vars.id = id
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetProductDetailsData>(request, type: GET_PRODUCT_DETAILS, isMainError: true);
    if (result == null) {
      return null;
    }
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    return ProductResponse.fromJson(result.getProductDetail.toJson());
  }

  @override
  Future<ProductResponse?> getBusinessProducts(String businessId, {int page = 1, int limit = 10, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork}) async {
    final request = GGetBusinessProductsReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.page = page.toDouble()
        ..vars.limit = limit.toDouble()
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetBusinessProductsData>(request, type: GET_BUSINESS_PRODUCTS, isMainError: true);
    if (result == null) {
      return null;
    }
    return ProductResponse.fromJson(result.getBusinessProducts.toJson());
  }

  @override
  Future<ProductResponse?> createProduct(String businessId, List<CreateProductInput> productInputs) async {
    final request = GCreateProductReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.input.addAll(
          productInputs.map((input) {
            return GCreateProductInput(
              (b) => b
                ..name.addAll(input.name!.toLocalizedFieldInput())
                ..displayName.addAll(input.name!.toLocalizedFieldInput())
                ..description.addAll(input.description!.toLocalizedFieldInput())
                ..gallery.update((b) => input.gallery?.toGraphQLInput())
                ..tag.addAll(input.tag ?? [])
                ..type = GProductType.PRODUCT
                ..mainProduct = input.mainProduct
                ..options.addAll(
                  input.options?.entries.map((e) => GProductOptionInput((b) => b
                        ..key = e.key
                        ..value.addAll(e.value))) ??
                      [],
                )
                ..optionsIncluded.addAll(input.optionsIncluded ?? [])
                ..category.addAll(input.category ?? [])
                ..inventoryInfo.addAll(
                  input.inventoryInfo!.map(
                    (e) => GCreateInventoryInput(
                      (b) => b
                        ..minOrderQty = e.minOrderQty
                        ..inventoryLocationId = e.inventoryLocationId
                        ..qty = e.qty,
                    ),
                  ),
                )
                ..callToAction = input.callToAction,
            );
          }),
        ),
    );

    final result = await _graphQLDataSource.request<GCreateProductData>(request, type: 'CREATE_PRODUCT', isMainError: true);
    if (result == null) {
      return null;
    }
    return ProductResponse.fromJson(result.createBusinessProducts.toJson());
  }

  @override 
  Future<ProductResponse?> getMembershipProducts(String membershipId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork}) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    final request = GGetMembershipProductsReq(
      (b) => b
        ..vars.membershipId = membershipId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetMembershipProductsData>(request, type: 'GET_MEMBERSHIP_PRODUCTS', isMainError: true);
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    if (result == null) {
      return null;
    }
    return ProductResponse.fromJson(result.getMembershipProducts.toJson());
  }

  @override
  Future<ProductResponse?> createProductAddon(String businessId, String productId, List<ProductAddon> addonInputs) async {
    final request = GcreateProductAddonReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.productId = productId
        ..vars.addons.addAll(
              addonInputs.map(
                (e) => GCreateProductAddonInput(
                  (b) => b
                    ..name.addAll(e.name!.toLocalizedFieldInput())
                    ..inputType = e.inputType
                    ..isRequired = e.isRequired
                    ..additionalPrice.addAll(e.additionalPrice.toPriceInput())
                    ..checkCalendar = e.checkCalendar
                    ..options.addAll(e.options.map((e) => GProductAddonOptionInput((b) => b..name.addAll(e.name!.toLocalizedFieldInput())))),
                ),
              ),
            ),
    );
    final result = await _graphQLDataSource.request<GcreateProductAddonData>(request, type: 'CREATE_PRODUCT_ADDON', isMainError: true);
    if (result == null) {
      return null;
    }
    return ProductResponse.fromJson(result.createProductAddon.toJson());
  }

  @override
  Future<ProductResponse?> createProductPrice(String businessId, String productId, List<ProductPrice> priceInputs) async {
    final request = GcreateProductPriceReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.productId = productId
        ..vars.input.addAll(
              priceInputs.map((e) => GCreateProductPriceInput((b) => b
                ..branchId = e.branchId
                ..price.addAll(e.price.toPriceInput())
                ..isDefault = e.isDefault
                ..priceListId = e.priceListId)),
            ),
    );
    final result = await _graphQLDataSource.request<GcreateProductPriceData>(request, type: 'CREATE_PRODUCT_PRICE', isMainError: true);
    if (result == null) {
      return null;
    }
    return ProductResponse.fromJson(result.createProductPrice.toJson());
  }

  @override
  Future<List<int>> savePOSProductsToDb({required String dbName, required String businessId, required String branchId, required List<Product> products}) async {
    // var dbInstance = await _dbDataSource.getDBInstance(dbName);
    // final productCollection = dbInstance.posCustomerEntitys;
    // final existingProducts = await _dbDataSource.getAllData(dbName, productCollection);
    // final existingProductIds = existingProducts.map((e) => e.id).toSet();
    // final newProducts = products.where((e) => !existingProductIds.contains(e.id)).toList();
    // final productEntities = newProducts.toPOSProductEntity(businessId, branchId);
    // final saveResult = await _dbDataSource.saveMultiple(dbName, collection: productCollection, data: productEntities);
    return [];
  }

  // request type cosntants
  static const String GET_PRODUCT_DETAILS = 'GET_PRODUCT_DETAILS';
  static const String GET_BUSINESS_PRODUCTS = 'GET_BUSINESS_PRODUCTS';
  static const String CREATE_PRODUCT_ADDON = 'CREATE_PRODUCT_ADDON';
}
