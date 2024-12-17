import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/loyalty/repo/loyalty_repository.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoyaltyUsecase {
  final ILoyaltyRepository _loyaltyRepository;

  const LoyaltyUsecase(@Named(LoyaltyRepository.injectName) this._loyaltyRepository);

  Future<LoyaltyResponse?> getCustomerLoyalties({ApiDataFetchPolicy apiDataFeed = ApiDataFetchPolicy.cacheFirst}) async {
    final result = await _loyaltyRepository.getCustomerLoyalties(apiDataFeed: apiDataFeed);
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
