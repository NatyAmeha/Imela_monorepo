import 'package:melegna_customer/data/network/business_response.dart';
import 'package:melegna_customer/data/network/graphql_datasource.dart';
import 'package:melegna_customer/domain/shared/repository.intereface.dart';
import 'package:melegna_customer/graphql/queries/__generated__/business.req.gql.dart';

abstract class IBusinessrepository extends IRepository {
  Future<BusinessResponse> getBusinessDetails(String id);
}

class BusinessRepository implements IBusinessrepository {
  final IGraphQLDataSource _graphQLDataSource;

  const BusinessRepository(this._graphQLDataSource);
  @override
  Future<BusinessResponse> getBusinessDetails(String id) async {
    final request = GGetBusinessDetailsReq((b) => b..vars.id = id);
    final result = await _graphQLDataSource.query(request);
    final businessResponse = BusinessResponse.fromJson(result.toJson());
    return businessResponse;
  }
}
