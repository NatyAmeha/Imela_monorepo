import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/routing_service.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/ui/business_registration/business_signin_page.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/user/auth.usecase.dart';
import 'package:imela_core/user/model/user.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class AppViewmodel extends GetxController with BaseViewmodel {
  static WidgetFactory? _widgetFactoryInstance;
  
  final AuthUsecase authUsecase;

  AppViewmodel({required this.authUsecase});

  late GoRouterService appRouter;

  // global state variables
  var loggedInUser = Rxn<User>();
  final businessList = <Business>[].obs;
  final selectedBusiness = Rxn<Business>();

  // getter
  String? get selectedBusinessId => selectedBusiness.value?.id;


  @override
  Future<void> initViewmodel({Map<String, dynamic>? data}) async {
    Get.put(this);
    appRouter = getIt<GoRouterService>(instanceName: GoRouterService.injectName);
  }

  static AppViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<AppViewmodel>());
  }

  // Getters
  String? get loggedInUserId => loggedInUser.value?.id;
  bool get isUserLoggedIn => loggedInUser.value != null;

  static WidgetFactory getWidgetFactory(BuildContext context) {
    return _widgetFactoryInstance ??= WidgetFactory(Theme.of(context).platform); 
  }


  var selectedLanguage = AppLanguage.ENGLISH.name;
  var selectedCurrency = 'USD';

  Future<void> getCurrentUser() async {
    final user =  await authUsecase.getCurrentUserInfoFromJwt();
    loggedInUser.value = user;
  }

  void setBusinessList(List<Business> businesses){
    businessList.addAll(businesses);
  }

  void setSelectedBusiness(Business business){
    selectedBusiness.value = business;
  }

  Future<void> logout(BuildContext context) async {
    final result = await authUsecase.logout();
    loggedInUser.value = null;
    if (result) {
      BusinessSignInPage.navigate(context);
    }
  }


  



}
