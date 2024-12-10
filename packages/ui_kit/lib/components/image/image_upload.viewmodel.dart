import 'package:get/get.dart';
import 'package:imela_ui_kit/components/list/list_componenet.viewmodel.dart';
import 'package:imela_ui_kit/helpers/file_upload.model.dart';
import 'package:imela_ui_kit/services/app_image_picker.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';

class ImageUploadViewmodel extends GetxController {
  final imageListController = CustomListController<FileUpload>();

  static ImageUploadViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered<ImageUploadViewmodel>(ImageUploadViewmodel());
  }

  void setUploadedImages(List<FileUpload> images) {
    imageListController.setItems(images);
  }

  Future<FileUpload?> PickImage() async {
    try {
      final imagePickerService = AppImagePicker();
      var image = await imagePickerService.getImage(AppImageSource.GALLERY);
      if (image != null) {
        final uploadedFile = FileUpload(file: image);
        imageListController.addItems([uploadedFile]);
        return uploadedFile;
      }
    } catch (e) {
      print('image error: $e');
    }
  }

  void updateIsFeaturedStatus(int index, bool isFeatured) {
    var item = imageListController.items[index];
    var newItem = FileUpload(file: item.file, isFeatured: isFeatured);
    imageListController.updateItem(index, newItem);
  }

  void removeImages(List<int> index) {
    imageListController.removeItems(index);
  }
}
