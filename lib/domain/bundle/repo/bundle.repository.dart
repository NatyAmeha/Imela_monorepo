import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/graphql/bundle/__generated__/bundle_detail_query.data.gql.dart';
import 'package:melegna_customer/data/network/graphql/bundle/__generated__/bundle_detail_query.req.gql.dart';
import 'package:melegna_customer/data/network/graphql_datasource.dart';
import 'package:melegna_customer/data/network/response.model.dart/bundle.reponse.dart';

abstract class IBundleRepository {
  Future<BundleResponse?> getBundleDetails(String bundleId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
}

@Injectable(as: IBundleRepository)
@Named(BundleRepository.injectName)
class BundleRepository implements IBundleRepository {
  static const injectName = 'BUNDLE_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;

  const BundleRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);
  @override
  Future<BundleResponse?> getBundleDetails(String bundleId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetBundleDetailReq(
      (b) => b
        ..vars.id = bundleId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetBundleDetailData>(request, type: GET_BUNDLE_DETAILS, isMainError: true);
    if (result == null) {
      return null;
    }
    return BundleResponse.fromJson(result.getBundleDetail.toJson());
  }

  // request type cosntants
  static const String GET_BUNDLE_DETAILS = 'GET_BUNDLE_DETAILS';
}
