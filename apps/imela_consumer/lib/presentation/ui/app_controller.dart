import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/app/app.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/authentication/auth_selection_page.dart';
import 'package:imela/presentation/ui/cart/cart_detail_page.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/loyalty/loyalty_usecase.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/membership/dto/membership_response.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/settings/setting_usecase.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_core/subscription/model/subscription.model.dart';
import 'package:imela_core/user/auth.usecase.dart';
import 'package:imela_core/user/model/auth_response.dart';
import 'package:imela_core/user/model/user.model.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_utils/helpers/localization_utils.dart';

@injectable
class AppController extends GetxController with BaseViewmodel {
  final AuthUsecase authUsecase;
  final LoyaltyUsecase loyaltyUsecase;
  final SettingUsecase settingUsecase;
  final IExceptiionHandler exceptiionHandler;

  AppController({
    required this.authUsecase,
    required this.settingUsecase,
    required this.loyaltyUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });
  static AppController get getInstance {
    return BaseViewmodel.isViewmodelRegistered(getIt<AppController>());
  }

  FirebaseAuthResponse? firebaseAuthInfo;
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  late GoRouterService router;

  AppLanguage selectedLanguage = AppLanguage.ENGLISH;
  Currency selectedCurrency = Currency.ETB;

  Rx<String> selectedLanguageUpdated = AppLanguage.ENGLISH.name.obs;

  // state variables
  var loggedInUser = Rxn<User>();
  var requireUserCheck = true.obs;
  var reloadHomePageDestination = true.obs;
  List<Business> favoriteBusinesses = [];

  var collectedDiscounts = <Discount>[].obs;

  var selectedBusiness = Rxn<Business>();
  var selectedBusinessBranchId = <String, String>{}.obs;

  var selectedBusinessLoyaltyInfo = Rxn<LoyaltyResponse>();
  var customerLoyalty = Rxn<CustomerLoyalty>();

  var businessMembershipInfo = Rxn<MembershipResponse>();

  var usedRewardPoints = (0.0).obs;

  var defaultPaymentMethods = PaymentMethod.getFakePaymentMethods();
  var refetchOrderList = false.obs;

  // getter
  BuildContext getAppContext() {
    return AppController.scaffoldMessengerKey.currentContext!;
  }

  bool get isAuthenticated => loggedInUser.value != null;
  List<Reward> get allRewards => selectedBusinessLoyaltyInfo.value?.tier?.rewards ?? [];
  List<Reward> get userEligableRewards {
    return allRewards.where((element) => element.minPointsToRedeem.toDouble() <= (remainingPoints)).toList();
  }

  List<Discount> get businessDiscounts => selectedBusiness.value?.discounts ?? [];

  // business membership getters
  List<Subscription?> get currentUserBusinessMembershipsSubscriptions {
    return businessMembershipInfo.value?.memberships?.map((membership) => membership.currentUserSubscription).toList() ?? [];
  }

  List<String> get currentUserMembershipIds => currentUserBusinessMembershipsSubscriptions.map((subscription) => subscription?.subscribedTo).whereType<String>().toList();

  List<Discount> get currentUserBusinessMembershipsDiscounts {
    final subscribedMemberships = businessMembershipInfo.value?.memberships?.where((membership) => membership.currentUserSubscription != null).toList() ?? [];
    final discounts = subscribedMemberships.map((membership) => membership.benefits?.map((benefit) => benefit.getFullDiscontInfo(membership.name)).flattened.toList() ?? []).flattened.toList();
    return discounts;
  }

  Discount? get heighestMembershipDiscounts => currentUserBusinessMembershipsDiscounts.firstOrNull;

  static WidgetFactory? _widgetFactory;
  WidgetFactory getWidgetFactory(BuildContext context) {
    _widgetFactory ??= WidgetFactory(Theme.of(context).platform);
    return _widgetFactory!;
  }

  double get remainingPoints => (customerLoyalty.value?.currentPoints ?? 0.0) - usedRewardPoints.value;

  var carts = <Cart>[].obs;
  bool enableCartFetchFromApi = true;

  @override
  Future<void> initViewmodel({Map<String, dynamic>? data}) async {
    Get.put(this);
    router = getIt<GoRouterService>(instanceName: GoRouterService.injectNameBeta);
    Future.delayed(Duration.zero, () {
      getInitialSettings();
      // POSDBDataSource.initDB(AppConstants.APP_DB_NAME);
    });
  }

  void getInitialSettings() async {
    final selectedLanguage = await settingUsecase.getSelectedLanguage();
    selectedLanguageUpdated.value = selectedLanguage;
    updateLanguage(AppLanguage.values.firstWhere((element) => element.name == selectedLanguage), (locale) {
      MelegnaCustomerApp.of(getAppContext()!)?.setLocale(locale);
    });
  }

  void updateSelectedBusiness(Business? business) {
    selectedBusiness.value = business;
  }

  // Method to update the selected language
  // Method to update the selected language
  Future<void> updateLanguage(AppLanguage language, Function(Locale) updateLocaleCallback) async {
    try {
      selectedLanguageUpdated.value = language.name;
      await settingUsecase.saveSelectedLanguage(language.name);
      // Update the app's locale by calling the provided callback
      updateLocaleCallback(language.locale);
    } catch (e) {
      print('updateLanguage error: $e');
    }
  }

  Future<void> getCurrentUser() async {
    final user = await authUsecase.getCurrentUserInfoFromJwt();
    setLoggedInUser(user);
  }

  void setSelectedBusinessBranchId(String businessId, String branchId) {
    selectedBusinessBranchId[businessId] = branchId;
  }

  String? getSelectedBusinessBranchId(String businessId) {
    return selectedBusinessBranchId[businessId];
  }

  Cart? getCartById(String cartId) {
    return carts.firstWhereOrNull((element) => element.id == cartId);
  }

  Cart? getCartByBusinessId(String businessId) {
    return carts.firstWhereOrNull((element) => element.businessIds?.contains(businessId) ?? false);
  }

  void addDiscounts(List<Discount> discounts, {bool clearPrevious = false}) {
    if (clearPrevious) {
      collectedDiscounts.clear();
    }
    collectedDiscounts.addAll(discounts);
  }

  void setLoggedInUser(User? user) {
    loggedInUser.value = user;
  }

  void setFavoriteBusinesses(List<Business> businesses) {
    favoriteBusinesses = businesses;
  }

  bool isBusinessInFavorite(String businessId) {
    return favoriteBusinesses.any((element) => element.id == businessId);
  }

  void updateLoggedinUserFields(User? updatedUserInfo) {
    loggedInUser.value = loggedInUser.value?.copyWith(
      firstName: updatedUserInfo?.firstName,
      lastName: updatedUserInfo?.lastName,
      email: updatedUserInfo?.email,
    );
  }

  void clearDiscounts() {
    collectedDiscounts.clear();
  }

  void setSelectedBusinessLoyaltyInfo(LoyaltyResponse? loyaltyInfo) {
    selectedBusinessLoyaltyInfo.value = loyaltyInfo;
    customerLoyalty.value = loyaltyInfo?.customerLoyalty;
  }

  void setBusinessMembershipInfo(MembershipResponse? membershipInfo) {
    businessMembershipInfo.value = membershipInfo;
  }

  Subscription? getCurrentUserSubscription(String membershipId) {
    return businessMembershipInfo.value?.memberships?.firstWhereOrNull((e) => e.currentUserSubscription != null)?.currentUserSubscription ?? businessMembershipInfo.value?.currentUserSubscription;
  }

  bool isCurrentUserSubscriptionActive(String membershipId) {
    final subscription = getCurrentUserSubscription(membershipId);
    return subscription?.endDate?.isAfter(DateTime.now()) ?? false;
  }

  bool currentUserIsMember(List<String>? membershipIds) {
    if (membershipIds == null || membershipIds.isEmpty) return false;
    final subscriptions = membershipIds.map((id) => getCurrentUserSubscription(id)).toList().whereType<Subscription>().toList();
    return subscriptions.isNotEmpty;
  }

  Future<LoyaltyResponse?> getCustomerBusinessLoyalty(BuildContext context, String businessId) async {
    try {
      setSelectedBusinessLoyaltyInfo(null);
      var loyaltyInfo = await loyaltyUsecase.getCustomerBusinessLoyalty(businessId);
      if (loyaltyInfo?.success ?? false) {
        setSelectedBusinessLoyaltyInfo(loyaltyInfo);
        final customerPoints = loyaltyInfo?.customerLoyalty?.currentPoints ?? 0.0;
        final tierInfo = await loyaltyUsecase.getCustomerTierByPoints(businessId, customerPoints);
        print('loyaltyInfo tier : ${tierInfo}');
        if (tierInfo?.success ?? false) {
          // take the higher tier from eligable customer loyalty tiers
          loyaltyInfo = loyaltyInfo?.copyWith(tier: tierInfo?.tiers?.firstOrNull);
          setSelectedBusinessLoyaltyInfo(loyaltyInfo);
        }
      }
      return loyaltyInfo;
    } catch (e) {
      print('loyalty fetch error: $e');
      final ex = exceptiionHandler.getException(e as Exception);
      if (!ex.isUnAuthorizedException) {
        getWidgetFactory(context).showFlashMessage(context, message: 'Error occurred, please try again', actionText: 'Try again', onActinClicked: () {
          getCustomerBusinessLoyalty(context, businessId);
        });
      }
      return null;
      // exception(exceptiionHandler.getException(e as Exception));
    }
  }

  void updateUsedRewardPoints(double points) {
    usedRewardPoints.value = points;
  }

  void removeRewardFromEligableRewards(Reward reward) {
    updateUsedRewardPoints(reward.minPointsToRedeem.toDouble());
    userEligableRewards.removeWhere((reward) => reward.minPointsToRedeem < remainingPoints);

    // final updatedCustomerLoyalty = selectedBusinessLoyaltyInfo.value?.customerLoyalty?.copyWith(currentPoints: remainingPoints);
    // customerLoyalty.value = updatedCustomerLoyalty;
  }

  void setRefetchOrderList(bool value) {
    refetchOrderList.value = value;
  }

  Future<bool> refreshTokenOrLogout(BuildContext context, {bool moveToLogin = true, bool showLoginMessage = false, String? redirectUrl, Map<String, dynamic>? redirectExtra, bool refreshToken = true}) async {
    try {
      final tokenRefreshed = await authUsecase.refreshToken();
      if (tokenRefreshed) {
        return true;
      }
      await logout(context, moveToLogin: moveToLogin, showLoginMessage: showLoginMessage, redirectUrl: redirectUrl, redirectExtra: redirectExtra);
      return false;
    } catch (e) {
      await logout(context, moveToLogin: moveToLogin, showLoginMessage: showLoginMessage, redirectUrl: redirectUrl, redirectExtra: redirectExtra);
      return false;
    }
  }

  Future<void> logout(BuildContext context, {bool moveToLogin = true, bool showLoginMessage = false, String? redirectUrl, Map<String, dynamic>? redirectExtra}) async {
    try {
      carts.clear();
      await authUsecase.logout();
      setLoggedInUser(null);
      requireUserCheck.value = true;
      if (moveToLogin) {
        AuthSelectionPage.navigate(context, redirectUrl: redirectUrl, redirectExtra: redirectExtra);
      } else if (showLoginMessage) {
        getWidgetFactory(context).showFlashMessage(context, message: 'Login to be able to continue', actionText: 'Login', onActinClicked: () {
          AuthSelectionPage.navigate(context, redirectUrl: redirectUrl, redirectExtra: redirectExtra);
        });
      }
    } catch (ex) {
      print('logout error: $ex');
    }
  }

  void changeCartApiFetchStatus(bool status) {
    enableCartFetchFromApi = status;
  }

  void showAddToCartDialog(BuildContext context, {required String message, required Cart cart}) {
    final widgetFactory = getWidgetFactory(context);
    AppModalSheet.showModal(
      context,
      type: AppModalSheetType.BOTTOMSHEET,
      pages: [
        ModalContent(
            title: const Text('Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                widgetFactory.createText(context, 'Successful', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                widgetFactory.createText(context, message, style: Theme.of(context).textTheme.bodyLarge),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total'),
                    widgetFactory.createText(context, cart.getTotalAmountPOSFormatted(selectedCurrency.name), style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: widgetFactory.createButton(
                        context: context,
                        content: widgetFactory.createText(context, 'Continue Shopping', style: Theme.of(context).textTheme.bodyMedium),
                        style: AppButtonStyle.outlinedButtonStyle(context, padding: EdgeInsets.symmetric(horizontal: 4)),
                        onPressed: () {
                          AppModalSheet.closeModal();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: widgetFactory.createButton(
                        context: context,
                        content: widgetFactory.createText(context, 'Go to cart', style: Theme.of(context).textTheme.bodyMedium),
                        onPressed: () async {
                          await AppModalSheet.closeModal();
                          CartDetailPage.navigateToCartDetailPage(context, router, cart);
                        },
                      ),
                    ),
                  ],
                ).paddingOnly(bottom: 16)
              ],
            ).paddingSymmetric(horizontal: 16))
      ],
    );
  }
}
