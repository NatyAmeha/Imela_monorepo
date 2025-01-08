import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_data/network/graphql/graphql_config.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_buusiness_loyalty_tiers.data.gql.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_buusiness_loyalty_tiers.req.gql.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_customer_business_loyalty.data.gql.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_customer_business_loyalty.req.gql.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_customer_loyalties.data.gql.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_customer_loyalties.req.gql.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_eligable_loyalty_tier_by_point.data.gql.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_eligable_loyalty_tier_by_point.req.gql.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_loyalty_tier.data.gql.dart';
import 'package:imela_data/network/graphql/loyalty/__generated__/get_loyalty_tier.req.gql.dart';
import 'package:injectable/injectable.dart';

abstract class ILoyaltyRepository {
  Future<LoyaltyResponse?> getCustomerLoyalties({ApiDataFetchPolicy apiDataFeed});
  Future<LoyaltyResponse?> getCustomerBusinessLoyalty(String businessId, {ApiDataFetchPolicy fetchPolicy});
  Future<LoyaltyResponse?> getEligableLoyaltyTierByPoint(String businessId, double points, {ApiDataFetchPolicy fetchPolicy});
  Future<LoyaltyResponse?> getBusinessLoyaltyTiers(String businessId, {ApiDataFetchPolicy fetchPolicy});
  Future<LoyaltyResponse?> getLoyaltyTier(String businessId, String tierId, {ApiDataFetchPolicy fetchPolicy});
}

@Injectable(as: ILoyaltyRepository)
@Named(LoyaltyRepository.injectName)
class LoyaltyRepository implements ILoyaltyRepository {
  static const injectName = 'LOYALTY_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;

  const LoyaltyRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);

  @override
  Future<LoyaltyResponse?> getCustomerLoyalties({ApiDataFetchPolicy apiDataFeed = ApiDataFetchPolicy.cacheFirst}) async {
    final req = GGetMyLoyaltiesReq((b) => b..fetchPolicy = _graphQLDataSource.getFetchPolicy(apiDataFeed));
    final result = await _graphQLDataSource.request<GGetMyLoyaltiesData>(req, type: "Get User loyalties", isMainError: true);
    if (result == null) {
      return null;
    }
    return LoyaltyResponse.fromJson(result.getCustomerLoyalties.toJson());
  }

  @override
  Future<LoyaltyResponse?> getCustomerBusinessLoyalty(String businessId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final req = GGetCustomerBusinessLoyaltyReq(
      (b) => b
        ..vars.businessId = businessId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetCustomerBusinessLoyaltyData>(req, type: 'Get loyalty details', isMainError: true);
    if (result == null) {
      return null;
    }
    return LoyaltyResponse.fromJson(result.getCustomerBusinessLoyality.toJson());
  }

  @override
  Future<LoyaltyResponse?> getEligableLoyaltyTierByPoint(String businessId, double points, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);

    final req = GGetEligableLoyaltyTierByPOintReq((b) => b
      ..vars.businessId = businessId
      ..vars.points = points
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    final result = await _graphQLDataSource.request<GGetEligableLoyaltyTierByPOintData>(req, type: 'Get eligable loyalty tier by point', isMainError: true);
    if (result == null) {
      return null;
    }
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    return LoyaltyResponse.fromJson(result.getCustomerEligibleTiers.toJson());
  }

  @override
  Future<LoyaltyResponse?> getBusinessLoyaltyTiers(String businessId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);

    final req = GGetBusinessLoyaltyTiersReq((b) => b
      ..vars.businessId = businessId
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    final result = await _graphQLDataSource.request<GGetBusinessLoyaltyTiersData>(req, type: 'Get business loyalty tiers', isMainError: true);
    if (result == null) {
      return null;
    }
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    return LoyaltyResponse.fromJson(result.getBusinessLoyaltyTiers.toJson());
  }

  @override
  Future<LoyaltyResponse?> getLoyaltyTier(String businessId, String tierId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final req = GGetLoyaltyTierReq((b) => b
      ..vars.businessId = businessId
      ..vars.tierId = tierId
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    final result = await _graphQLDataSource.request<GGetLoyaltyTierData>(req, type: 'Get loyalty tier', isMainError: true);
    if (result == null) {
      return null;
    }
    return LoyaltyResponse.fromJson(result.getBusinessLoyaltyTier.toJson());
  }
}
