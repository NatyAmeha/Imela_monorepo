import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/subscription/model/platform_service.model.dart';

part 'platform_service.response.freezed.dart';
part 'platform_service.response.g.dart';

@freezed
class PlatformServiceResponse with _$PlatformServiceResponse {
  const PlatformServiceResponse._();
  const factory PlatformServiceResponse({
    bool? success,
    String? message,
    PlatformService? service,
    List<PlatformService>? platformServices,
  }) = _PlatformServiceResponse;

  factory PlatformServiceResponse.fromJson(Map<String, dynamic> json) => _$PlatformServiceResponseFromJson(json);

}