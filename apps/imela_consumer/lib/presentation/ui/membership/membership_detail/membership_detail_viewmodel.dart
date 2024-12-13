import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/membership/components/membership_benefit_modal.dart';
import 'package:imela/presentation/ui/membership/membership_detail/membership_confirmation_page.dart';
import 'package:imela/presentation/ui/membership/membership_detail/membership_detail_page.dart';
import 'package:imela/presentation/ui/membership/membership_detail/membership_payment_page.dart';
import 'package:imela/presentation/ui/payment/components/payment_method_list_modal.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.page.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/membership/dto/membership_response.dart';
import 'package:imela_core/membership/membership_usecase.dart';
import 'package:imela_core/membership/model/group.model.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_core/subscription/model/subscription.model.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/helpers/file_upload.model.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class MembershipDetailsViewModel extends GetxController with BaseViewmodel {
  final MembershipUseCase membershipUseCase;
  final IExceptiionHandler exceptiionHandler;
  MembershipDetailsViewModel({
    required this.membershipUseCase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static MembershipDetailsViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<MembershipDetailsViewModel>());
  }

  late String membershipId;
  // state variables
  var isLoading = false.obs;
  var isProductsLoading = false.obs;
  var exception = Rxn<AppException>();
  var membershipDetails = Rxn<MembershipResponse>();
  var membershipProducts = <Product>[].obs;

  // getters
  AppController get appViewmodel => AppController.getInstance;
  String get membershipName => membershipDetails.value?.membership?.name?.localize(appViewmodel.selectedLanguage.name) ?? '';
  String get membershipPrice => membershipDetails.value?.membership?.price?.toSelectedPriceString(appViewmodel.selectedCurrency.name) ?? '';
  GroupMember? get userGroupMemberInfo {
    final loggedInUserId = appViewmodel.loggedInUser.value?.id;
    final defaultGroup = membershipDetails.value?.membership?.groups?.firstWhereOrNull((element) => element.isDefault == true);
    if (defaultGroup == null || loggedInUserId == null) return null;
    final user = defaultGroup.members?.firstWhereOrNull((element) => element.userId == loggedInUserId);
    return user;
  }

  Membership? get membership => membershipDetails.value?.membership;
  Subscription? get subscription => membershipDetails.value?.currentUserSubscription;

  List<Discount> get membershipDiscounts => membership?.benefits?.map((benefit) => benefit.discounts ?? []).flattened.toList() ?? [];

  var membershipPaymentMethods = PaymentMethod.getFakePaymentMethods();
  var selectedPaymentMethod = Rxn<SelectedPaymentMethod>();

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    membershipId = data?[MembershipDetailsPage.MEMBERSHIP_ID_KEY] ?? '';
    var context = data?[MembershipDetailsPage.CONTEXT_KEY] as BuildContext;
    getMembershipInformation(context);
  }

  Future<void> getMembershipInformation(BuildContext context) async {
    Future.delayed(Duration.zero, () async {
      await getMembershipDetails(context, fetchPolicy: ApiDataFetchPolicy.networkOnly);
      await getMembershipProducts();
    });
  }

  bool isUserJoined() {
    if (userGroupMemberInfo?.isUserMembershipStatusPending ?? false) return true;
    if ((userGroupMemberInfo?.isUserMembershipStatusActive ?? false) && (subscription != null)) return true;
    return false;
  }

  Future<void> getMembershipDetails(BuildContext context, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    try {
      isLoading.value = true;
      exception.value = null;
      membershipDetails.value = null;
      final result = await membershipUseCase.getMembershipDetails(membershipId, fetchPolicy: fetchPolicy);
      membershipDetails.value = result;
    } catch (e) {
      var ex = exceptiionHandler.getException(e as Exception);
      if (ex.isUnAuthorizedException == true) {
        await appViewmodel.refreshTokenOrLogout(context, moveToLogin: false, showLoginMessage: true, redirectUrl: MembershipDetailsPage.routeName, redirectExtra: {MembershipDetailsPage.MEMBERSHIP_ID_KEY: membershipId});
        return;
      }
      exception.value = AppException(message: 'something went wrong', isMainError: false);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMembershipProducts() async {
    try {
      isProductsLoading.value = true;
      exception.value = null;

      final result = await membershipUseCase.getMembershipProducts(membershipId);
      if (result == null || result.success == false) {
        exception.value = AppException(message: 'something went wrong');
      }
      membershipProducts.value = result?.products ?? [];
    } catch (e) {
      print('exception $e');
    } finally {
      isProductsLoading.value = false;
    }
  }

  void navigateToProductDetails(BuildContext context, Product product) {
    ProductDetailPage.navigateBeta(context, product: product, discounts: membershipDiscounts);
  }

  Future<void> showPaymentMethodListModal(BuildContext context) async {
    final membershipPrice = membership?.price?.toSelectedPrice('ETB');
    if (membershipPrice == null) return;
    final amount = Price(amount: membershipPrice.amount, currency: appViewmodel.selectedCurrency.name);
    await AppModalSheet.showModal(
      context,
      type: AppModalSheetType.BOTTOMSHEET,
      pages: [
        ModalContent(
          title: const Text('Choose payment method'),
          content: PaymentMethodListModal(
            paymentMethods: membershipPaymentMethods,
            // initialPaymentMethod: selectedPaymentMethods.firstOrNull?.paymentMethod,
            onContinuePressed: (selectedPayment) {
              final paymentInfo = SelectedPaymentMethod(id: selectedPayment.id, name: selectedPayment.name!, amount: amount, requireReceiptImage: selectedPayment.requireReceiptImage);
              selectedPaymentMethod.value = paymentInfo;
              AppModalSheet.closeModal();
            },
          ),
        ),
      ],
    );
  }

  Future<void> showMembershipBenefitsModal(BuildContext context) async {
    final userId = appViewmodel.loggedInUser.value?.id ?? '';
    Widget? qrCodeWidget;
    if (userId.isNotEmpty) {
      final qrCodeResponse = await membershipUseCase.generateUserMembershipQRCode(membershipId, userId);
      if (qrCodeResponse.success) {
        qrCodeWidget = qrCodeResponse.qrCodeWidget;
      }
    }
    await AppModalSheet.showModal(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
      ModalContent(
        title: const Text('Membership Benefits'),
        content: MembershipBenefitsModal(
          membershipInfo: membership!,
          currentUserSubscription: subscription,
          qrcodeWidget: qrCodeWidget,
          selectedLanguage: appViewmodel.selectedLanguage.name,
          currency: appViewmodel.selectedCurrency.name,
        ),
      )
    ]);
  }

  void addPaymenReceiptImage(FileUpload? uploadedFile) {
    if (selectedPaymentMethod.value != null) {
      selectedPaymentMethod.value = selectedPaymentMethod.value?.copyWith(receiptImages: [uploadedFile?.file?.path ?? '']);
      selectedPaymentMethod.refresh();
    }
  }

  void removePaymentReceiptImage() {
    if (selectedPaymentMethod.value != null) {
      selectedPaymentMethod.value = selectedPaymentMethod.value?.copyWith(receiptImages: []);
      selectedPaymentMethod.refresh();
    }
  }

  void removeSelectedPaymentMethod() {
    selectedPaymentMethod.value = null;
  }

  void requestToJoinMembership(BuildContext context) async {
    try {
      final userId = appViewmodel.loggedInUser.value?.id;
      if (userId == null) {
        return;
      }
      isLoading.value = true;
      if (membership?.name == null || membership?.owner == null) {
        return;
      }
      if (selectedPaymentMethod.value == null) {
        return;
      }
      var result = await membershipUseCase.requestToJoinMembership(membership!.owner!, membershipId, memberId: userId, membershipName: membership!.name.localize('ENGLISH'), selectedPaymentMethod: selectedPaymentMethod.value!);
      if (result == null || result.success == false) {
        final widgetFactory = appViewmodel.getWidgetFactory(context);
        await widgetFactory.showFlashMessage(context, message: 'Unable to join membership', actionText: 'Retry', onActinClicked: () => requestToJoinMembership(context));
        return;
      }
      MembershipConfirmationPage.navigate(context, membershipId: membershipId);
    } catch (e) {
      print(' app app exception $e');
      var ex = exceptiionHandler.getException(e as Exception);
      if (ex.isUnAuthorizedException == true) {
        await appViewmodel.refreshTokenOrLogout(context, moveToLogin: true, showLoginMessage: true, redirectUrl: MembershipDetailsPage.routeName, redirectExtra: {MembershipDetailsPage.MEMBERSHIP_ID_KEY: membershipId});
      }
      exception.value = AppException(message: 'something went wrong', isMainError: false);
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToMembershipPayment(BuildContext context) async {
    if (!appViewmodel.isAuthenticated) {
      await appViewmodel.refreshTokenOrLogout(context, moveToLogin: true, showLoginMessage: true, redirectUrl: MembershipDetailsPage.routeName, redirectExtra: {MembershipDetailsPage.MEMBERSHIP_ID_KEY: membershipId});
      return;
    }
    MembershipPaymentPage.navigate(context, membershipId: membershipId);
  }

  void goBackToMembershipDetailsPage(BuildContext context) {
    appViewmodel.router.goBackToStack(context, MembershipDetailsPage.routeName);
  }
}
