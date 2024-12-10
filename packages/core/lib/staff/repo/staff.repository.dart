import 'package:imela_core/shared/repository.intereface.dart';
import 'package:imela_core/staff/model/staff_model.dart';
import 'package:imela_core/staff/model/staff_response.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql/staff/__generated__/authenticate_staff.data.gql.dart';
import 'package:imela_data/network/graphql/staff/__generated__/authenticate_staff.req.gql.dart';
import 'package:imela_data/network/graphql/staff/__generated__/check_manager_access.data.gql.dart';
import 'package:imela_data/network/graphql/staff/__generated__/check_manager_access.req.gql.dart';
import 'package:imela_data/network/graphql/staff/__generated__/create_staff.data.gql.dart';
import 'package:imela_data/network/graphql/staff/__generated__/create_staff.req.gql.dart';
import 'package:imela_data/network/graphql/staff/__generated__/get_branch_staff.data.gql.dart';
import 'package:imela_data/network/graphql/staff/__generated__/get_branch_staff.req.gql.dart';
import 'package:imela_data/shared_pref/preference_datastore.dart';
import 'package:injectable/injectable.dart';

abstract class IStaffRepository extends IRepository {
  Future<StaffResponse?> createStaff({required Staff staff});
  Future<StaffResponse?> getBranchStaff({required String branchId, required ApiDataFetchPolicy fetchPolicy});
  Future<StaffResponse?> checkManagerAccess({required String businessId, required String branchId, required String phoneNumber});
  Future<StaffResponse?> authenticateStaff({required String phoneNumber, int? pin, required String businessId});
  Future<bool> saveLastLoggedInStaffTime(String key, String value);
  Future<DateTime?> getLastLoggedInStaffTime(String key);
}

@Named(StaffRepository.injectName)
@Injectable(as: IStaffRepository)
class StaffRepository implements IStaffRepository {
  static const injectName = 'STAFF_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;
  final ISharedPreferenceDataStore _sharedPreferenceDataStore;

  const StaffRepository(
    @Named(GraphqlDatasource.injectName) this._graphQLDataSource,
    @Named(SharedPreferenceDataStore.injectName) this._sharedPreferenceDataStore,
  );

  @override
  Future<StaffResponse?> authenticateStaff({required String phoneNumber, int? pin, required String businessId}) async {
    final request = GAuthenticateStaffReq((b) => b
          ..vars.phoneNumber = phoneNumber
          ..vars.pin = pin?.toDouble()
          ..vars.businessId = businessId
        // ..fetchPolicy = ApiDataFetchPolicy.networkOnly

        );
    final result = await _graphQLDataSource.request<GAuthenticateStaffData?>(request, type: 'AUTHENTICATE_STAFF', isMainError: true);
    if (result?.authenticateStaff == null) {
      return null;
    }
    return StaffResponse.fromJson(result!.authenticateStaff.toJson());
  }

  @override
  Future<StaffResponse?> createStaff({required Staff staff}) async {
    final request = GcreateStaffReq((b) => b
      ..vars.input.update(
            (b) => b
              ..name = staff.name
              ..phoneNumber = staff.phoneNumber
              ..pin = staff.pin?.toDouble()
              ..branchId = staff.branchId
              ..businessId = staff.businessId,
          ));

    final result = await _graphQLDataSource.request<GcreateStaffData?>(request, type: 'CREATE_STAFF', isMainError: true);
    if (result?.createStaff == null) {
      return null;
    }
    return StaffResponse.fromJson(result!.createStaff.toJson());
  }

  @override
  Future<StaffResponse?> getBranchStaff({required String branchId, required ApiDataFetchPolicy fetchPolicy}) async {
    final request = GgetBranchStaffReq((b) => b
      ..vars.branchId = branchId
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));

    final result = await _graphQLDataSource.request<GgetBranchStaffData?>(request, type: 'GET_BRANCH_STAFF', isMainError: true);
    if (result?.getBranchStaffs == null) {
      return null;
    }
    return StaffResponse.fromJson(result!.getBranchStaffs.toJson());
  }

  @override
  Future<StaffResponse?> checkManagerAccess({required String businessId, required String branchId, required String phoneNumber}) async {
    final request = GcheckManagerAccessReq((b) => b
      ..vars.businessId = businessId
      ..vars.branchId = branchId
      ..vars.phoneNumber = phoneNumber);

    final result = await _graphQLDataSource.request<GcheckManagerAccessData?>(request, type: 'CHECK_MANAGER_ACCESS', isMainError: true);
    if (result?.checkManagerAccessToBranch == null) {
      return null;
    }
    return StaffResponse.fromJson(result!.checkManagerAccessToBranch.toJson());
  }

  @override
  Future<bool> saveLastLoggedInStaffTime(String key, String value) async {
    return await _sharedPreferenceDataStore.create(key, value);
  }

  @override
  Future<DateTime?> getLastLoggedInStaffTime(String key) async {
    final stringResult = await _sharedPreferenceDataStore.get(key);
    if (stringResult == null) {
      return null;
    }
    return DateTime.parse(stringResult);
  }
}
