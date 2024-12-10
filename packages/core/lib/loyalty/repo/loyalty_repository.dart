import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_data/network/graphql/graphql_config.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_customer_business_loyalty.data.gql.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_customer_business_loyalty.req.gql.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_customer_loyalties.data.gql.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_customer_loyalties.req.gql.dart';
import 'package:injectable/injectable.dart';

abstract class ILoyaltyRepository {
  Future<LoyaltyResponse?> getCustomerLoyalties();
  Future<LoyaltyResponse?> getCustomerBusinessLoyalty(String businessId);
}

@Injectable(as: ILoyaltyRepository)
@Named(LoyaltyRepository.injectName)
class LoyaltyRepository implements ILoyaltyRepository {
  static const injectName = 'LOYALTY_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;

  const LoyaltyRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);

  @override
  Future<LoyaltyResponse?> getCustomerLoyalties() async {
    final req = GGetMyLoyaltiesReq();
    final result = await _graphQLDataSource.request<GGetMyLoyaltiesData>(req, type: "Get User loyalties", isMainError: true);
    if (result == null) {
      return null;
    }
    return LoyaltyResponse.fromJson(result.getCustomerLoyalties.toJson());
  }

  @override
  Future<LoyaltyResponse?> getCustomerBusinessLoyalty(String businessId) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    final req = GGetCustomerBusinessLoyaltyReq(
      (b) => b..vars.businessId = businessId,
    );
    final result = await _graphQLDataSource.request<GGetCustomerBusinessLoyaltyData>(req, type: 'Get loyalty details', isMainError: true);
    if (result == null) {
      return null;
    } 
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    return LoyaltyResponse.fromJson(result.getCustomerBusinessLoyality.toJson());
  }
}
