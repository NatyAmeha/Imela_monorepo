import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/staff/model/staff_model.dart';
import 'package:imela_core/staff/staff_usecase.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateStaffViewModel extends GetxController with BaseViewmodel {
  final StaffUsecase staffUsecase;

  CreateStaffViewModel({required this.staffUsecase});

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();

  List<Branch> get branches => appViewmodel.businessBranches;
  String get selectedLanguage => appViewmodel.selectedLanguage;

  static CreateStaffViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<CreateStaffViewModel>());
  }

  // Reactive state variables
  var staffName = TextEditingController();
  var phoneNumber = TextEditingController();
  var pin = TextEditingController();
  var selectedBranch = Rxn<Branch>();

  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  void setSelectedBranch(Branch? branch) {
    selectedBranch.value = branch;
  }

  // getters
  bool get canEnableCreateButton => staffName.text.isNotEmpty && phoneNumber.text.isNotEmpty && pin.text.isNotEmpty && selectedBranch.value != null;
  

  Map<String, Widget> getBranchOpotions() {
    return {for (var branch in branches) branch.id!: Text(branch.name.localize(appViewmodel.selectedLanguage))};
  }

  Future<void> createStaff(BuildContext context, {Function(Staff?)? onSuccess}) async {
    if (staffName.text.isNotEmpty && phoneNumber.text.isNotEmpty && pin.text.isNotEmpty && selectedBranch.value != null) {
      try {
        isLoading.value = true;
        // Logic to create staff using staffUsecase
        final response = await staffUsecase.createStaff(
          staff: Staff(
            name: staffName.value.text,
            phoneNumber: phoneNumber.value.text,
            pin: int.parse(pin.value.text),
            branchId: selectedBranch.value!.id!,
            businessId: appViewmodel.selectedBusinessId,
          ),
        );
        if (!(response?.success ?? false)) {
          exception.value = AppException(message: response?.message ?? 'Failed to create staff');
        }

        onSuccess?.call(response?.staff);
        // Handle success (e.g., navigate back or show success message)
      } catch (e) {
        print(e);
        exception.value = AppException(message: 'Failed to create staff');
        // Handle error
      } finally {
        isLoading.value = false;
      }
    } else {
      exception.value = AppException(message: 'Please fill all fields');
    }
  }

  void setPhoneNumber(String value) {
    phoneNumber.value = TextEditingValue(text: value);
  }

  void setPin(String value) {
    pin.value = TextEditingValue(text: value);
  }

  void setStaffName(String value) {
    staffName.value = TextEditingValue(text: value);
  }
}
