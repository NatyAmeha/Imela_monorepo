import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/graphql/discover/__generated__/discover_query.data.gql.dart';
import 'package:melegna_customer/data/network/graphql/discover/__generated__/discover_query.req.gql.dart';
import 'package:melegna_customer/data/network/graphql_datasource.dart';
import 'package:melegna_customer/domain/discovery/model/discovery_response.dart';

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
    final request = GGetDiscoveryDataReq(
      (b) => b..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.query<GGetDiscoveryDataData>(request, type: "BROWSE", isMainError: true);
    if (result == null) {
      return null;
    }
    return DiscoveryResponse.fromJson(result.getDiscoveryData.toJson());
  }
}
