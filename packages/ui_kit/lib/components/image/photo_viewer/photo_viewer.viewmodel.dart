import 'package:get/get.dart';

class PhotoViewerViewModel extends GetxController {
  final RxList<String> photos = <String>[].obs; // List of photo URLs
  final RxInt initialIndex = 0.obs; // Start index for the gallery

  // Initialize the photos and starting index
  void initializeGallery(List<String> photoUrls, int startIndex) {
    photos.value = photoUrls;
    initialIndex.value = startIndex.clamp(0, photoUrls.length - 1); // Ensure valid index
  }

  // Handle logic for a single image view
  void initializeSinglePhoto(String photoUrl) {
    photos.value = [photoUrl];
    initialIndex.value = 0;
  }
}
