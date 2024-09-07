import 'package:freezed_annotation/freezed_annotation.dart';
import '../../bundle/model/product_bundle.model.dart';
part 'bundle_discovery.model.freezed.dart';
part 'bundle_discovery.model.g.dart';

@freezed
class BundleDiscovery with _$BundleDiscovery {
  const factory BundleDiscovery({
    required String title,
    String? subtitle,
    int? sequence,
    @Default([]) List<ProductBundle> items,
  }) = _BundleDiscovery;

  factory BundleDiscovery.fromJson(Map<String, dynamic> json) =>
      _$BundleDiscoveryFromJson(json);
}