import 'package:imela_core/branch/model/branch.response.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';
import 'repo/branch.repository.dart';

@injectable
class BranchUsecase {
  final IBranchRepository _businessRepository;

  const BranchUsecase(@Named(BranchRepository.injectName) this._businessRepository);

  Future<BranchResponse?> getBusinessDetails(String businessId, String branchId) async {
    var result = await _businessRepository.getBranchDetailsFromApi(businessId, branchId, fetchPolicy: ApiDataFetchPolicy.cacheAndNetwork);
    return result;
  }

  Future<BranchResponse?> getPosBranchDetails(String businessId, String branchId) async {
    var result = await _businessRepository.getPosBranch(businessId, branchId, fetchPolicy: ApiDataFetchPolicy.cacheFirst);
    if((result?.success ?? false) == false){
      result = await _businessRepository.getPosBranch(businessId, branchId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }
}
