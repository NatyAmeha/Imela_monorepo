import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/business_response.dart';
import 'package:melegna_customer/domain/business/repo/business_repository.dart';

@injectable
class BusinessUsecase {
  final IBusinessrepository _businessRepository;

  const BusinessUsecase(@Named(BusinessRepository.injectName) this._businessRepository);

  Future<BusinessResponse?> getBusinessDetails(String businessId) async {
    var result = await _businessRepository.getBusinessDetails(businessId);
    return result;
  }
}
