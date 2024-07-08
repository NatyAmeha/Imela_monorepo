import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/bundle/model/product_bundle.model.dart';
part 'bundle.reponse.freezed.dart';
part 'bundle.reponse.g.dart';

@freezed
class BundleResponse with _$BundleResponse {
  const factory BundleResponse({
    bool? success,
    String? message,
    ProductBundle? bundle,
    
  }) = _BundleResponse;

  factory BundleResponse.fromJson(Map<String, dynamic> json) => _$BundleResponseFromJson(json);
}