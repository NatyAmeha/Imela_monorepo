import 'package:injectable/injectable.dart';
import 'package:imela/data/network/graphql_datasource.dart';
import 'package:imela/data/network/response.model.dart/branch.response.dart';
import 'package:imela/domain/branch/repo/branch.repository.dart';

@injectable
class BranchUsecase {
  final IBranchRepository _businessRepository;

  const BranchUsecase(@Named(BranchRepository.injectName) this._businessRepository);

  Future<BranchResponse?> getBusinessDetails(String businessId, String branchId) async {
    var result = await _businessRepository.getBranchDetailsFromApi(businessId, branchId, fetchPolicy: ApiDataFetchPolicy.cacheAndNetwork);
    return result;
  }
}
