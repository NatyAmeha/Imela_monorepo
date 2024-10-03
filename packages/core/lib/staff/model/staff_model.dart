import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/business/model/business.model.dart';

part 'staff_model.freezed.dart';
part 'staff_model.g.dart';

@freezed
class Staff with _$Staff {
  const Staff._();
  factory Staff({
    String? id,
    String? name,
    int? pin,
    String? phoneNumber,
    String? password,
    List<String>? roles,
    String? branchId,
    Branch? branch,
    String? businessId,
    Business? business,
  }) = _Staff;

  factory Staff.fromJson(Map<String, dynamic> json) => _$StaffFromJson(json);
}
