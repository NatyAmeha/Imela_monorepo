import 'package:imela_core/discovery/model/discovery_response.dart';
import 'package:imela_core/discovery/repo/discovery.repository.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class DiscoveryUsecase {
  final IDiscoveryRepository _discoveryRepo;

  const DiscoveryUsecase(@Named(DiscoveryRepository.injectName) this._discoveryRepo);

  Future<DiscoveryResponse?> getDiscoveryDetails({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheAndNetwork}) async {
    var result = await _discoveryRepo.browse(fetchPolicy: fetchPolicy);
    if(result == null){
      throw Exception('Failed to fetch data');
  }
    return result;
  }
}
