import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
import 'package:imela_core/loyalty/repo/loyalty_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoyaltyUsecase {
  final ILoyaltyRepository _loyaltyRepository;

  const LoyaltyUsecase(@Named(LoyaltyRepository.injectName) this._loyaltyRepository);

  Future<LoyaltyResponse?> getCustomerLoyalties() async {
    final result = await _loyaltyRepository.getCustomerLoyalties();
    return result;
  }

  Future<LoyaltyResponse?> getCustomerBusinessLoyalty(String businessId) async {
    return await _loyaltyRepository.getCustomerBusinessLoyalty(businessId);
  }
}
