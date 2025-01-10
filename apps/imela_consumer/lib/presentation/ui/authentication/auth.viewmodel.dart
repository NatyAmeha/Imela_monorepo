import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/authentication/create_account_for_google_signin.dart';
import 'package:imela/presentation/ui/authentication/phone_login_page.dart';
import 'package:imela/presentation/ui/authentication/phone_verify_page.dart';
import 'package:imela/presentation/ui/home/home.page.dart';
import 'package:imela/presentation/ui/profile/update_profile/update_profile_page.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_core/user/auth.usecase.dart';
import 'package:imela_core/user/dto/user_signup_input.dart';
import 'package:imela_core/user/model/auth_response.dart';
import 'package:imela_core/user/model/user.model.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
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

  TextEditingController verifyPinController = TextEditingController();

  // page state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;

  // google auth state variables
  var phoneNumberController = TextEditingController();
  var emailController = TextEditingController();
  var firstNameController = TextEditingController();
  var googleUser = Rxn<User>();
  var isInputValid = false.obs;
  var canShowWarningDialog = true;

  String? redirectUrl;
  Map<String, dynamic>? redirectExtra;

  var phoneNumber = ''.obs;
  var isPhoneNumberValid = false.obs;

  static AuthViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<AuthViewmodel>());
  }

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
        appController.firebaseAuthInfo = response;
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

  Future<void> handleGoogleAuthentication(BuildContext context) async {
    final widgetFactory = appController.getWidgetFactory(context);
    try {
      isLoading(true);
      final response = await authUsecae.continueWithGoogle();
      if (response.success) {
        // user is already registered on the api
        await handleRedirect(context, user: response.user, isNewUser: response.isNewUser ?? false);
        return;
      } else {
        // user is not registered on the api, we need to create a new account from fetched google credentials
        if (response.user != null) {
          CreateAccountForGoogleSignin.navigate(context, response.user!);
        } else {
          widgetFactory.showFlashMessage(context, message: 'An error occured while trying to sign in with google');
        }
      }
    } catch (e) {
      widgetFactory.showFlashMessage(context, message: 'An error occured while trying to sign in with google');
    } finally {
      isLoading(false);
    }
  }

  void initializeTextFields(User userInfo) {
    Future.delayed(Duration.zero, () {
      googleUser.value = userInfo;
      firstNameController.text = userInfo.username?.split(' ').first ?? '';
      emailController.text = userInfo.email ?? '';
      phoneNumberController.text = userInfo.phoneNumber ?? '';
    });
  }

  Future<void> registerUserWithGoogleAccountInfo(BuildContext context) async {
    try {
      isLoading(true);
      canShowWarningDialog = false;
      final signupInput = SignupInput.getGoogleSignupInput(
        googleId: googleUser.value!.id!,
        phoneNumber: phoneNumber.value,
        username: firstNameController.text,
        email: googleUser.value!.email,
        profileImageUrl: googleUser.value!.profileImageUrl,
      );
      final response = await authUsecae.registerWithGoogleAccountData(signupInput);
      if (response.isSuccessfull) {
        await handleRedirect(context, user: response.user, isNewUser: response.isNewUser ?? false);
      }
    } catch (e) {
      print('Error occured: ${e.toString()}');
      exception.value = AppException(message: 'An error occured while trying to register user');
      canShowWarningDialog = true;
    } finally {
      isLoading(false);
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

  Future<void> handleRedirect(BuildContext context, {User? user, bool isNewUser = false}) async {
    if (isNewUser) {
      UpdateProfilePage.navigate(context, redirectUrl: redirectUrl ?? HomePage.routeName, redirectExtra: redirectExtra);
      return;
    }
    appController.setLoggedInUser(user);
    appController.reloadHomePageDestination(true);
    // resetGraphQlClientInstance();
    await HomePage.navigate(context, replace: true);
    if (redirectUrl != null) {
      await appController.router.navigateTo(context, redirectUrl!, extra: redirectExtra);
    }
  }

  @override
  void dispose() {
    // verifyPinController.dispose();
    super.dispose();
  }

  void checkInputValidity() {
    final isValid = firstNameController.text.isNotEmpty && phoneNumber.value.length >= 13 && emailController.text.isNotEmpty;
    isInputValid.value = isValid;
  }

  void showWarningAlertDialog(BuildContext context) {
    if (canShowWarningDialog) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: const Text('Are you sure you want to leave this page?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              child: const Text('Leave'),
              onPressed: () {
                Navigator.pop(context);
                appController.router.goBack(context);
              },
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }
}
