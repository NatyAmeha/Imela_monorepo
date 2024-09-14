import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';

import 'package:imela_admin/injection.dart';
import 'package:imela_admin/ui/business_registration/business_signin_page.dart';
import 'package:imela_admin/ui/business_registration/registration_page.dart';
import 'package:imela_core/user/auth.usecase.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class BusinessAuthViewmodel extends GetxController with BaseViewmodel {
  final AuthUsecase authUsecase;

  BusinessAuthViewmodel({required this.authUsecase});

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

  Future<void> registerWithEmail() async {}

  void navigateToSigninPage(BuildContext context) {
    BusinessSignInPage.navigate(context);
  }

  void navigateToBusinessRegistrationPage(BuildContext context) {
    BusinessRegistrationPage.navigate(context);
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
}
