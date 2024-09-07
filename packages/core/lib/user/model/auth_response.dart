import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.model.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

abstract class IAuthResponse {}

@freezed
class AuthResponse with _$AuthResponse implements IAuthResponse {
  const AuthResponse._();

  const factory AuthResponse({
    required bool success,
    String? message,
    User? user,
    String? accessToken,
    String? refreshToken,
    bool? isNewUser,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);

  bool get isSuccessfull {
    if(success && accessToken != null && refreshToken != null){
      return true;
    }
    return false;
  }
}

class FirebaseAuthResponse implements IAuthResponse {
  final bool authenticated;
  final String? smscode;
  final String? errorMsg;
  final String? verificationId;

  FirebaseAuthResponse({required this.authenticated, this.smscode, this.errorMsg, this.verificationId});
}
