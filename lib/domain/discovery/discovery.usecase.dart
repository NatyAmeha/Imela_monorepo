import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/graphql_datasource.dart';
import 'package:melegna_customer/domain/discovery/model/discovery_response.dart';
import 'package:melegna_customer/domain/discovery/repo/discovery.repository.dart';

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
