import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/shared/localized_field.model.dart';

part 'permission.freezed.dart';
part 'permission.g.dart';

enum PERMISSIONACTION { CREATE, READ, UPDATE, DELETE, ANY, MANAGE, ASSIGN_UNASSIGN }

@freezed
class Permission with _$Permission {
  const Permission._();
  const factory Permission({
    String? id,
    List<LocalizedField>? name,
    String? action,
    String? resourceType,
    String? resourceTarget,
    String? effect,
    List<PermissionGroup>? groups,
    bool? userGenerated,
    String? resourcTargetName,
  }) = _Permission;

  factory Permission.fromJson(Map<String, dynamic> json) => _$PermissionFromJson(json);
}

@freezed
class PermissionGroup with _$PermissionGroup {
  const PermissionGroup._();
  const factory PermissionGroup({
    String? id,
    String? key,
    List<LocalizedField>? name,
  }) = _PermissionGroup;

  factory PermissionGroup.fromJson(Map<String, dynamic> json) => _$PermissionGroupFromJson(json);
}
