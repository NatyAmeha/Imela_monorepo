import 'package:imela_core/bundle/model/bundle.response.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';
import 'repo/bundle.repository.dart';

@injectable
class BundleUsecase {
  final IBundleRepository _bundleRepo;

  const BundleUsecase(@Named(BundleRepository.injectName) this._bundleRepo);

  Future<BundleResponse?> getBundleDetails(String bundleId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    BundleResponse? bundleResponse;
    bundleResponse = await _bundleRepo.getBundleDetails(bundleId, fetchPolicy: fetchPolicy);
    if (!(bundleResponse?.isSuccessful ?? false) && fetchPolicy == ApiDataFetchPolicy.cacheFirst) {
      bundleResponse = await _bundleRepo.getBundleDetails(bundleId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }

    return bundleResponse;
  }
}
