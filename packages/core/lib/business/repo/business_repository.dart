import 'package:imela_core/business/dto/create_business_input.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/business/model/business_response.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/repository.intereface.dart';
import 'package:imela_data/database/db_datasource.dart';
import 'package:imela_data/database/entity/pos_business.entity.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/add_business_to_favorite.data.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/add_business_to_favorite.req.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/business_queries.data.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/business_queries.req.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/create_business_section.data.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/create_business_section.req.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/get_business_by_workspace.data.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/get_business_by_workspace.req.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/get_business_section_details.data.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/get_business_section_details.req.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/get_user_business.data.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/get_user_business.req.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/order_business_list.data.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/order_business_list.req.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/register_business.data.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/register_business.req.gql.dart';
import 'package:imela_data/network/graphql/graphql_config.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql_exception.dart';
import 'package:injectable/injectable.dart';

abstract class IBusinessrepository extends IRepository {
  Future<BusinessResponse> registerBusiness(CreateBusinessInput businessInfo);
  Future<BusinessResponse?> getBusinessDetailsFromApi(String id, {String? branchId, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<BusinessResponse?> addBusinessToFavorite(String businessId, List<LocalizedField> businessName);
  Future<BusinessResponse?> getBusinessesFromOrder(List<String> businessIds, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<BusinessResponse?> getBusinessSectionDetailsFromApi(String businessId, String sectionId, {String? branchId, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<BusinessResponse?> getBusinessByWorkspace(String workspaceUrl, {String? branchId, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  // Future<bool> saveBusinessToDB(String workspaceUrl, POSBusinessEntity business);
  Future<BusinessResponse?> getUserOwnedBusinesses({required ApiDataFetchPolicy fetchPolicy});
  Future<BusinessResponse?> createBusinessSection(String businessId, List<BusinessSection> sections);
}

@Named(BusinessRepository.injectName)
@Injectable(as: IBusinessrepository)
class BusinessRepository implements IBusinessrepository {
  static const injectName = 'BUSINESS_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;
  final IDBDataSource _dbDataSource;

  const BusinessRepository(
    @Named(GraphqlDatasource.injectName) this._graphQLDataSource,
    @Named(POSDBDataSource.injectName) this._dbDataSource,
  );

  @override
  Future<BusinessResponse> registerBusiness(CreateBusinessInput businessInfo) async {
    final request = GCreateBusinessReq(
      (b) => b
        ..vars.businessInput.update(
              (b) => b
                ..name.addAll(businessInfo.name.toLocalizedFieldInput())
                ..description.addAll(businessInfo.description.toLocalizedFieldInput())
                ..categories.addAll(businessInfo.categories)
                ..phoneNumber = businessInfo.phoneNumber
                ..creator = businessInfo.creator
                ..email = businessInfo.email
                ..gallery.update((b) => businessInfo.gallery?.toGraphQLInput())
                ..mainAddress.update(
                  (b) => b
                    ..address = businessInfo.mainAddress.address
                    ..city = businessInfo.mainAddress.city
                    ..location = businessInfo.mainAddress.location,
                ),
            )
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly),
    );
    // ..paymentOptions.addAll(paymentOptions?.map((e) => e.toGraphQLInput()));)

    final result = await _graphQLDataSource.request<GCreateBusinessData>(request, type: 'CREATE_BUSINESS', isMainError: true);
    if (result?.createBusiness == null) {
      throw GraphqlException(message: 'Unable to create Business');
    }
    return BusinessResponse.fromJson(result!.createBusiness.toJson());
  }

  @override
  Future<BusinessResponse?> getUserOwnedBusinesses({required ApiDataFetchPolicy fetchPolicy}) async {
    final request = GGetUserBusinessReq(
      (b) => b..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetUserBusinessData?>(request, type: 'GET_USER_BUSINESS', isMainError: true);
    if (result?.getUserBusinesses == null) {
      return null;
    }
    return BusinessResponse.fromJson(result!.getUserBusinesses.toJson());
  }

  @override
  Future<BusinessResponse?> getBusinessDetailsFromApi(String id, {String? branchId, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    final request = GGetBusinessDetailsReq(
      (b) => b
        ..vars.id = id
        ..vars.branchId = branchId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetBusinessDetailsData?>(request, type: "GET_BUSINESS_DETAILS", isMainError: true);
    if (result?.getBusinessDetails == null) {
      return null;
    }
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    return BusinessResponse.fromJson(result!.getBusinessDetails.toJson());
  }

  @override
  Future<BusinessResponse?> addBusinessToFavorite(String businessId, List<LocalizedField> businessName) async {
    final request = GAddBusinessToFavoriteReq((b) => b
      ..vars.input.addAll(
            businessName.map(
              (e) => GFavoriteBusienssInput(
                (b) => b
                  ..businessId = businessId
                  ..businessName.addAll(businessName.toLocalizedFieldInput()),
              ),
            ),
          )
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(ApiDataFetchPolicy.networkOnly));
    final result = await _graphQLDataSource.request<GAddBusinessToFavoriteData?>(request, type: 'ADD_BUSINESS_TO_FAVORITE', isMainError: true);
    if (result?.addBusinessToFavorites == null) {
      return null;
    }
    return BusinessResponse.fromJson(result!.addBusinessToFavorites.toJson());
  }

  @override
  Future<BusinessResponse?> getBusinessesFromOrder(List<String> businessIds, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GOrderBusinessListReq(
      (b) => b
        ..vars.businessIds.addAll(businessIds)
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GOrderBusinessListData?>(request, type: 'ORDER_BUSINESS_LIST', isMainError: true);
    if (result?.getBusinessesFromOrder == null) {
      return null;
    }
    return BusinessResponse.fromJson(result!.getBusinessesFromOrder.toJson());
  }

  @override
  Future<BusinessResponse?> getBusinessSectionDetailsFromApi(String businessId, String sectionId, {String? branchId, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);

    final request = GGetBusinessSectionDetailsReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.sectionId = sectionId
        ..vars.branchId = branchId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetBusinessSectionDetailsData?>(request, type: 'GET_BUSINESS_SECTION_DETAILS', isMainError: true);
    if (result?.getBusinesSectionsDetails == null) {
      return null;
    }
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    return BusinessResponse.fromJson(result!.getBusinesSectionsDetails.toJson());
  }

  @override
  Future<BusinessResponse?> getBusinessByWorkspace(String workspaceUrl, {String? branchId, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    final request = GGetBusinessByWorkspaceReq(
      (b) => b
        ..vars.workspace = workspaceUrl
        // ..vars.branchId = branchId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetBusinessByWorkspaceData?>(request, type: 'GET_BUSINESS_BY_WORKSPACE', isMainError: true);
    if (result?.getBusinessByWorkspaceUrl == null) {
      return null;
    }
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    return BusinessResponse.fromJson(result!.getBusinessByWorkspaceUrl.toJson());
  }

  // @override
  // Future<bool> saveBusinessToDB(String workspaceUrl, POSBusinessEntity business) async {
  //   try {
  //     final dbInstance = await _dbDataSource.getDBInstance(workspaceUrl);
  //     final result = await dbInstance.writeTxn(() async {
  //       final id = await dbInstance.pOSBusinessEntitys.put(business);
  //       return id > 0;
  //     });
  //     return result;
  //   } catch (e) {
  //     print('db save error $e');
  //     return false;
  //   }
  // }

  @override
  Future<BusinessResponse?> createBusinessSection(String businessId, List<BusinessSection> sections) async {
    final request = GCreateBusinessSectionReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.sections.addAll(
              sections.map(
                (e) => GCreateBusinessSectionInput(
                  (b) => b
                    ..name.addAll(e.name!.toLocalizedFieldInput())
                    ..description.addAll(e.description!.toLocalizedFieldInput())
                    ..images.addAll(e.images ?? []),
                ),
              ),
            ),
    );
    final result = await _graphQLDataSource.request<GCreateBusinessSectionData?>(request, type: "CREATE_BUSINESS_SECTION", isMainError: true);
    if (result?.createBusinessSection == null) {
      return null;
    }
    return BusinessResponse.fromJson(result!.createBusinessSection.toJson());
  }
}
