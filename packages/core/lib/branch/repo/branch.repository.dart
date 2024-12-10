import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/branch/model/branch.response.dart';
import 'package:imela_core/shared/const/preference_constant.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_core/shared/repository.intereface.dart';
import 'package:imela_data/network/graphql/branch/__generated__/branch_details.data.gql.dart';
import 'package:imela_data/network/graphql/branch/__generated__/branch_details.req.gql.dart';
import 'package:imela_data/network/graphql/branch/__generated__/create_branch.data.gql.dart';
import 'package:imela_data/network/graphql/branch/__generated__/create_branch.req.gql.dart';
import 'package:imela_data/network/graphql/branch/__generated__/get_pos_branch.data.gql.dart';
import 'package:imela_data/network/graphql/branch/__generated__/get_pos_branch.req.gql.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/shared_pref/preference_datastore.dart';
import 'package:injectable/injectable.dart';

abstract class IBranchRepository extends IRepository {
  Future<BranchResponse?> getBranchDetailsFromApi(String businessId, String branchId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
  Future<BranchResponse?> createBranch(String businessId, Branch branchInfo, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
  Future<BranchResponse?> getPosBranch(String businessId, String branchId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});

  // POS related
  Future<bool> saveWorkspaceUrl(String workspaceUrl);
  Future<String?> getWorkspaceUrl();
  Future<bool> saveLastLoginStaffPhone(String phoneNumber);
  Future<String?> getLastLoginStaffPhone();
}

@Named(BranchRepository.injectName)
@Injectable(as: IBranchRepository)
class BranchRepository implements IBranchRepository {
  static const injectName = 'BRANCH_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;
  final ISharedPreferenceDataStore _sharedPreferenceDataStore;

  const BranchRepository(
    @Named(GraphqlDatasource.injectName) this._graphQLDataSource,
    @Named(SharedPreferenceDataStore.injectName) this._sharedPreferenceDataStore,
  );

  @override
  Future<BranchResponse?> getBranchDetailsFromApi(String businessId, String branchId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.networkOnly}) async {
    final request = GGetBranchDetailsReq(
      (b) => b
        ..vars.bsId = businessId
        ..vars.brId = branchId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetBranchDetailsData?>(request, type: 'GET_BRANCH_DETAILS', isMainError: true);
    if (result?.getBranchDetails == null) {
      return null;
    }
    return BranchResponse.fromJson(result!.getBranchDetails.toJson());
  }

  @override
  Future<BranchResponse?> createBranch(String businessId, Branch branchInfo, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork}) async {
    final request = GGCreateBranchReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.branchInfo.update((b) => b
          ..name.addAll(branchInfo.name!.toLocalizedFieldInput())
          ..phoneNumber = branchInfo.phoneNumber
          ..address.update((b) => b
            ..address = branchInfo.address?.address
            ..city = branchInfo.address?.city
            ..location = branchInfo.address?.location))
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGCreateBranchData?>(request, type: 'CREATE_BRANCH', isMainError: true);
    if (result?.createBranch == null) {
      return null;
    }
    return BranchResponse.fromJson(result!.createBranch.toJson());
  }

  @override
  Future<BranchResponse?> getPosBranch(String businessId, String branchId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetPosBranchReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.branchId = branchId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final result = await _graphQLDataSource.request<GGetPosBranchData?>(request, type: 'GET_POS_BRANCH', isMainError: true);
    if (result?.getPosBranch == null) {
      return null;
    }
    return BranchResponse.fromJson(result!.getPosBranch.toJson());
  }

  @override
  Future<bool> saveWorkspaceUrl( String workspaceUrl) async {
    return await _sharedPreferenceDataStore.create(PreferenceConstant.WORKSPACE_URL, workspaceUrl);
  }

  @override
  Future<String?> getWorkspaceUrl() async {
    return await _sharedPreferenceDataStore.get<String>(PreferenceConstant.WORKSPACE_URL);
  }

  @override
  Future<bool> saveLastLoginStaffPhone(String phoneNumber) async {
    return await _sharedPreferenceDataStore.create(PreferenceConstant.LAST_LOGIN_STAFF_PHONE, phoneNumber);
  }

  @override
  Future<String?> getLastLoginStaffPhone() async {
    return await _sharedPreferenceDataStore.get<String>(PreferenceConstant.LAST_LOGIN_STAFF_PHONE);
  }
}
