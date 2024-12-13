import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_details_page.dart';
import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/loyalty/loyalty_usecase.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoyaltyListViewModel extends GetxController with BaseViewmodel {
  final LoyaltyUsecase loyaltyUsecase;
  final IExceptiionHandler exceptiionHandler;

  LoyaltyListViewModel({
    required this.loyaltyUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static LoyaltyListViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<LoyaltyListViewModel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var loyaltyInfo = Rxn<LoyaltyResponse>();
  var customerLoyalties = <CustomerLoyalty>[].obs;

  // getters
  AppController get appViewmodel => AppController.getInstance;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () {
      getCustomerLoyalties();
    });
  }

  Future<void> getCustomerLoyalties() async {
    try {
      isLoading.value = true;
      final result = await loyaltyUsecase.getCustomerLoyalties();
      if (result?.success ?? false) {
        exception(AppException(message: 'No loyalty found'));
      }
      loyaltyInfo.value = result;
      customerLoyalties.value = result?.customerLoyalties ?? [];
    } catch (e) {
      exception(exceptiionHandler.getException(e as Exception));
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToLoyaltyDetails(BuildContext context, CustomerLoyalty loyalty) {
    print('loyaltyInfo: ${loyalty.businessId}');
    LoyaltyDetailsPage.navigate(context, programName: loyalty.name.localize(appViewmodel.selectedLanguage.name), loyaltyInfo: loyaltyInfo.value, businessId: loyalty.businessId);
  }
}
