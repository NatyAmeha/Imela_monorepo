import 'package:imela_core/shared/repository.intereface.dart';
import 'package:imela_core/staff/model/staff_response.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_data/network/graphql/staff/__generated__/authenticate_staff.data.gql.dart';
import 'package:imela_data/network/graphql/staff/__generated__/authenticate_staff.req.gql.dart';
import 'package:imela_data/shared_pref/preference_datastore.dart';
import 'package:injectable/injectable.dart';

abstract class IStaffRepository extends IRepository {
  Future<StaffResponse?> authenticateStaff({required String phoneNumber, required int pin, required String branchId, required String businessId});

}

@Named(StaffRepository.injectName)
@Injectable(as: IStaffRepository)
class StaffRepository implements IStaffRepository {
  static const injectName = 'STAFF_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;

  const StaffRepository(
    @Named(GraphqlDatasource.injectName) this._graphQLDataSource
  );

  @override
  Future<StaffResponse?> authenticateStaff({required String phoneNumber, required int pin, required String branchId, required String businessId}) async {
    final request = GAuthenticateStaffReq(
      (b) => b
        ..vars.phoneNumber = phoneNumber
        ..vars.pin = pin.toDouble()
        ..vars.branchId = branchId
        ..vars.businessId = businessId
        // ..fetchPolicy = ApiDataFetchPolicy.networkOnly
        
    );
    final result = await _graphQLDataSource.request<GAuthenticateStaffData?>(request, type: 'AUTHENTICATE_STAFF', isMainError: true);
    if (result?.authenticateStaff == null) {
      return null;
    }
    return StaffResponse.fromJson(result!.authenticateStaff.toJson());
  }
}
