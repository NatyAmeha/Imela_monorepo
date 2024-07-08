import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/response.model.dart/bundle.reponse.dart';
import 'package:melegna_customer/domain/bundle/repo/bundle.repository.dart';

@injectable
class BundleUsecase{
  final IBundleRepository _bundleRepo;

  const BundleUsecase(@Named(BundleRepository.injectName) this._bundleRepo);

  Future<BundleResponse?> getBundleDetails(String bundleId) async {
    var result = await _bundleRepo.getBundleDetails(bundleId);
    return result;
  }

  
}