import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';

import 'package:imela_admin/injection.dart';
import 'package:imela_admin/resources/values.dart';
import 'package:imela_admin/shared/component/input_field.viewmodel.dart';
import 'package:imela_admin/ui/business/business_list.viewmodel.dart';
import 'package:imela_admin/ui/business_registration/business_signin_page.dart';
import 'package:imela_admin/ui/business_registration/registration_page.dart';
import 'package:imela_admin/ui/business_subscription/platform_service_list_page.dart';
import 'package:imela_core/business/business.usecase.dart';
import 'package:imela_core/business/dto/create_business_input.dart';
import 'package:imela_core/shared/address.model.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_core/user/auth.usecase.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class BusinessRegistrationViewmodel extends GetxController with BaseViewmodel {
  final AuthUsecase authUsecase;
  final BusinessUsecase businessUsecase;
  final IExceptiionHandler exceptiionHandler;

  BusinessRegistrationViewmodel({
    required this.authUsecase,
    required this.businessUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  AppViewmodel get appviewmodel => AppViewmodel.getInstance();

  var phoneNumberController = '';
  final businessNameInputViewodel = TextInputViewmodel.getInstance(key: 'businessName');
  final businessDescriptionInputViewodel = TextInputViewmodel.getInstance(key: 'businessDescription');
  final businessEmailController = TextEditingController();
  final cityInputViewmodel = TextInputViewmodel.getInstance(key: 'city');
  final addressInputViewmodel = TextInputViewmodel.getInstance(key: 'address');
  final locationController = TextEditingController();

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var showEmailInput = true.obs;

  var inputOptions = <String, String>{AppLanguage.ENGLISH.name: '', AppLanguage.AMHARIC.name: ''};
  var selectedInputOptionKey = AppLanguage.ENGLISH.name.obs;

  // getters
  AppViewmodel get appcontroller => AppViewmodel.getInstance();
  BusinessListViewmodel get businessListViewmodel => BusinessListViewmodel.getInstance();

  static BusinessRegistrationViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<BusinessRegistrationViewmodel>());
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    exception.value = null;
  } 

  void updatePhoneNumber(String phoneNumber) {
    phoneNumberController = phoneNumber;
  }

  Future<void> registerBusiness(BuildContext context) async {
    try {
      isLoading.value = true;
      exception.value = null;

      final businessName = businessNameInputViewodel.options.toLocalizedFieldArray();
      final businessDescription = businessDescriptionInputViewodel.options.toLocalizedFieldArray();
      final phoneNumber = phoneNumberController;
      final city = cityInputViewmodel.options.toLocalizedFieldArray();
      final address = addressInputViewmodel.options.toLocalizedFieldArray();
      final email = businessEmailController.text;
      final location = locationController.text;
      print('phone number: $phoneNumber'); 
      final businessInfoInput = CreateBusinessInput(
        name: businessName,
        description: businessDescription,
        phoneNumber: phoneNumber,
        mainAddress: Address(address: address.first.value, city: city.first.value!, location: location),
        email: email,
        categories: ["All"],
        creator: appviewmodel.loggedInUserId!,
        gallery: Gallery.fakeGalleryData(),
      );

      final result = await businessUsecase.registerBusiness(businessInfoInput);
      if (result.success == true) {
        businessListViewmodel.addBusinessToBusinessList(result.business!);
        PlatformServiceListPage.navigate(context);
      }
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
    } else if (Responsive.isMediumScreen(context))
      return MediaQuery.sizeOf(context).width * 0.7;
    else
      return MediaQuery.sizeOf(context).width * 0.4;
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
