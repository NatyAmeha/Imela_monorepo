import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/graphql/product/__generated__/product_queries.data.gql.dart';
import 'package:melegna_customer/data/network/graphql/product/__generated__/product_queries.req.gql.dart';
import 'package:melegna_customer/data/network/graphql_datasource.dart';
import 'package:melegna_customer/data/network/product_response.dart';

abstract class IProductRepository {
  Future<ProductResponse?> getProductDetails(String id, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
}

@Injectable(as: IProductRepository)
@Named(ProductRepository.injectName)
class ProductRepository implements IProductRepository {
  static const injectName = 'PRODUCT_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;

  const ProductRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);
  @override
  Future<ProductResponse?> getProductDetails(String id, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly}) async {
    final request = GGetProductDetailsReq(
      (b) => b
        ..vars.id = id
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.query<GGetProductDetailsData>(request, type: GET_PRODUCT_DETAILS, isMainError: true);
    if (result == null) {
      return null;
    }
    return ProductResponse.fromJson(result.getProductDetail.toJson());
  }


  // request type cosntants
  static const  String GET_PRODUCT_DETAILS = 'GET_PRODUCT_DETAILS';
}
