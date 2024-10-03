import 'package:imela_core/staff/model/staff_response.dart';
import 'package:imela_core/staff/repo/staff.repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class StaffUsecase {
  final IStaffRepository _staffRepo;

  const StaffUsecase(@Named(StaffRepository.injectName) this._staffRepo);

  Future<StaffResponse?> authenticateStaff(String phone, int pin) async {
    final businessId  = "662505ca50948fabb12180ba";
    final branchId = "662cc374060fb50140d73deb";
    final result = await _staffRepo.authenticateStaff(phoneNumber: phone, pin: pin, branchId: branchId, businessId: businessId);
    return result;
  }
}
