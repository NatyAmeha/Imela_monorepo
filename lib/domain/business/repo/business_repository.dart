
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/business_response.dart';
import 'package:melegna_customer/data/network/graphql/business/__generated__/business_queries.data.gql.dart';
import 'package:melegna_customer/data/network/graphql/business/__generated__/business_queries.req.gql.dart';
import 'package:melegna_customer/data/network/graphql_datasource.dart';
import 'package:melegna_customer/domain/shared/repository.intereface.dart';


abstract class IBusinessrepository extends IRepository {
  Future<BusinessResponse?> getBusinessDetailsFromApi(String id, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
}

@Named(BusinessRepository.injectName)
@Injectable(as: IBusinessrepository)
class BusinessRepository implements IBusinessrepository {
  static const injectName = 'BUSINESS_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;

  const BusinessRepository(@Named( GraphqlDatasource.injectName) this._graphQLDataSource);
  @override
  Future<BusinessResponse?> getBusinessDetailsFromApi(String id, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork}) async {
    final request = GGetBusinessDetailsReq(
      (b) => b
        ..vars.id = id
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.query<GGetBusinessDetailsData?>(request, type: "GET_BUSINESS_DETAILS", isMainError: true);
    if (result?.getBusinessDetails == null) {
      return null;
    }
    return BusinessResponse.fromJson(result!.getBusinessDetails.toJson());
  }
}
