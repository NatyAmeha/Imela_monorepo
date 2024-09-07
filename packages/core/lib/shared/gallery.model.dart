import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'gallery.model.freezed.dart';
part 'gallery.model.g.dart';

@freezed
class Gallery with  _$Gallery{
    const factory Gallery({
        String? id,
        String? logoImage,
        String? coverImage,
        List<GalleryData>?images,
        List<GalleryData>?videos,
    }) = _Gallery;

    factory Gallery.fromJson(Map<String, dynamic> json) => _$GalleryFromJson(json);

}

@freezed
class GalleryData with _$GalleryData { 
    const factory GalleryData({
        String? url,
        bool? featured,
    }) = _GalleryData;

    factory GalleryData.fromJson(Map<String, dynamic> json) => _$GalleryDataFromJson(json);
    
} 

extension GalleryDataExtension on Gallery {
    List<String> getImages({bool? featured = false}) {
    // sort images by featured first
    // gallery?.images?.sort((a, b) => a.featured == b.featured
    //     ? 0
    //     : (a.featured ?? false)
    //         ? -1
    //         : 1);
    if(images?.isEmpty == null) return [];
    if (featured == true) {
      return images!.where((element) => element.featured == true).map((e) => e.url!).toList();
    }
    return images!.map((e) => e.url!).toList();
  }

  String? getImage({bool? featured = false}) {
    if (images?.isEmpty == null) return '';
    if (featured == true) {
      return images!.firstWhereOrNull((element) => element.featured == true)?.url;
    }
    return images?.firstOrNull?.url;
  }
}