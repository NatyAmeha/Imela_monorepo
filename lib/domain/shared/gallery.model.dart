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