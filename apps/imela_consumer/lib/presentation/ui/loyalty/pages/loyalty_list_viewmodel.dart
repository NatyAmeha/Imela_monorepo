import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/home/home.page.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_details_page.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_list_page.dart';
import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/loyalty/loyalty_usecase.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
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
  String get selectedLanguage => appViewmodel.selectedLanguageUpdated.value;
  var colorLoyaltyCardColors = ColorManager.colors;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    var context = data?['context'];
    Future.delayed(Duration.zero, () {
      getCustomerLoyalties(context);
    });
  }

  Future<void> getCustomerLoyalties(BuildContext context, {ApiDataFetchPolicy apiDataFeed = ApiDataFetchPolicy.cacheFirst}) async {
    try {
      isLoading.value = true;
      exception.value = null;
      final result = await loyaltyUsecase.getCustomerLoyalties(apiDataFeed: appViewmodel.loggedInUser.value?.id == null ? ApiDataFetchPolicy.networkOnly : apiDataFeed);
      if (!(result?.success ?? false) || (result?.customerLoyalties?.isEmpty ?? true)) {
        exception(
          AppException(
            message: 'No loyalty found. Order products or services from your favorite businesses to earn rewards.',
            actionText: 'Order Now',
            isMainError: true,
            onAction: () {
              HomePage.navigate(context, replace: true);
            },
          ),
        );
        return;
      }
      loyaltyInfo.value = result;
      customerLoyalties.value = result?.customerLoyalties ?? [];
    } catch (e) {
      var ex = exceptiionHandler.getException(e as Exception);
      if (ex.isUnAuthorizedException == true) {
        await appViewmodel.refreshTokenOrLogout(context, moveToLogin: true, showLoginMessage: true, redirectUrl: LoyaltyListPage.routeName, redirectExtra: {});
      }
      exception.value = ex;
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToLoyaltyDetail(BuildContext context, CustomerLoyalty loyalty) {
    LoyaltyDetailsPage.navigate(context, programName: loyalty.currentTier?.name?.localize(selectedLanguage) ?? '', businessId: loyalty.businessId!);
  }

  
}
