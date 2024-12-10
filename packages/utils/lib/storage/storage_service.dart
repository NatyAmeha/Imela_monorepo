import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:imela_utils/storage/storage_reponse.dart';
import 'package:injectable/injectable.dart';

abstract class IStorageService {
  Future<StorageResponse> uploadImages(String directoryName, List<String> imagePaths);
}

@Injectable(as: IStorageService)
@Named(StorageService.injectableName)
class StorageService implements IStorageService {
  static const injectableName = 'StorageService';
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  @override
  Future<StorageResponse> uploadImages(String directoryName, List<String> imagePaths) async {
    final downloadUrls = <String>[];
    try {
      for (var path in imagePaths) {
        final file = File(path);
        final fileName = path.split('/').last;
        print('uploading image $fileName');
        final ref = _firebaseStorage.ref().child('$directoryName/$fileName');
        await ref.putFile(file);
        final downloadUrl = await ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }
      return StorageResponse(success: true, downloadUrls: downloadUrls);
    } catch (e) {
      print('error uploading image $e');
      return StorageResponse(success: false, errorMessage: e.toString());
    }
  }
}
