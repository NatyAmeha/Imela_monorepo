import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/staff/model/staff_model.dart';
import 'package:imela_core/user/model/auth_response.dart';

part 'staff_response.freezed.dart';
part 'staff_response.g.dart';

@freezed
class StaffResponse with _$StaffResponse {
  const StaffResponse._();
  const factory StaffResponse({
    bool? success,
    String? message,
    Staff? staff,
    List<Staff>? staffs,
    String? accessToken,
    AuthResponse? authResponse,
  }) = _StaffResponse;

  factory StaffResponse.fromJson(Map<String, dynamic> json) => _$StaffResponseFromJson(json);

  StaffResponse setAuthInfo(AuthResponse authInfo) {
    return copyWith(authResponse: authResponse);
  }
}

extension StaffResponseX on StaffResponse? {
  bool get isAuthenticated {
    if (this == null) return false;
    if (this!.success == true && this!.staff != null) return true;
    return false;
  }

  bool get isStaffListFetchSuccess {
    if (this == null) return false;
    if (this!.success == true && this!.staffs != null) return true;
    return false;
  }
}
