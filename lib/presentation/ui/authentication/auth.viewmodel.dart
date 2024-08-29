import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:imela/domain/user/auth.usecase.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/authentication/phone_login_page.dart';
import 'package:imela/presentation/ui/authentication/phone_verify_page.dart';
import 'package:imela/presentation/ui/shared/base_viewmodel.dart';
import 'package:imela/presentation/utils/exception/app_exception.dart';

@injectable
class AuthViewmodel extends GetxController with BaseViewmodel {
  final IExceptiionHandler exceptiionHandler;
  AuthUsecase authUsecae;

  AuthViewmodel({
    required this.authUsecae,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  AppController get appController => AppController.getInstance;

  final phoneController = TextEditingController();
  final verifyPinController = TextEditingController();

  // page state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
  }

  void navigateToPhoneLoginPage(BuildContext context) {
    PhoneLoginPage.navigate(context, appController.router);
  }

  void navigateToPhoneVerifyPage(BuildContext context) {
    PhoneVerifyPage.navigate(context, appController.router);
  }

  void handleGoogleAuth(){}
}
 