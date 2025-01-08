import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:imela_ui_kit/components/image/photo_viewer/photo_viewer.viewmodel.dart';

class PhotoViewerScreen extends StatelessWidget {
  final PhotoViewerViewModel viewModel = Get.put(PhotoViewerViewModel());

  PhotoViewerScreen({super.key, required List<String> photoUrls, int startIndex = 0}) {
    viewModel.initializeGallery(photoUrls, startIndex);
  }

  PhotoViewerScreen.single({super.key, required String photoUrl}) {
    viewModel.initializeSinglePhoto(photoUrl);
  }

  static void navigate(BuildContext context, List<String> photoUrls, int startIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(photoUrls: photoUrls, startIndex: startIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(
        () => Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  
                  imageProvider: CachedNetworkImageProvider(viewModel.photos[index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              itemCount: viewModel.photos.length,
              pageController: PageController(initialPage: viewModel.initialIndex.value),
              onPageChanged: (index) {
                viewModel.initialIndex.value = index;
              },
            ),
            if (viewModel.photos.length > 1)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(viewModel.photos.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == viewModel.initialIndex.value ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == viewModel.initialIndex.value ? Colors.white : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
