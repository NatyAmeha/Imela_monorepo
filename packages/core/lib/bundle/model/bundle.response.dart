import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';

part 'bundle.response.freezed.dart';
part 'bundle.response.g.dart';

@freezed
class BundleResponse with _$BundleResponse {
  const BundleResponse._();
  const factory BundleResponse({
    bool? success,
    String? message,
    ProductBundle? bundle,
  }) = _BundleResponse;

  factory BundleResponse.fromJson(Map<String, dynamic> json) => _$BundleResponseFromJson(json);

  bool get isSuccessful {
    if (success == true && bundle != null) {
      return true;
    }
    return false;
  }
}
