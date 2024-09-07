import 'package:freezed_annotation/freezed_annotation.dart';
import '../../business/model/business.model.dart';
part 'business_discovery.model.freezed.dart';
part 'business_discovery.model.g.dart';

@freezed
class BusinessDiscovery with _$BusinessDiscovery {
  const factory BusinessDiscovery({
    required String title,
    String? subtitle,
    int? sequence,
    @Default([]) List<Business> items,
  }) = _BusinessDiscovery;

  factory BusinessDiscovery.fromJson(Map<String, dynamic> json) =>
      _$BusinessDiscoveryFromJson(json);
}