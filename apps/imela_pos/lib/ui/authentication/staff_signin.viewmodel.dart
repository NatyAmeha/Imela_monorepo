import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/business/business.usecase.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_core/staff/model/staff_response.dart';
import 'package:imela_core/staff/staff_usecase.dart';
import 'package:imela_core/user/auth.usecase.dart';
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

  final phoneNumberController = TextEditingController();
  final pinController = TextEditingController();

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var showEmailInput = true.obs;

  var inputOptions = <String, String>{AppLanguage.ENGLISH.name: '', AppLanguage.AMHARIC.name: ''};
  var selectedInputOptionKey = AppLanguage.ENGLISH.name.obs;

  // getters
  AppViewmodel get appviewmodel => AppViewmodel.getInstance();

  static StaffAuthViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<StaffAuthViewmodel>());
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    exception.value = null;
  }

  Future<void> signInStaff(BuildContext context) async {
    try {
      isLoading.value = true;
      exception.value = null;
      final pin = int.parse(pinController.text);
      final result = await staffUsecase.authenticateStaff(phoneNumberController.text, pin);
      if (!result.isAuthenticated) {
        exception.value = AppException(message: result!.message ?? 'Unable to authenticate this staff', isMainError: false);
        return;
      }
      appviewmodel.setLoggedInStaff(result!.staff!);
      BranchSelectionPage.navigate(context);
    } catch (e) {
      print('error $e');
      final exceptionResult = exceptiionHandler.getException(e as Exception);
      AppViewmodel.getWidgetFactory(context).showFlashMessage(context, message: exceptionResult.message ?? 'Error occured, please try again');
    } finally {
      isLoading.value = false;
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
}
