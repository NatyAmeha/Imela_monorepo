import 'package:imela_core/branch/repo/branch.repository.dart';
import 'package:imela_core/staff/model/staff_model.dart';
import 'package:imela_core/staff/model/staff_response.dart';
import 'package:imela_core/staff/repo/staff.repository.dart';
import 'package:imela_core/user/repo/auth.repository.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class StaffUsecase {
  final IStaffRepository _staffRepo;
  final IBranchRepository _branchRepo;
  final IAuthRepository _authRepo;

  const StaffUsecase(
    @Named(StaffRepository.injectName) this._staffRepo,
    @Named(BranchRepository.injectName) this._branchRepo,
    @Named(AuthRepository.injectName) this._authRepo,
  );

  Future<StaffResponse?> createStaff({required Staff staff}) async {
    final response = await _staffRepo.createStaff(staff: staff);
    return response;
  }

  Future<StaffResponse?> authenticateStaff({required String phone, required int pin, required String businessId, required String staffLoginTimeKey}) async {
    final staffResponse = await _staffRepo.authenticateStaff(phoneNumber: phone, pin: pin, businessId: businessId);
    if (staffResponse?.isAuthenticated ?? false) {
      await _branchRepo.saveLastLoginStaffPhone(phone);
      final authResponse = await _authRepo.generateTokenForStaff(phone);
      if (!authResponse.isSuccessfull) {
        return null;
      }
      await _authRepo.saveAuthCredentialToPreference(authResponse);
      await _staffRepo.saveLastLoggedInStaffTime(staffLoginTimeKey, DateTime.now().toIso8601String());
      final updatedStaffResponse = staffResponse!.setAuthInfo(authResponse);
      return updatedStaffResponse;
    }
  }

  Future<StaffResponse?> authenticateBranchAdmin({required String phone, required String businessId, required String branchId, required String staffLoginTimeKey}) async {
    final authResponse = await _authRepo.generateTokenForStaff(phone);
    if (!authResponse.isSuccessfull) {
      return null;
    }
    await _authRepo.saveAuthCredentialToPreference(authResponse);
    final accessResponse = await _staffRepo.checkManagerAccess(phoneNumber: phone, businessId: businessId, branchId: branchId);
    if (!(accessResponse?.isAuthenticated ?? false)) {
      return null;
    }
    await _branchRepo.saveLastLoginStaffPhone(phone);
    await _staffRepo.saveLastLoggedInStaffTime(staffLoginTimeKey, DateTime.now().toIso8601String());
    if (!(accessResponse?.success ?? false)) {
      return null;
    }
    if (accessResponse!.success! && (accessResponse.staff!.name == null || accessResponse.staff!.phoneNumber == null)) {
      final result = StaffResponse(success: true, staff: Staff(phoneNumber: phone, name: "Admin", branchId: branchId, businessId: businessId), authResponse: authResponse);
      return result;
    } else {
      final updatedAccessResponse = accessResponse.setAuthInfo(authResponse);
      return updatedAccessResponse;
    }
  }

  Future<StaffResponse?> getBranchStaff({required String branchId, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    return await _staffRepo.getBranchStaff(branchId: branchId, fetchPolicy: fetchPolicy);
  }

  Future<String?> getLastLoginStaffPhone() async {
    return await _branchRepo.getLastLoginStaffPhone();
  }

  Future<bool> isLastLoggedInStaffTimeExpired(String key) async {
    final lastLoggedInStaffTime = await _staffRepo.getLastLoggedInStaffTime(key);
    if (lastLoggedInStaffTime == null) {
      return true;
    }
    final currentTime = DateTime.now();
    final difference = currentTime.difference(lastLoggedInStaffTime);
    return difference.inHours > 1;
  }
}
