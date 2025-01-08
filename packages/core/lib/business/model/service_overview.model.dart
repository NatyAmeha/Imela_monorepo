import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';

part 'service_overview.model.freezed.dart';
part 'service_overview.model.g.dart';

@freezed
class ServiceOverview with _$ServiceOverview {
  const ServiceOverview._();
  const factory ServiceOverview({
    required String id,
    required List<LocalizedField> title,
    required List<LocalizedField> description,
    List<LocalizedField>? callToAction,
    String? callToActionUrl,
    Gallery? gallery,
    @Default(true) bool isActive,
    @Default(false) bool featured,
  }) = _ServiceOverview;

  factory ServiceOverview.fromJson(Map<String, dynamic> json) => _$ServiceOverviewFromJson(json);
}
