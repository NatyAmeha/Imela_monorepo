import 'package:imela_core/discovery/model/discovery_response.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_data/network/graphql/discover/__generated__/discover_query.data.gql.dart';
import 'package:imela_data/network/graphql/discover/__generated__/discover_query.req.gql.dart';
import 'package:imela_data/network/graphql/graphql_config.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

abstract class IDiscoveryRepository {
  Future<DiscoveryResponse?> browse({required ApiDataFetchPolicy fetchPolicy});
}

@Injectable(as: IDiscoveryRepository)
@Named(DiscoveryRepository.injectName)
class DiscoveryRepository implements IDiscoveryRepository {
  static const injectName = 'DISCOVERY_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;

  const DiscoveryRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);

  @override
  Future<DiscoveryResponse?> browse({required ApiDataFetchPolicy fetchPolicy}) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    final request = GGetDiscoveryDataReq((b) => b..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    final result = await _graphQLDataSource.request<GGetDiscoveryDataData>(request, type: 'BROWSE', isMainError: true);
    if (result == null) {
      return null;
    }
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    return DiscoveryResponse.fromJson(result.getDiscoveryData.toJson());
  }
}
