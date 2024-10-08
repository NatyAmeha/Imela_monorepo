import 'package:imela_core/branch/model/branch.response.dart';
import 'package:imela_core/shared/repository.intereface.dart';
import 'package:imela_data/network/graphql/branch/__generated__/branch_details.data.gql.dart';
import 'package:imela_data/network/graphql/branch/__generated__/branch_details.req.gql.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

abstract class  IBranchRepository extends IRepository {
  Future<BranchResponse?> getBranchDetailsFromApi(String businessId , String branchId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork});
}

@Named(BranchRepository.injectName)
@Injectable(as: IBranchRepository)
class BranchRepository implements IBranchRepository{
  static const injectName = 'BRANCH_REPOSITORY_INJECTION';
  final IGraphQLDataSource _graphQLDataSource;

  const BranchRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);

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


}