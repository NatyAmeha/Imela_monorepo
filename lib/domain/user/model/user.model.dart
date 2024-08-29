import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela/domain/user/model/user_favorite_business.model.dart';

part 'user.model.freezed.dart';
part 'user.model.g.dart';

@freezed
class User with _$User {
  const User._();
  const factory User({
    String? id,
    String? email,
    String? phoneNumber,
    String? username,
    bool? isUsernamePlaceholder,
    String? password,
    String? firstName,
    String? lastName,
    String? profileImageUrl,
    String? refreshToken,
    String? accountStatus,
    bool? isEmailPlaceholder,
    bool? emailVerified,
    bool? phoneVerified,
    // List<Access>? accesses,
    List<String>? accessIds,
    String? accountType,
    List<UserFavoriteBusiness>? favoriteBusinesses,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
