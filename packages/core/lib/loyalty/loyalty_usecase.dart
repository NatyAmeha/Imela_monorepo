import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/loyalty/repo/loyalty_repository.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoyaltyUsecase {
  final ILoyaltyRepository _loyaltyRepository;

  const LoyaltyUsecase(@Named(LoyaltyRepository.injectName) this._loyaltyRepository);

  Future<LoyaltyResponse?> getCustomerLoyalties({ApiDataFetchPolicy apiDataFeed = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _loyaltyRepository.getCustomerLoyalties(apiDataFeed: apiDataFeed);
    if ((result?.success ?? false) && (apiDataFeed == ApiDataFetchPolicy.cacheFirst)) {
      result = await _loyaltyRepository.getCustomerLoyalties(apiDataFeed: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<LoyaltyResponse?> getBusinessLoyaltyTiers(String businessId, {ApiDataFetchPolicy apiDataFeed = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _loyaltyRepository.getBusinessLoyaltyTiers(businessId, fetchPolicy: apiDataFeed);
    if ((result?.success ?? false) && (apiDataFeed == ApiDataFetchPolicy.cacheFirst)) {
      result = await _loyaltyRepository.getBusinessLoyaltyTiers(businessId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<LoyaltyResponse?> getLoyaltyTier(String businessId, String tierId, {ApiDataFetchPolicy apiDataFeed = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _loyaltyRepository.getLoyaltyTier(businessId, tierId, fetchPolicy: apiDataFeed);
    if ((result?.success ?? false) && (apiDataFeed == ApiDataFetchPolicy.cacheFirst)) {
      result = await _loyaltyRepository.getLoyaltyTier(businessId, tierId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<LoyaltyResponse?> getCustomerTierByPoints(String businessId, double points, {ApiDataFetchPolicy apiDataFeed = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _loyaltyRepository.getEligableLoyaltyTierByPoint(businessId, points, fetchPolicy: apiDataFeed);
    if ((result?.success ?? false) && (apiDataFeed == ApiDataFetchPolicy.cacheFirst)) {
      result = await _loyaltyRepository.getEligableLoyaltyTierByPoint(businessId, points, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<LoyaltyResponse?> getCustomerBusinessLoyalty(String businessId, {ApiDataFetchPolicy apiDataFeed = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _loyaltyRepository.getCustomerBusinessLoyalty(businessId, fetchPolicy: apiDataFeed);
    if ((result?.success ?? false) && (apiDataFeed == ApiDataFetchPolicy.cacheFirst)) {
      result = await _loyaltyRepository.getCustomerBusinessLoyalty(businessId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }
}
