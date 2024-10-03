import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/ui/business_registration/business_signin_page.dart';
import 'package:imela_admin/ui/business_registration/registration_page.dart';
import 'package:imela_admin/ui/business_subscription/platform_service_list_page.dart';
import 'package:imela_admin/ui/dashboard/home_page.dart';
import 'package:imela_admin/ui/product/create_product_page.dart';
import 'package:imela_core/business/business.usecase.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/exception/exception_type.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class BusinessListViewmodel extends GetxController with BaseViewmodel {
  final BusinessUsecase businessUsecase;
  final IExceptiionHandler exceptiionHandler;

  BusinessListViewmodel({
    required this.businessUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  AppViewmodel get appViewmodel => AppViewmodel.getInstance();

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var businessList = <Business>[].obs;

  static BusinessListViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<BusinessListViewmodel>());
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    final context = data!['context'] as BuildContext;
    appViewmodel.getCurrentUser();
    getBusinessList(context);
  }

  // Getters
  String get userNameInitial {
    return appViewmodel.loggedInUser.value?.username?.substring(0, 1).toUpperCase() ?? '';
  }

  String getBusinessCallToActionString(Business business) {
    switch (business.getBusinessStage) {
      case BusinessRegistrationStages.CREATED:
        return 'Integrate Services';
      case BusinessRegistrationStages.PAYMENT_STAGE:
        return 'Complete Payment';
      case BusinessRegistrationStages.COMPLETED:
        return 'Go to Dashboard';
      default:
        return 'Integrate Services';
    }
  }

  void setupStateVariables() {
    businessList.clear();
    exception.value = null;
    isLoading.value = true;
  }

  Future<void> getBusinessList(BuildContext context) async {
    try {
      setupStateVariables();
      final result = await businessUsecase.getUserOwnedBusinesses();
      if (result?.isBusinessListFetchSuccessfull() == true) {
        if (result!.businesses?.isEmpty == true) {
          exception.value = AppException(
            message: 'No business found',
            isMainError: true,
            type: ExceptionType.USER_OWNED_BUSINESS_NOT_FOUND.name,
          );
          return;
        }
        businessList.value = result.businesses!;
        appViewmodel.setBusinessList(businessList);
      }
    } catch (ex) {
      print('error $ex');
      final exceptionResult = exceptiionHandler.getException(ex as Exception);
      if (exceptionResult.isUnAuthorizedException) {
        navigateToSignInPage(context);
      }
    } finally {
      isLoading.value = false;
    }
  }

  void addBusinessToBusinessList(Business business) {
    businessList.addIf((element) => element.id != business.id, business);
  }

  void handleBusinessListItemCallToAction(BuildContext context, Business business) {
    appViewmodel.setSelectedBusiness(business);
    switch (business.getBusinessStage) {
      case BusinessRegistrationStages.PAYMENT_STAGE:
      // BusinessPaymentPage.navigateTo(context, services: services);
      case BusinessRegistrationStages.COMPLETED:
        HomePage.navigate(context);
      default:
        PlatformServiceListPage.navigate(context);
    }
  }

  void navigateToSignInPage(BuildContext context) {
    appViewmodel.logout(context);
    BusinessSignInPage.navigate(context);
  }

  void navigateToBusinessRegistrationPage(BuildContext context) {
    BusinessRegistrationPage.navigate(context);
  }

  void navigateToProductCreatePage(BuildContext context, Business business) {
    CreateProductPage.navigate(context, business);
  }

  void logout(BuildContext context) {
    appViewmodel.logout(context);
  }
}
