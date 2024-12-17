import 'package:imela_core/branch/repo/branch.repository.dart';
import 'package:imela_core/business/dto/create_business_input.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/business/model/business_response.dart';
import 'package:imela_core/business/repo/business_repository.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class BusinessUsecase {
  final IBusinessrepository _businessRepository;
  final IBranchRepository _branchRepository;

  const BusinessUsecase(
    @Named(BusinessRepository.injectName) this._businessRepository,
    @Named(BranchRepository.injectName) this._branchRepository,
  );


  Future<BusinessResponse> registerBusiness(CreateBusinessInput businessInfo) async {
    return await _businessRepository.registerBusiness(businessInfo);
  }

  Future<BusinessResponse?> getBusinessDetails(String businessId, {String? branchId, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    BusinessResponse? result;
    result = await _businessRepository.getBusinessDetailsFromApi(businessId, branchId: branchId, fetchPolicy: fetchPolicy);
    if ((fetchPolicy == ApiDataFetchPolicy.cacheFirst) && result?.isBusinessDetailFetchSuccessfull() == false) {
      result = await _businessRepository.getBusinessDetailsFromApi(businessId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result; 
  }

  Future<BusinessResponse?> getBusinessesFromOrder(List<String> businessIds, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    BusinessResponse? result;
    result = await _businessRepository.getBusinessesFromOrder(businessIds, fetchPolicy: fetchPolicy);
    if (fetchPolicy == ApiDataFetchPolicy.cacheFirst && result?.isBusinessListFetchSuccessfull() == false) {
      result = await _businessRepository.getBusinessesFromOrder(businessIds, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<BusinessResponse?> getBusinessSectionDetails(String businessId, String sectionId, {String? branchId, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _businessRepository.getBusinessSectionDetailsFromApi(businessId, sectionId, branchId: branchId, fetchPolicy: fetchPolicy);
    if (fetchPolicy == ApiDataFetchPolicy.cacheFirst && result?.success == false) {
      result = await _businessRepository.getBusinessSectionDetailsFromApi(businessId, sectionId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<BusinessResponse?> getBusinessByWorkspaceUrl(String workspaceUrl, {String? branchId, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final result = await _businessRepository.getBusinessByWorkspace(workspaceUrl, branchId: branchId, fetchPolicy: fetchPolicy);
    print('business ${result?.business?.orderStatuses}');
    if (result?.business == null) {
      throw Exception("Business not found");
    }

    // final posBusiness = result!.business?.toPOSBusinessEntity();
    // final saveToDBResult = await _businessRepository.saveBusinessToDB(workspaceUrl, posBusiness!);
    final workspaceSaveResult = await _branchRepository.saveWorkspaceUrl(workspaceUrl);
    // if (!saveToDBResult) {
    //   throw Exception("Failed to save business to DB");
    // }
    return result;
  }

  Future<String?> getWorkspaceUrlFromPreference() async {
    return await _branchRepository.getWorkspaceUrl();
  }

  Future<BusinessResponse?> getUserOwnedBusinesses({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly}) async {
    BusinessResponse? result;
    result = await _businessRepository.getUserOwnedBusinesses(fetchPolicy: fetchPolicy);
    if (fetchPolicy == ApiDataFetchPolicy.cacheFirst && result?.isBusinessListFetchSuccessfull() == false) {
      result = await _businessRepository.getUserOwnedBusinesses(fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<BusinessResponse?> addBusinessToFavorites(String businessId, List<LocalizedField> businessName) async {
    var result = await _businessRepository.addBusinessToFavorite(businessId, businessName);
    return result;
  }

  Future<BusinessResponse?> createBusinessProductSection(String businessId, List<BusinessSection> sections) async {
    return await _businessRepository.createBusinessSection(businessId, sections);
  }

  
}
