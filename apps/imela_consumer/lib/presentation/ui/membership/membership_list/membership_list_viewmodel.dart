import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/membership/components/membership_benefit_modal.dart';
import 'package:imela/presentation/ui/membership/membership_detail/membership_detail_page.dart';
import 'package:imela/presentation/ui/membership/membership_list/membership_list_page.dart';
import 'package:imela/presentation/ui/membership/membership_plan_list/membership_plan_list_page.dart';
import 'package:imela_core/membership/dto/membership_response.dart';
import 'package:imela_core/membership/membership_usecase.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

enum MembershipListType {
  USER_MEMBERSHIP,
}

@injectable
class MembershipListViewmodel extends GetxController with BaseViewmodel {
  final MembershipUseCase membershipUseCase;
  final IExceptiionHandler exceptiionHandler;
  MembershipListViewmodel({
    required this.membershipUseCase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static const backgroundColorSamples = const [
    ColorManager.primary,
    ColorManager.secondary,
    ColorManager.tertiary,
    ColorManager.accent2,
  ];

  static MembershipListViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<MembershipListViewmodel>());
  }

  String membershipListType = MembershipListType.USER_MEMBERSHIP.name;
  // state variables
  var isLoading = false.obs;
  var isProductsLoading = false.obs;
  var exception = Rxn<AppException>();

  var membershipResponse = Rxn<MembershipResponse>();
  var qrCodeList = Rxn<Map<String, Widget>>();

  // getters
  AppController get appViewmodel => AppController.getInstance;
  List<Membership> get membershipList => membershipResponse.value?.memberships ?? [];

  String get selectedLanguage => appViewmodel.selectedLanguage.name;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    membershipListType = data?[UserMembershipListPage.MEMBERSHIP_LIST_TYPE_KEY] ?? MembershipListType.USER_MEMBERSHIP;
    var context = data?['context'] as BuildContext;
    Future.delayed(Duration.zero, () async {
      getUserMemberships(context);
    });
  }

  Future<void> getUserMemberships(BuildContext context) async {
    try {
      isLoading.value = true;
      exception.value = null;
      membershipResponse.value = await membershipUseCase.getUserMemberships(fetchPolicy: ApiDataFetchPolicy.networkOnly);
      getqrCodeList();
    } catch (e) {
      var ex = exceptiionHandler.getException(e as Exception);
      if (ex.isUnAuthorizedException == true) {
        await appViewmodel.refreshTokenOrLogout(context, moveToLogin: true, showLoginMessage: true, redirectUrl: MembershipPlanListPage.routeName, redirectExtra: {});
      }
      exception.value = ex;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getqrCodeList() async {
    if (appViewmodel.loggedInUser.value?.id == null) {
      qrCodeList.value = {};
      return;
    }
    final result = <String, Widget>{};
    await Future.forEach(membershipList, (membership) async {
      final qrCodeResponse = await membershipUseCase.generateUserMembershipQRCode(membership.id!, appViewmodel.loggedInUser.value!.id!);
      if (qrCodeResponse.success && qrCodeResponse.qrCodeWidget != null) {
        result[membership.id!] = qrCodeResponse.qrCodeWidget!;
      }
    });
    qrCodeList.value = result;
  }

  Widget getQrCode(String membershipId) {
    return qrCodeList.value?[membershipId] ?? const SizedBox.shrink();
  }

  Color getRandomBackgroundColor(int index) {
    return backgroundColorSamples[index % backgroundColorSamples.length];
  }

  Future<void> showMembershipBenefitsModal(BuildContext context, Membership membership) async {
    await AppModalSheet.showModal(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
      ModalContent(
        title: const Text('Membership Details'),
        content: MembershipBenefitsModal(
          membershipInfo: membership,
          currentUserSubscription: membership.currentUserSubscription,
          qrcodeWidget: getQrCode(membership.id!),
          selectedLanguage: appViewmodel.selectedLanguage.name,
          currency: appViewmodel.selectedCurrency.name,
        ),
      )
    ]);
  }

  void navigateToMembershipDetails(BuildContext context, Membership item) {
    MembershipDetailsPage.navigate(context, item.id!);
  }
}
