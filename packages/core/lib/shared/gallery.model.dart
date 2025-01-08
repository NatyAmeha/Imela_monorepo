import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';
part 'gallery.model.freezed.dart';
part 'gallery.model.g.dart';

@freezed
class Gallery with _$Gallery {
  const Gallery._();
  const factory Gallery({
    String? id,
    String? logoImage,
    String? coverImage,
    List<GalleryData>? images,
    List<GalleryData>? videos,
  }) = _Gallery;

  factory Gallery.fromJson(Map<String, dynamic> json) => _$GalleryFromJson(json);

  List<String> getImages({bool? featured = false}) {
    if (images?.isEmpty == null) return [];
    if (featured == true) {
      return images!.where((element) => element.featured == true).map((e) => e.url).whereNotNull().toList();
    }
    return images!.map((e) => e.url).whereNotNull().toList();
  }

  Function toGraphQLInput() {
    return (b) => b
      ..logoImage = logoImage
      ..coverImage = coverImage
      ..images.addAll(images?.map((e) => e.toGraphQLInput()) ?? [])
      ..videos.addAll(videos?.map((e) => e.toGraphQLInput()) ?? []);
  }

  static Gallery fakeGalleryData() {
    return const Gallery(
      id: '1',
      logoImage: 'https://via.placeholder.com/150',
      coverImage: 'https://via.placeholder.com/150',
      images: [
        GalleryData(url: 'https://via.placeholder.com/150', featured: true),
        GalleryData(url: 'https://via.placeholder.com/150', featured: false),
        GalleryData(url: 'https://via.placeholder.com/150', featured: false),
        GalleryData(url: 'https://via.placeholder.com/150', featured: false),
      ],
      videos: [
        GalleryData(url: 'https://via.placeholder.com/150', featured: true),
        GalleryData(url: 'https://via.placeholder.com/150', featured: false),
        GalleryData(url: 'https://via.placeholder.com/150', featured: false),
        GalleryData(url: 'https://via.placeholder.com/150', featured: false),
      ],
    );
  }
}

@freezed
class GalleryData with _$GalleryData {
  const GalleryData._();
  const factory GalleryData({
    String? url,
    bool? featured,
  }) = _GalleryData;

  factory GalleryData.fromJson(Map<String, dynamic> json) => _$GalleryDataFromJson(json);

  GGalleryDataInput toGraphQLInput() {
    return GGalleryDataInput((b) => b
      ..url = url
      ..featured = featured);
  }
}

extension GalleryDataExtension on Gallery {
  List<String> getImages({bool? featured = false}) {
    // sort images by featured first
    // gallery?.images?.sort((a, b) => a.featured == b.featured
    //     ? 0
    //     : (a.featured ?? false)
    //         ? -1
    //         : 1);
    if (images?.isEmpty == null) return [];
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
