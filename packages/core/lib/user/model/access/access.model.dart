import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/user/model/access/permission.dart';

part 'access.model.freezed.dart';
part 'access.model.g.dart';

enum DefaultRoles { ADMIN, MANAGER, STAFF, BUSINESS_OWNER }

@freezed
class Access with _$Access {
  const Access._();
  const factory Access({
    String? id,
    List<LocalizedField>? name,
    String? resourceId,
    String? role,
    List<Permission>? permissions,
    String? owner,
    String? ownerType,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? permissionType,
  }) = _Access;

  factory Access.fromJson(Map<String, dynamic> json) => _$AccessFromJson(json);
}

extension AccessX on List<Access> {
  
  bool hasRole(List<DefaultRoles> roles) {
    final rolesString = roles.map((e) => e.name).toList();
    return any((e) => rolesString.contains(e.role));
  }

  bool hasPermission({String? resourceType, String? action, String? resourceTarget}) {
    final permissions = map((e) => e.permissions).whereType<Permission>().toList();
    return permissions.any((e) {
      final resourceTypeCheck = e.resourceType == resourceType;
      final actionCheck = e.action == action;
      if (e.resourceTarget != null) {
        final resourceTargetCheck = e.resourceTarget == resourceTarget;
        return resourceTargetCheck && resourceTypeCheck && actionCheck;
      }
      return resourceTypeCheck && actionCheck;
    });
  }

  bool canAccessStaff() {
    return hasRole([DefaultRoles.BUSINESS_OWNER, DefaultRoles.MANAGER]);
  }
}
