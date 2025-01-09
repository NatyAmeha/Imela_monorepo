import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/app/app.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/authentication/auth_selection_page.dart';
import 'package:imela/presentation/ui/home/home.page.dart';
import 'package:imela/presentation/ui/home/home_page.viewmodel.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_list_page.dart';
import 'package:imela/presentation/ui/membership/membership_list/membership_list_page.dart';
import 'package:imela/presentation/ui/membership/membership_list/membership_list_viewmodel.dart';
import 'package:imela/presentation/ui/order/order_list/order_list_page.dart';
import 'package:imela/presentation/ui/profile/update_profile/update_profile_page.dart';
import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_core/user/auth.usecase.dart';
import 'package:imela_core/user/model/user.model.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_core/user/user.usecase.dart';
import 'package:imela_core/shared/components/language_selector.dart';

@injectable
class ProfileViewmodel extends GetxController with BaseViewmodel {
  // final OrderUsecase orderUsecase;
  final IExceptiionHandler exceptiionHandler;
  final UserUsecase userUsecase;
  final AuthUsecase authUsecase;

  ProfileViewmodel({
    required this.userUsecase,
    required this.authUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static ProfileViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<ProfileViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var user = Rxn<User>();
  var loyaltyResponse = Rxn<LoyaltyResponse>();

  var appViewmodel = AppController.getInstance;
  var homeViewmodel = HomepageViewmodel.getInstance();

  // Add these getters for easy access to user information

  String? get fullName => user.value?.username?.trim();
  String get fullNameInitial => appViewmodel.loggedInUser.value?.username?.trim().substring(0, 1) ?? '';
  String get email => user.value?.email ?? '';
  int get loyaltyPoints => 15; // Placeholder, replace with actual data source
  String get phoneNumber => user.value?.phoneNumber ?? 'Add Number';
  String get language => appViewmodel.selectedLanguageUpdated.value; // Placeholder, replace with actual data source
  String get currency => appViewmodel.selectedCurrency.name; // Placeholder, replace with actual data source

  @override
  void initViewmodel({Map<String, dynamic>? data}) async {
    super.initViewmodel(data: data);
    var context = data?['context'] as BuildContext;
    listenUserAuthChange(context);
    await fetchUserProfile(context);
  }

  void listenUserAuthChange(BuildContext context) {
    ever(appViewmodel.loggedInUser, (value) { 
      print('loggedInUser $value');
      setUser(value);
      getUserLoyaltyRewards(context);
    });
  }

  void setUser(User? user) {
    this.user.value = user;
  }

  Future<void> fetchUserProfile(BuildContext context) async {
    try {
      final result = await authUsecase.getCurrentUserInfoFromJwt();
      await getUserLoyaltyRewards(context);
      if (result != null) {
        setUser(result);
      }
      // setUser(appViewmodel.loggedInUser.value);
    } catch (e) {
      var ex = AppException(message: e.toString());
      if (ex.isUnAuthorizedException) {
        final tokenRefreshed = await appViewmodel.refreshTokenOrLogout(context);
        if (tokenRefreshed) {
          await fetchUserProfile(context);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserLoyaltyRewards(BuildContext context) async {
    try {
      // if (appViewmodel.loggedInUser.value == null) {
      //   return;
      // }
      final result = await userUsecase.getUserLoyaltyRewards();
      print('customer loyalty ${result?.customerLoyalties}');
      if (result != null) {
        loyaltyResponse.value = result;
      }
    } catch (e) {
      print('customer loyalty error $e');
    }
  }

  Future<void> logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              appViewmodel.reloadHomePageDestination(true);
              await appViewmodel.logout(context, redirectUrl: HomePage.routeName, redirectExtra: {});
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void navigateToLoyaltyRewards(BuildContext context) {
    LoyaltyListPage.navigate(context);
  }

  void navigateToLogin(BuildContext context) {
    AuthSelectionPage.navigate(context);
  }

  void showLanguageSelectorDialog(BuildContext context) {
    AppModalSheet.showModal(
      context,
      type: AppModalSheetType.BOTTOMSHEET,
      pages: [
        ModalContent(
          title: const Text(''),
          content: LanguageSelectorDialog(
            selectedLanguage: language,
            onLanguageSelected: (value) {
              updateLanguage(context, value);
              AppModalSheet.closeModal();
            },
          ),
        )
      ],
    );
  }

  Future<void> updateLanguage(BuildContext context, AppLanguage language) async {
    await appViewmodel.updateLanguage(language, (locale) {
      appViewmodel.reloadHomePageDestination(true);
      MelegnaCustomerApp.of(context)?.setLocale(locale);
    });
  }

  void navigateToMembershipList(BuildContext context) {
    UserMembershipListPage.navigateTo(context, MembershipListType.USER_MEMBERSHIP);
  }

  void navigateToOrderList(BuildContext context) {
    OrderListPage.navigate(context);
  }

  void navigateToUpdateProfile(BuildContext context) {
    UpdateProfilePage.navigate(context, pageTitle: 'Update Profile');
  }
}
