import 'package:imela_core/business/dto/create_business_input.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/business/model/business_response.dart';
import 'package:imela_core/business/repo/business_repository.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class BusinessUsecase {
  final IBusinessrepository _businessRepository;

  const BusinessUsecase(@Named(BusinessRepository.injectName) this._businessRepository);

  Future<BusinessResponse> registerBusiness(CreateBusinessInput businessInfo) async {
    return await _businessRepository.registerBusiness(businessInfo);
  }

  Future<BusinessResponse?> getBusinessDetails(String businessId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    BusinessResponse? result;
     result = await _businessRepository.getBusinessDetailsFromApi(businessId, fetchPolicy: fetchPolicy);
    if(fetchPolicy == ApiDataFetchPolicy.cacheFirst && result?.isBusinessDetailFetchSuccessfull() == false){
      result = await _businessRepository.getBusinessDetailsFromApi(businessId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<BusinessResponse?> getUserOwnedBusinesses({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly}) async {
    BusinessResponse? result;
    result = await _businessRepository.getUserOwnedBusinesses(fetchPolicy: fetchPolicy);
    if(fetchPolicy == ApiDataFetchPolicy.cacheFirst && result?.isBusinessListFetchSuccessfull() == false){
      result = await _businessRepository.getUserOwnedBusinesses(fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<BusinessResponse?> createBusinessProductSection(String businessId, List<BusinessSection> sections) async {
    return await _businessRepository.createBusinessSection(businessId, sections);
  }
}
