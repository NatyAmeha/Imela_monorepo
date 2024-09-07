import 'package:imela_core/bundle/model/bundle.response.dart';
import 'package:imela_core/shared/repository.intereface.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_data/network/graphql/bundle/__generated__/bundle_detail_query.data.gql.dart';
import 'package:imela_data/network/graphql/bundle/__generated__/bundle_detail_query.req.gql.dart';
import 'package:imela_data/network/graphql/graphql_config.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

abstract class IBundleRepository extends IRepository {
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
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    final request = GGetBundleDetailReq(
      (b) => b
        ..vars.id = bundleId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetBundleDetailData>(request, type: GET_BUNDLE_DETAILS, isMainError: true);
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    if (result == null) {
      return null;
    }
    return BundleResponse.fromJson(result.getBundleDetail.toJson());
  }

  // request type cosntants
  static const String GET_BUNDLE_DETAILS = 'GET_BUNDLE_DETAILS';
}
