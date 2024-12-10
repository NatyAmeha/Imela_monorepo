import 'package:imela_utils/storage/storage_service.dart';
import 'package:injectable/injectable.dart';

@injectable
class StorageUseCase {
  final IStorageService _firebaseStorageService;
  final cachedImageUrls = <String, List<String>>{};

  StorageUseCase(@Named(StorageService.injectableName) this._firebaseStorageService);

  Future<Map<String, List<String>?>> uploadOrderPaymentProof(String uploadDirectory, Map<String, List<String>?>? paymentProofImages) async {
    if (paymentProofImages == null) {
      return Future.value({});
    }
    final response = Map<String, List<String>?>.from({});
    await Future.forEach(
      paymentProofImages.entries,
      (element) async {
        if (element.value != null) {
          if (cachedImageUrls.containsKey(element.key)) {
            response[element.key] = cachedImageUrls[element.key];
          } else {
            final result = await _firebaseStorageService.uploadImages(uploadDirectory, element.value!);
            response[element.key] = result.downloadUrls;
            cachedImageUrls[element.key] = result.downloadUrls ?? [];
          }
        }
      },
    );
    return response;
  }

  void removeCachedImageUrls() {
    cachedImageUrls.clear();
  }
}
