import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';

import 'package:imela_admin/injection.dart';
import 'package:imela_admin/ui/business/business_list_page.dart';
import 'package:imela_admin/ui/business_registration/business_signin_page.dart';
import 'package:imela_admin/ui/business_registration/business_signup_page.dart';
import 'package:imela_admin/ui/business_registration/registration_page.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_core/user/auth.usecase.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class BusinessAuthViewmodel extends GetxController with BaseViewmodel {
  final AuthUsecase authUsecase;
  final IExceptiionHandler exceptiionHandler;

  BusinessAuthViewmodel({
    required this.authUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  final firstNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var businessName = <String, String>{AppLanguage.ENGLISH.name: '', AppLanguage.AMHARIC.name: ''}.obs;
  var selectedBusienssNameKey = AppLanguage.ENGLISH.name.obs;

  var businessDescription = <String, String>{AppLanguage.ENGLISH.name: '', AppLanguage.AMHARIC.name: ''}.obs;
  var selectedBusienssDescriptionKey = AppLanguage.ENGLISH.name.obs;

  // getters
  AppViewmodel get appcontroller => AppViewmodel.getInstance();

  static BusinessAuthViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<BusinessAuthViewmodel>());
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    cleanupStateVariables();
  }

  Future<void> registerWithEmail(BuildContext context) async {
    try {
      exception.value = null;
      isLoading.value = true;
      final response = await authUsecase.register(firstNameController.text, emailController.text, passwordController.text);
      if (response.isSuccessfull) {
        if (response.isUserNew()) {
          navigateToBusinessRegistrationPage(context);
        }
      }
    } catch (ex) {
      print('Error: $ex');
      exception.value = exceptiionHandler.getException(ex as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    try {
      exception.value = null;
      isLoading.value = true;

      final response = await authUsecase.signInWithEmailAndPassword(emailController.text, passwordController.text);
      if (response?.isSuccessfull == true) {
        navigateToBusinessListPage(context);
      } else {
        AppViewmodel.getWidgetFactory(context).showFlashMessage(context, message: 'Invalid email or password');
      }
    } catch (ex) {
      exception.value = exceptiionHandler.getException(ex as Exception);
      print('Error: ${exception.value?.message}');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToSigninPage(BuildContext context) {
    BusinessSignInPage.navigate(context, replaceRoute: true);
  }

  void navigateToSignupPage(BuildContext context) {
    BusinessSignupPage.navigate(context, replaceRoute: true);
  }

  void navigateToBusinessRegistrationPage(BuildContext context) {
    BusinessRegistrationPage.navigate(context);
  }

  void navigateToBusinessListPage(BuildContext context) {
    BusinessListPage.navigate(context, replaceRoute: true);
  }

  //  UI helpers
  double getFormWidth(BuildContext context) {
    return Responsive.isSmallScreen(context) ? MediaQuery.sizeOf(context).width * 0.9 : MediaQuery.sizeOf(context).width * 0.6;
  }

  double signupHeaderCard(BuildContext context) {
    return Responsive.isSmallScreen(context) ? 100 : 200;
  }

  double signupFormWidth(BuildContext context) {
    return Responsive.isSmallScreen(context) ? MediaQuery.sizeOf(context).width * 0.9 : MediaQuery.sizeOf(context).width * 0.4;
  }

  void cleanupStateVariables() {
    firstNameController.clear();
    emailController.clear();
    passwordController.clear();
    exception.value = null;
    isLoading.value = false;
  }
}
