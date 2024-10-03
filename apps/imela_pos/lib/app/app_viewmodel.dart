import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/staff/model/staff_model.dart';
import 'package:imela_core/user/auth.usecase.dart';
import 'package:imela_core/user/model/user.model.dart';
import 'package:imela_data/injection.dart';
import 'package:imela_pos/app/routing_service.dart';
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
  var loggedInStaff = Rxn<Staff>();

  final selectedBusiness = Rxn<Business>();
  var selectedBranch = Rxn<Branch>();

  var cartInfo = const Cart(name: [LocalizedField(key: "ENGLISH", value: "Cart")], items: []).obs;

  // getter

  bool get isUserAuthenticated {
    return loggedInStaff.value != null;
  }

  String get selectedBusinessId => selectedBusiness.value!.id!;
  String get selectedBranchId => selectedBranch.value!.id!;

  List<Branch> get staffBranchList {
    if (loggedInStaff.value == null || loggedInStaff.value!.branch == null) return [];
    return [loggedInStaff.value!.branch!];
  }

  List<PaymentOption> get paymentOptions {
    return selectedBusiness.value?.paymentOptions ?? [PaymentOption.defaultPaymentOption()];
  }

  List<PaymentMethod> get paymentMethods {
    return PaymentMethod.getFakePaymentMethods();
  }

  @override
  Future<void> initViewmodel({Map<String, dynamic>? data}) async {
    Get.put(this);
    appRouter = getIt<GoRouterService>(instanceName: GoRouterService.injectName);
  }

  static AppViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<AppViewmodel>());
  }

  // Getters
  String? get loggedInStaffName => loggedInStaff.value?.name;
  bool get isUserLoggedIn => loggedInStaff.value != null;

  static WidgetFactory getWidgetFactory(BuildContext context) {
    return _widgetFactoryInstance ??= WidgetFactory(Theme.of(context).platform);
  }

  var selectedLanguage = AppLanguage.ENGLISH.name;
  var selectedCurrency = 'ETB';

  void setSelectedBusiness(Business business) {
    selectedBusiness.value = business;
  }

  void setLoggedInStaff(Staff staff) {
    loggedInStaff.value = staff;
    selectedBranch.value = staff.branch;
  }

  void selectBranch(Branch? branch) {
    if (branch != null) {
      selectedBranch.value = branch;
    }
  }

  // Future<void> logout(BuildContext context) async {
  //   final result = await authUsecase.logout();
  //   loggedInUser.value = null;
  //   if (result) {
  //     BusinessSignInPage.navigate(context);
  //   }
  // }
}
