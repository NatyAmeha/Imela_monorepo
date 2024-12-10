import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/membership/dto/membership_response.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_data/network/graphql/graphql_config.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql/membership/__generated__/approve_membership_request.data.gql.dart';
import 'package:imela_data/network/graphql/membership/__generated__/approve_membership_request.req.gql.dart';
import 'package:imela_data/network/graphql/membership/__generated__/get_business_membership_plan.data.gql.dart';
import 'package:imela_data/network/graphql/membership/__generated__/get_business_membership_plan.req.gql.dart';
import 'package:imela_data/network/graphql/membership/__generated__/get_business_membership_plan_for_pos.data.gql.dart';
import 'package:imela_data/network/graphql/membership/__generated__/get_business_membership_plan_for_pos.req.gql.dart';
import 'package:imela_data/network/graphql/membership/__generated__/get_membership_details.data.gql.dart';
import 'package:imela_data/network/graphql/membership/__generated__/get_membership_details.req.gql.dart';
import 'package:imela_data/network/graphql/membership/__generated__/get_user_membership.data.gql.dart';
import 'package:imela_data/network/graphql/membership/__generated__/get_user_membership.req.gql.dart';
import 'package:imela_data/network/graphql/membership/__generated__/request_to_join_membership.data.gql.dart';
import 'package:imela_data/network/graphql/membership/__generated__/request_to_join_membership.req.gql.dart';
import 'package:injectable/injectable.dart';

abstract class IMembershipRepository {
  Future<MembershipResponse?> getMembershipDetails(String membershipId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<MembershipResponse?> getBusinessMembershipPlans(String businessId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<MembershipResponse?> getBusinessMembershipPlansForPos(String businessId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<MembershipResponse?> requestToJoinMembership(String membershipId, SelectedPaymentMethod selectedPaymentMethod);
  Future<MembershipResponse?> approveMembershipRequest(String businessId, String membershipId, String? branchId, List<String> groupMembersId, {SelectedPaymentMethod? selectedPaymentMethod});
  Future<MembershipResponse?> getUserMemberships({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
}

@Injectable(as: IMembershipRepository)
@Named(MembershipRepository.injectName)
class MembershipRepository extends IMembershipRepository {
  static const injectName = 'MEMBERSHIP_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;

  MembershipRepository(
    @Named(GraphqlDatasource.injectName) this._graphQLDataSource,
  );
  @override
  Future<MembershipResponse?> getMembershipDetails(String membershipId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    final request = GGetMembershipDetailsReq(
      (b) => b
        ..vars.membershipId = membershipId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetMembershipDetailsData>(request, type: "getMembershipDetails", isMainError: true);
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    if (result == null) {
      return null;
    }

    return MembershipResponse.fromJson(result.getMembershipDetails.toJson());
  }

  @override
  Future<MembershipResponse?> getBusinessMembershipPlans(String businessId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, true);
    final request = GGetBusinessMembershipPlansReq(
      (b) => b
        ..vars.businessId = businessId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetBusinessMembershipPlansData>(request, type: "getBusinessMembershipPlans", isMainError: true);
    updateDIValue<bool>(ClientInterceptor.BYPASS_TOKEN_VALIDATION, false);
    if (result == null) {
      return null;
    }

    return MembershipResponse.fromJson(result.getBusinessMembershipPlans.toJson());
  }

  @override
  Future<MembershipResponse?> getBusinessMembershipPlansForPos(String businessId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetBusinessMembershipPlansForPosReq(
      (b) => b
        ..vars.businessId = businessId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetBusinessMembershipPlansForPosData>(request, type: "getBusinessMembershipPlansForPos", isMainError: true);
    if (result == null) {
      return null;
    }
    print('result: ${result.getBusinessMembershipPlans.toJson()}');
    return MembershipResponse.fromJson(result.getBusinessMembershipPlans.toJson());
  }

  @override
  Future<MembershipResponse?> requestToJoinMembership(String membershipId, SelectedPaymentMethod selectedPaymentMethod) async {
    print('selected payment method ${selectedPaymentMethod.toJson()}');
    final request = GRequestToJoinMembershipReq(
      (b) => b
        ..vars.membershipId = membershipId
        ..vars.paymentMethod.update(
              (b) => b
                ..name.addAll(selectedPaymentMethod.name.toLocalizedFieldInput())
                ..receiptImages.addAll(selectedPaymentMethod.receiptImages ?? [])
                ..amount.update((bb) => bb
                  ..amount = selectedPaymentMethod.amount.amount
                  ..currency = selectedPaymentMethod.amount.currency.toCurrencyKeyInput),
            ),
    );
    final result = await _graphQLDataSource.request<GRequestToJoinMembershipData>(request, type: "requestToJoinMembership", isMainError: true);
    if (result == null) {
      return null;
    }

    return MembershipResponse.fromJson(result.joinMemership.toJson());
  }

  @override
  Future<MembershipResponse?> approveMembershipRequest(String businessId, String membershipId, String? branchId, List<String> groupMembersId, {SelectedPaymentMethod? selectedPaymentMethod}) async {
    final request = GApproveMembershipRequestReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.membershipId = membershipId
        ..vars.branchId = branchId
        ..vars.groupMembersId.addAll(groupMembersId)
        ..vars.paymentMethod.update(
              (b) => b
                ..name.addAll(selectedPaymentMethod?.name.toLocalizedFieldInput() ?? [])
                ..receiptImages.addAll(selectedPaymentMethod?.receiptImages ?? [])
                ..amount.update((bb) => bb
                  ..amount = selectedPaymentMethod?.amount.amount
                  ..currency = selectedPaymentMethod?.amount.currency.toCurrencyKeyInput),
            ),
    );

    final result = await _graphQLDataSource.request<GApproveMembershipRequestData>(request, type: "approveMembershipRequest", isMainError: true);
    if (result == null) {
      return null;
    }

    return MembershipResponse.fromJson(result.approveMembershipRequest.toJson());
  }

  @override
  Future<MembershipResponse?> getUserMemberships({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetUserMembershipReq((b) => b..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    final result = await _graphQLDataSource.request<GGetUserMembershipData>(request, type: "getUserMemberships", isMainError: true);
    if (result == null) {
      return null;
    }

    return MembershipResponse.fromJson(result.getUserMemberships.toJson());
  }
}
