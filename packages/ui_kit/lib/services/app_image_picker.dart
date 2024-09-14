import 'dart:io';

import 'package:image_picker/image_picker.dart';

enum AppImageSource { GALLERY, CAMERA }

abstract class IImagePicker {
  Future<File?> getImage(AppImageSource source);
  Future<List<File>?> getImages(AppImageSource source);

  Future<File?> getVideo(AppImageSource source);
  Future<List<File>?> getVideos(AppImageSource source);
}

class AppImagePicker implements IImagePicker {
  @override
  Future<File?> getImage(AppImageSource source) async {
    try {
      final imagePicker = ImagePicker();
      final imageSource = source == AppImageSource.GALLERY ? ImageSource.gallery : ImageSource.camera;
      final result = await imagePicker.pickImage(source: imageSource);
      if (result == null) {
        return null;
      }
      return File(result.path);
    } catch (ex) {
      print('Error getting image: $ex');
    }
  }

  @override
  Future<List<File>?> getImages(AppImageSource source) async {
    try {
      final imagePicker = ImagePicker();
      final result = await imagePicker.pickMultiImage();
      return result.map((e) => File(e.path)).toList();
    } catch (ex) {
      print('Error getting images: $ex');
    }
  }

  @override
  Future<File?> getVideo(AppImageSource source) async {
    try {
      final imagePicker = ImagePicker();
      final imageSource = source == AppImageSource.GALLERY ? ImageSource.gallery : ImageSource.camera;
      final result = await imagePicker.pickVideo(source: imageSource);
      if (result == null) {
        return null;
      }
      return File(result.path);
    } catch (ex) {
      print('Error getting video: $ex');
    }
  }

  @override
  Future<List<File>?> getVideos(AppImageSource source) async {
    try {
      final imagePicker = ImagePicker();
      final result = await imagePicker.pickMultipleMedia();
      return result.map((e) => File(e.path)).toList();
    } catch (ex) {
      print('Error getting videos: $ex');
    }
  }
}
