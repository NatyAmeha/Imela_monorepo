import 'package:freezed_annotation/freezed_annotation.dart';
import '../../shared/localized_field.model.dart';

part 'user_favorite_business.model.freezed.dart';
part 'user_favorite_business.model.g.dart';

@freezed
class UserFavoriteBusiness with _$UserFavoriteBusiness {
  const UserFavoriteBusiness._();
  const factory UserFavoriteBusiness({
    String? id,
    String? businessId,
    List<LocalizedField>? businessName,
    String? image,
  }) = _UserFavoriteBusiness;

  factory UserFavoriteBusiness.fromJson(Map<String, dynamic> json) => _$UserFavoriteBusinessFromJson(json);
}
