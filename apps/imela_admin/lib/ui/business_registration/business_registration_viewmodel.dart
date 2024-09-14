import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';

import 'package:imela_admin/injection.dart';
import 'package:imela_admin/resources/values.dart';
import 'package:imela_admin/shared/component/input_field.viewmodel.dart';
import 'package:imela_admin/ui/business_registration/business_signin_page.dart';
import 'package:imela_admin/ui/business_registration/registration_page.dart';
import 'package:imela_admin/ui/business_subscription/platform_service_list_page.dart';
import 'package:imela_core/user/auth.usecase.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class BusinessRegistrationViewmodel extends GetxController with BaseViewmodel {
  final AuthUsecase authUsecase;

  BusinessRegistrationViewmodel({required this.authUsecase});

  final phoneNumberController = TextEditingController();

  final businessNameInputViewodel = TextInputViewmodel.getInstance(key: 'businessName');
  final businessEmailInputViewodel = TextInputViewmodel.getInstance(key: 'businessEmail');
  final businessDescriptionInputViewodel = TextInputViewmodel.getInstance(key: 'businessDescription');
  final cityInputViewmodel = TextInputViewmodel.getInstance(key: 'city');
  final addressInputViewmodel = TextInputViewmodel.getInstance(key: 'address');
  final locationInputViewmodel = TextInputViewmodel.getInstance(key: 'location');

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var showEmailInput = true.obs;

  var businessName = <String, String>{AppLanguage.ENGLISH.name: '', AppLanguage.AMHARIC.name: ''}.obs;
  var selectedBusienssNameKey = AppLanguage.ENGLISH.name.obs;

  var businessDescription = <String, String>{AppLanguage.ENGLISH.name: '', AppLanguage.AMHARIC.name: ''}.obs;
  var selectedBusienssDescriptionKey = AppLanguage.ENGLISH.name.obs;

  // getters
  AppViewmodel get appcontroller => AppViewmodel.getInstance();

  static BusinessRegistrationViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<BusinessRegistrationViewmodel>());
  }

  double getFormWidth(BuildContext context) {
    if (Responsive.isSmallScreen(context))
      return MediaQuery.sizeOf(context).width;
    else if (Responsive.isMediumScreen(context))
      return MediaQuery.sizeOf(context).width * 0.7;
    else
      return MediaQuery.sizeOf(context).width * 0.4;
  }

  Future<void> registerBusiness(BuildContext context) async {
    PlatformServiceListPage.navigate(context);
  }

  Map<String, Widget> getBusinessCategories(BuildContext context) {
    return categories.asMap().map((index, key) => MapEntry(
        key,
        Text(
          key,
          style: Theme.of(context).textTheme.bodyMedium,
        )));
  }

  void navigateToSigninPage(BuildContext context) {
    BusinessSignInPage.navigate(context);
  }

  void navigateToBusinessRegistrationPage(BuildContext context) {
    BusinessRegistrationPage.navigate(context);
  }
}
