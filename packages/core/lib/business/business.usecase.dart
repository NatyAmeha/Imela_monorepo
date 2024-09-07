import 'package:imela_core/business/model/business_response.dart';
import 'package:imela_core/business/repo/business_repository.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class BusinessUsecase {
  final IBusinessrepository _businessRepository;

  const BusinessUsecase(@Named(BusinessRepository.injectName) this._businessRepository);

  Future<BusinessResponse?> getBusinessDetails(String businessId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    BusinessResponse? result;
     result = await _businessRepository.getBusinessDetailsFromApi(businessId, fetchPolicy: fetchPolicy);
    if(fetchPolicy == ApiDataFetchPolicy.cacheFirst && result?.isBusinessDetailFetchSuccessfull() == false){
      result = await _businessRepository.getBusinessDetailsFromApi(businessId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }
}
