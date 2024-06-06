import 'package:melegna_customer/data/network/business_response.dart';
import 'package:melegna_customer/domain/business/repo/business_repository.dart';

class BusinessUsecase{
  final IBusinessrepository _businessRepository;

  const BusinessUsecase(this._businessRepository);

  Future<BusinessResponse> getBusinessDetails(String businessId) async {
    var result = await _businessRepository.getBusinessDetails(businessId);
    print("business result ${result.toJson()}");
    return result;
  }
}