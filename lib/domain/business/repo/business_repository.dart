import 'package:injectable/injectable.dart';
import 'package:imela/data/network/business_response.dart';
import 'package:imela/data/network/graphql/business/__generated__/business_queries.data.gql.dart';
import 'package:imela/data/network/graphql/business/__generated__/business_queries.req.gql.dart';
import 'package:imela/data/network/graphql_config.dart';
import 'package:imela/data/network/graphql_datasource.dart';
import 'package:imela/domain/shared/repository.intereface.dart';
import 'package:imela/injection.dart';

abstract class IBusinessrepository extends IRepository {
  Future<BusinessResponse?> getBusinessDetailsFromApi(String id, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
}

@Named(BusinessRepository.injectName)
@Injectable(as: IBusinessrepository)
class BusinessRepository implements IBusinessrepository {
  static const injectName = 'BUSINESS_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;

  const BusinessRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);
  @override
  Future<BusinessResponse?> getBusinessDetailsFromApi(String id, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly}) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    final request = GGetBusinessDetailsReq(
      (b) => b
        ..vars.id = id
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetBusinessDetailsData?>(request, type: "GET_BUSINESS_DETAILS", isMainError: true);
    if (result?.getBusinessDetails == null) {
      return null;
    }
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    return BusinessResponse.fromJson(result!.getBusinessDetails.toJson());
  }
}
