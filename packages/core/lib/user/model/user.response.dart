import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.model.dart';

part 'user.response.freezed.dart';
part 'user.response.g.dart';

@freezed
class UserResponse with _$UserResponse {
  const UserResponse._();
  const factory UserResponse({
    User? user,
    String? accessToken,
    String? refreshToken,
    bool? isNewUser,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) => _$UserResponseFromJson(json);
}
