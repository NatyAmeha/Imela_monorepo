import 'dart:async';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/business/business.usecase.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_core/staff/model/staff_response.dart';
import 'package:imela_core/staff/staff_usecase.dart';
import 'package:imela_pos/app/app_constants.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/home/branch_selection_page.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class StaffAuthViewmodel extends GetxController with BaseViewmodel {
  final StaffUsecase staffUsecase;
  final BusinessUsecase businessUsecase;
  final IExceptiionHandler exceptiionHandler;

  StaffAuthViewmodel({
    required this.staffUsecase,
    required this.businessUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  final phoneNumberController = TextEditingController().obs;
  final pinController = TextEditingController().obs;

  final isAdmin = false.obs;
  final selectedBranch = Rxn<Branch>();

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var showEmailInput = true.obs;

  var inputOptions = <String, String>{AppLanguage.ENGLISH.name: '', AppLanguage.AMHARIC.name: ''};
  var selectedInputOptionKey = AppLanguage.ENGLISH.name.obs;

  // getters
  AppViewmodel get appviewmodel => AppViewmodel.getInstance();

  var isInputValid = false.obs;

  static StaffAuthViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<StaffAuthViewmodel>());
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () {
      exception.value = null;
      handleLastLoginStaffPhone();
    });
  }

  void handleLastLoginStaffPhone() async {
    final phone = await staffUsecase.getLastLoginStaffPhone();
    if (phone != null) {
      phoneNumberController.value.text = phone.removePrefix('+251');
    }
  }

  void checkInputValidity() {
    if (isAdmin.value) {
      isInputValid.value = selectedBranch.value != null && phoneNumberController.value.text.isNotEmpty && phoneNumberController.value.text.length >= 13;
    } else {
      isInputValid.value = phoneNumberController.value.text.isNotEmpty && pinController.value.text.isNotEmpty && phoneNumberController.value.text.length >= 13 && pinController.value.text.length >= 4;
    }
  }

  Future<void> handleSignIn(BuildContext context) async {
    if (isAdmin.value) {
      signInBranchAdmin(context, selectedBranch.value);
    } else {
      signInStaff(context);
    }
  }

  Future<void> signInStaff(BuildContext context) async {
    try {
      isLoading.value = true;
      exception.value = null;
      final pin = int.parse(pinController.value.text);
      final result = await staffUsecase.authenticateStaff(phone: phoneNumberController.value.text, pin: pin, businessId: appviewmodel.selectedBusinessId, staffLoginTimeKey: AppConstants.LAST_LOGGED_IN_STAFF_TIME);
      if (!(result?.isAuthenticated ?? false)) {
        exception.value = AppException(message: result?.message ?? 'Unable to authenticate this staff', isMainError: false);
        return;
      }
      appviewmodel.setLoggedInStaff(result!);
      BranchSelectionPage.navigate(context, replace: true);
    } catch (e) {
      print('error $e');
      final exceptionResult = exceptiionHandler.getException(e as Exception);
      AppViewmodel.getWidgetFactory(context).showFlashMessage(context, message: exceptionResult.message ?? 'Error occured, please try again');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInBranchAdmin(BuildContext context, Branch? branch) async {
    try {
      isLoading.value = true;
      exception.value = null;
      if (selectedBranch.value != null) {
        final result = await staffUsecase.authenticateBranchAdmin(phone: phoneNumberController.value.text, businessId: appviewmodel.selectedBusinessId, branchId: selectedBranch.value!.id!, staffLoginTimeKey: AppConstants.LAST_LOGGED_IN_STAFF_TIME);
        if (!(result?.isAuthenticated ?? false)) {
          exception.value = AppException(message: result?.message ?? 'Unable to authenticate this staff', isMainError: false);
          return;
        }
        appviewmodel.setLoggedInStaff(result!);
        BranchSelectionPage.navigate(context, replace: true);
      }
    } catch (e) {
      print('error $e');
      final exceptionResult = exceptiionHandler.getException(e as Exception);
      AppViewmodel.getWidgetFactory(context).showFlashMessage(context, message: exceptionResult.message ?? 'Error occured, please try again');
    } finally {
      isLoading(false);
    }
  }

  double getFormWidth(BuildContext context) {
    if (Responsive.isSmallScreen(context)) {
      return MediaQuery.sizeOf(context).width;
    } else if (Responsive.isMediumScreen(context)) {
      return MediaQuery.sizeOf(context).width * 0.7;
    } else {
      return MediaQuery.sizeOf(context).width * 0.4;
    }
  }

  void setIsAdmin(bool? value) {
    if (value != null) {
      isAdmin.value = value;
      selectedBranch.value = null;
    }
    phoneNumberController.value.text = '';
    pinController.value.text = '';
    checkInputValidity();
  }

  void setSelectedBranch(List<Branch> value) {
    selectedBranch.value = value.firstOrNull;
    checkInputValidity();
  }
}
