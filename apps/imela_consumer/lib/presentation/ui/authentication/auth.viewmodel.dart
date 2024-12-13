import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/authentication/phone_login_page.dart';
import 'package:imela/presentation/ui/authentication/phone_verify_page.dart';
import 'package:imela/presentation/ui/home/home.page.dart';
import 'package:imela/presentation/ui/profile/update_profile/update_profile.viewmodel.dart';
import 'package:imela/presentation/ui/profile/update_profile/update_profile_page.dart';
import 'package:imela/presentation/ui/shared/base_viewmodel.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_core/user/auth.usecase.dart';
import 'package:imela_core/user/model/auth_response.dart';
import 'package:imela_core/user/model/user.model.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';

import 'package:intl_phone_field/phone_number.dart';

@injectable
class AuthViewmodel extends GetxController with BaseViewmodel {
  final IExceptiionHandler exceptiionHandler;
  AuthUsecase authUsecae;

  AuthViewmodel({
    required this.authUsecae,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  AppController get appController => AppController.getInstance;

  late TextEditingController verifyPinController;

  // page state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;

  String? redirectUrl;
  Map<String, dynamic>? redirectExtra;

  var phoneNumber = ''.obs;
  var isPhoneNumberValid = false.obs;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    redirectUrl = data?['REDIRECT_URL'];
    redirectExtra = data?['REDIRECT_EXTRA'];
    verifyPinController = TextEditingController();
    print('redirect url ${redirectUrl} ${redirectExtra}');
  }

  void updatePhoneNumber(PhoneNumber number) {
    phoneNumber.value = number.completeNumber;
    isPhoneNumberValid.value = number.isValidNumber();
  }

  var enableVerifyButton = false.obs;
  void updateVerifyButtonState(String code) {
    verifyPinController.text = code;
    enableVerifyButton.value = verifyPinController.text.length == 6;
  }

  Timer? smsCodeTimer;
  var isSmsCodeSent = true.obs;
  void startResendCodeTimer() {
    Future.delayed(Duration.zero, () {
      enableVerifyButton.value = false;
      verifyPinController.clear();
      isSmsCodeSent.value = true;
      smsCodeTimer = Timer(
        const Duration(seconds: 30),
        () {
          isSmsCodeSent.value = false;
        },
      );
    });
  }

  void cancelResendCodeTimer() {
    smsCodeTimer?.cancel();
  }

  void navigateToPhoneLoginPage(BuildContext context) {
    PhoneLoginPage.navigate(context, appController.router);
  }

  Future<void> handlePhoneAuthentication(BuildContext context) async {
    if (phoneNumber.isEmpty && phoneNumber.value.length < 11) {
      errorMessage.value = 'Please enter a valid phone number';
      return;
    }
    isLoading.value = true;
    try {
      final response = await authUsecae.continueWithPhoneNumber(phoneNumber.value);
      if (response is AuthResponse) {
        // automatic phone verification without sms code
        if (response.isSuccessfull) {
          handleRedirect(context, user: response.user, isNewUser: response.isNewUser ?? false);
        } else {
          appController.getWidgetFactory(context).showFlashMessage(context, message: 'Unable to authenticate');
        }
      } else if (response is FirebaseAuthResponse) {
        // it means we need to navigate to the next screen to enter the sms code
        if (response.errorMsg != null) {
          appController.getWidgetFactory(context).showFlashMessage(context, message: response.errorMsg!);
          return;
        }
        PhoneVerifyPage.navigate(context);
      }
    } catch (e) {
      print('Error occured: ${e.toString()}');
      exception.value = exceptiionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifySmsAndAuthenticate(BuildContext context) async {
    try {
      final smsCode = verifyPinController.text;
      if (smsCode.isEmpty) {
        appController.getWidgetFactory(context).showFlashMessage(context, message: 'Please enter a valid pin');
        return;
      }
      final verificationId = appController.firebaseAuthInfo?.verificationId;
      if (verificationId == null) {
        appController.getWidgetFactory(context).showFlashMessage(context, message: 'Verification id is missing');
        return;
      }
      final result = await authUsecae.verifyPhoneNumber(phoneNumber.value, verificationId, smsCode);
      if (result.isSuccessfull) {
        appController.setLoggedInUser(result.user);
        handleRedirect(context, user: result.user, isNewUser: result.isNewUser ?? false);
      } else {
        appController.getWidgetFactory(context).showFlashMessage(context, message: 'Unable to authenticate');
      }
    } catch (e) {
      exception.value = AppException(message: 'An error occured while trying to verify sms code');
    }
  }

  void handleGoogleAuth(BuildContext context) {
    // handleRedirect(context);
  }

  void handleRedirect(BuildContext context, {User? user, bool isNewUser = false}) async {
    appController.setLoggedInUser(user);
    if (isNewUser) {
      UpdateProfilePage.navigate(context, redirectUrl: redirectUrl ?? HomePage.routeName, redirectExtra: redirectExtra);
      return;
    }
    appController.reloadHomePageDestination(true);
    await HomePage.navigate(context, replace: true);
    if (redirectUrl != null) {
      await appController.router.navigateTo(context, redirectUrl!, extra: redirectExtra);
    }
    resetGraphQlClientInstance();
  }

  @override
  void dispose() {
    // verifyPinController.dispose();
    super.dispose();
  }
}
