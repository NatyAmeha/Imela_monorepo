import 'package:imela_core/business/dto/create_business_input.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/business/model/business_response.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_core/shared/repository.intereface.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/business_queries.data.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/business_queries.req.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/create_business_section.data.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/create_business_section.req.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/get_user_business.data.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/get_user_business.req.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/register_business.data.gql.dart';
import 'package:imela_data/network/graphql/business/__generated__/register_business.req.gql.dart';
import 'package:imela_data/network/graphql/graphql_config.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql_exception.dart';
import 'package:injectable/injectable.dart';

abstract class IBusinessrepository extends IRepository {
  Future<BusinessResponse> registerBusiness(CreateBusinessInput businessInfo);
  Future<BusinessResponse?> getBusinessDetailsFromApi(String id, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
  Future<BusinessResponse?> getUserOwnedBusinesses({required ApiDataFetchPolicy fetchPolicy});
  Future<BusinessResponse?> createBusinessSection(String businessId, List<BusinessSection> sections);
}

@Named(BusinessRepository.injectName)
@Injectable(as: IBusinessrepository)
class BusinessRepository implements IBusinessrepository {
  static const injectName = 'BUSINESS_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;

  const BusinessRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);

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
  Future<BusinessResponse?> getBusinessDetailsFromApi(String id, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly}) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    final request = GGetBusinessDetailsReq(
      (b) => b
        ..vars.id = id
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetBusinessDetailsData?>(request, type: "GET_BUSINESS_DETAILS", isMainError: true);
    if (result?.getBusinessDetails == null) {
      return null;
    }
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    return BusinessResponse.fromJson(result!.getBusinessDetails.toJson());
  }

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
