import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/graphql_datasource.dart';
import 'package:melegna_customer/data/network/response.model.dart/branch.response.dart';
import 'package:melegna_customer/domain/branch/repo/branch.repository.dart';

@injectable
class BranchUsecase {
  final IBranchRepository _businessRepository;

  const BranchUsecase(@Named(BranchRepository.injectName) this._businessRepository);

  Future<BranchResponse?> getBusinessDetails(String businessId, String branchId) async {
    var result = await _businessRepository.getBranchDetailsFromApi(businessId, branchId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    return result;
  }
}
