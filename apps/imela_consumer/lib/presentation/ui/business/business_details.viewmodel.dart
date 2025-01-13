import 'package:dartx/dartx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/app/app.dart';
import 'package:imela/app/app_constants.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/branch/component/business_branch_list_modal.dart';
import 'package:imela/presentation/ui/bundle/bundle_detail/bundle_detail.page.dart';
import 'package:imela/presentation/ui/business/business_section/business_section_page.dart';
import 'package:imela/presentation/ui/business/service_overview/service_overview_list_page.dart';
import 'package:imela/presentation/ui/cart/cart_detail_page.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_tier/loyalty_tier_page.dart';
import 'package:imela/presentation/ui/membership/membership_detail/membership_detail_page.dart';
import 'package:imela/presentation/ui/membership/membership_plan_list/membership_plan_list_page.dart';
import 'package:imela/presentation/ui/product/components/product_item_badge.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.page.dart';
import 'package:imela/presentation/ui/product/product_list/product_list_page.dart';
import 'package:imela/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/list_display_style.constants.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_core/business/business.usecase.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/business/model/business_response.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/business/model/service_overview.model.dart';
import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/loyalty/loyalty_usecase.dart';
import 'package:imela_core/membership/dto/membership_response.dart';
import 'package:imela_core/membership/membership_usecase.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/settings/setting_usecase.dart';
import 'package:imela_core/shared/components/language_selector.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_ui_kit/components/image/photo_viewer/photo_viewer.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/date_utils.dart';
import 'package:imela_utils/url/url_service.dart';
import 'package:injectable/injectable.dart';
import 'component/business_info.dart';
import 'package:imela_ui_kit/components/shared/download_app_banner.dart';

@injectable
class BusinessDetailsViewModel extends GetxController with BaseViewmodel {
  final BusinessUsecase businessUsecase;
  final LoyaltyUsecase loyaltyUsecase;
  final MembershipUseCase membershipUsecase;
  final IExceptiionHandler exceptiionHandler;
  final SettingUsecase settingUsecase;
  final IRoutingService router;

  BusinessDetailsViewModel({
    required this.businessUsecase,
    required this.loyaltyUsecase,
    required this.membershipUsecase,
    required this.settingUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  static BusinessDetailsViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<BusinessDetailsViewModel>());
  }

  late String businessId;
  AppController get appViewmodel => AppController.getInstance;

// widget controllers
  late TabController businessSectionTabControllers;
  ScrollController businessHeaderScrollController = ScrollController();

  // page state variables
  var isLoading = false.obs;
  var isSecondLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;

  var businessDetails = Rxn<BusinessResponse>();
  var selectedBranch = Rxn<Branch>();

  var isAppbarExpanded = true.obs;

  var preventBranchSelectedDialogFromDismissed = false;

  static const businessUiHeaderHeight = 170;

  // getters
  Business? get businessData => businessDetails.value?.business;
  List<ServiceOverview> get serviceOverviews => businessDetails.value?.business?.serviceOverviews?.sortedByDescending((element) => element.featured == true ? 1 : 0).toList() ?? [];
  List<BusinessSection> get sections => businessDetails.value?.business?.sections ?? [];
  List<Product> get featuredProducts => businessDetails.value?.products?.where((element) => element.featured == true).toList() ?? [];
  List<Branch> get businessBranches => businessDetails.value?.branches ?? [];
  String? alreadySelectedBranchId;
  String get selectedBranchName => selectedBranch.value?.name.localize(appViewmodel.selectedLanguage.name) ?? '';
  List<PaymentOption> get businessPaymentOption => businessData?.paymentOptions ?? [];
  List<Discount> get allDiscounts {
    final businessDiscounts = businessData?.discounts ?? [];
    final userMembershipDiscounts = appViewmodel.currentUserBusinessMembershipsDiscounts;
    return [...businessDiscounts, ...userMembershipDiscounts];
  }

  List<ProductBundle> get businessBundles => businessData?.bundles ?? [];

  LoyaltyResponse? get businessLoyaltyInfo => appViewmodel.selectedBusinessLoyaltyInfo.value;
  MembershipResponse? get businessMembershipInfo => appViewmodel.businessMembershipInfo.value;

  List<String> get categories => businessDetails.value?.business?.categories ?? [];
  @override
  void initViewmodel({Map<String, dynamic>? data}) async {
    Future.delayed(Duration.zero, () async {
      super.initViewmodel(data: data);
      businessId = data!['id'] as String;
      final context = data['context'] as BuildContext;
      final branches = data['branches'] as List<Branch>;
      alreadySelectedBranchId = appViewmodel.getSelectedBusinessBranchId(businessId);
      cleanupStateVariables();
      getBusinessDetails(context, businessId, branchId: alreadySelectedBranchId, branchListWithAddress: branches);
    });
  }

  void listenAppbarHeaderScroll() {
    businessHeaderScrollController.addListener(() {
      if (businessHeaderScrollController.offset > businessUiHeaderHeight) {
        isAppbarExpanded(false);
      } else if (businessHeaderScrollController.offset <= businessUiHeaderHeight) {
        isAppbarExpanded(true);
      }
    });
  }

  Future<void> getBusinessDetails(BuildContext context, String id, {String? branchId, List<Branch> branchListWithAddress = const []}) async {
    try {
      isLoading(true);
      if (branchListWithAddress.isNotEmpty && alreadySelectedBranchId == null) {
        final nearestBranch = await businessUsecase.getNearestBranch(branchListWithAddress);
        branchId = nearestBranch.id;
        selectedBranch.value = nearestBranch;
        appViewmodel.setSelectedBusinessBranchId(businessId, nearestBranch.id!);
      }
      final response = await businessUsecase.getBusinessDetails(id, branchId: branchId, fetchPolicy: ApiDataFetchPolicy.cacheFirst);
      if (response?.isBusinessDetailFetchSuccessfull() == true) {
        businessDetails.value = response;

        if (businessBranches.isNotEmpty && branchId == null) {
          final nearestBranch = await businessUsecase.getNearestBranch(businessBranches);
          alreadySelectedBranchId = nearestBranch.id;
          branchId = nearestBranch.id;
          selectedBranch.value = nearestBranch;
          await getBusinessDetails(context, id, branchId: selectedBranch.value?.id);
          return;
        } else {
          selectedBranch.value ??= businessBranches.firstWhereOrNull((element) => element.id == branchId);
        }

        appViewmodel.addDiscounts(allDiscounts, clearPrevious: true);
        isLoading(false);
        isSecondLoading(true);
        await appViewmodel.getCustomerBusinessLoyalty(context, businessId);
        await getMembershipPlans();
        await showDownloadAppBanner(context);
      } else {
        exception(AppException(message: 'Business not found'));
      }
    } catch (e) {
      print('exception $e');
      var ex = exceptiionHandler.getException(e as Exception);
      if (!ex.isUnAuthorizedException) {
        exception(ex);
      }
    } finally {
      isLoading(false);
      isSecondLoading(false);
      if (businessData != null) {
        await addBusinessToFavorite(businessData!);
      }
    }
  }

  Future<void> addBusinessToFavorite(Business business) async {
    try {
      if (appViewmodel.isBusinessInFavorite(business.id!)) {
        return;
      }
      final result = await businessUsecase.addBusinessToFavorites(businessId, business.name!);
      if (result?.success == true) {
        appViewmodel.setFavoriteBusinesses([...appViewmodel.favoriteBusinesses, business]);
      }
    } catch (ex) {
      print(ex);
    }
  }

  Future<void> selectBranch(BuildContext context, Branch? branch) async {
    if (branch != null) {
      appViewmodel.setSelectedBusinessBranchId(businessId, branch.id!);
      alreadySelectedBranchId = branch.id;
      selectedBranch.value = branch;
      await getBusinessDetails(context, businessId, branchId: branch.id);
    }
  }

  Future<void> getMembershipPlans() async {
    try {
      final result = await membershipUsecase.getBusinessMembershipPlans(businessId);
      appViewmodel.setBusinessMembershipInfo(result);
    } catch (e) {
      print('exception $e');
    }
  }

  void showBusinessInfoDialog(BuildContext context, WidgetFactory widgetFactory) {
    widgetFactory.createModalBottomSheet(context, initialHeight: 1.0, content: (scrollController) {
      return BusinessInfoDialog(
        business: businessData!,
        branches: businessBranches,
        widgetFactory: widgetFactory,
        onEmailPressed: () {
          if (businessData!.email != null) {
            settingUsecase.launchUrl(businessData!.email!, type: UrlType.email);
          }
        },
        onPhonePressed: () {
          if (businessData!.phoneNumber != null) {
            settingUsecase.launchUrl(businessData!.phoneNumber!, type: UrlType.phone);
          }
        },
        onClose: () {
          router.goBack(context);
        },
      );
    });
  }

  Future<void> showDownloadAppBanner(BuildContext context) async {
    Future.delayed(
      const Duration(seconds: 5),
      () async {
        if (kIsWeb) {
          final dialogContent = ModalContent(
            title: const Text('Download App'),
            content: DownloadAppBanner(
              title: 'Get the best experience with our app',
              description: const [
                'Interact with your favorite businesses on the go with our mobile app.',
                'Get instant notification for best offers and discounts.',
                'Get exclusive deals and rewards just for being a member.',
                'Track your orders and manage your account with ease.',
              ],
              widgetFactory: appViewmodel.getWidgetFactory(context),
              onDownload: () {
                AppModalSheet.closeModal();
                settingUsecase.launchUrl(AppConstants.appDownloadUrl, type: UrlType.url);
              },
            ),
          );
          final isDownloadAppBannerShown = await settingUsecase.getIsDownloadAppBannerShown();
          final isBannerShown = (isDownloadAppBannerShown.firstWhereOrNull((t) => true))?.value ?? false;
          if (isBannerShown) {
            final downloadAppBannerShownDate = isDownloadAppBannerShown.lastOrNull?.value;
            final dateNow = DateTime.now();
            final bannerShownDate = DateTime.tryParse(downloadAppBannerShownDate ?? dateNow.toFormattedString()) ?? dateNow;
            final after24Hours = bannerShownDate.add(const Duration(days: 1));
            if (after24Hours.isBefore(dateNow)) {
              await AppModalSheet.showModal(context, type: AppModalSheetType.DIALOG, pages: [dialogContent]);
              await settingUsecase.setIsDownloadAppBannerShown(true);
            }
          } else {
            AppModalSheet.showModal(context, type: AppModalSheetType.DIALOG, pages: [dialogContent]);
            await settingUsecase.setIsDownloadAppBannerShown(true);
          }
        }
      },
    );
  }

  Future<void> showBusinessBranchSelectionModal(BuildContext context) async {
    await AppModalSheet.showModal(
      context,
      dimissable: false,
      type: AppModalSheetType.BOTTOMSHEET,
      onClose: (context) {
        if (selectedBranch.value != null) {
          AppModalSheet.closeModal();
        }
      },
      pages: [
        ModalContent(
          title: const Text('Select branch'),
          content: BusinessBranchListModal(
            selectedBranch: selectedBranch.value,
            branches: businessBranches,
            onBranchSelected: (newBranch) {
              selectBranch(context, newBranch);
              AppModalSheet.closeModal();
            },
          ),
        ),
      ],
    );
  }

  List<ProductBadgeInfo> getProductBadgeInfo(Product product) {
    var badgeInfos = <ProductBadgeInfo>[];
    if (product.isMembershipProduct) {
      badgeInfos.add(const ProductBadgeInfo(name: 'Membership', icon: Icons.card_membership));
    }
    return badgeInfos;
  }

  void showLoyaltyTierListPage(BuildContext context) {
    LoyaltyTierListPage.navigate(context, businessId: businessId);
  }

  void navigateToMembership(BuildContext context) {
    if (appViewmodel.currentUserIsMember(businessMembershipInfo?.membershipIds ?? [])) {
      if (businessMembershipInfo?.membershipIds.isNotEmpty == true) {
        MembershipDetailsPage.navigate(context, businessMembershipInfo!.membershipIds.first);
      } else {
        MembershipPlanListPage.navigate(context, businessId);
      }
    } else {
      MembershipPlanListPage.navigate(context, businessId);
    }
  }

  void navigateToFeaturedProductListPage(BuildContext context) {
    router.navigateTo(context, '${ProductListPage.baseRouteName}/featured', extra: {'title': 'Featured products', 'products': featuredProducts, 'displayStyle': ListDisplayStyle.List});
  }

  void navigateToAllProductsPage(BuildContext context) {
    router.navigateTo(context, '${ProductListPage.baseRouteName}/all', extra: {'title': 'All products', 'products': businessDetails.value?.products, 'displayStyle': ListDisplayStyle.Grid});
  }

  void navigateToCartDetailsPage(BuildContext context) {
    final selectedCart = appViewmodel.getCartByBusinessId(businessId);
    if (selectedCart == null) {
      appViewmodel.getWidgetFactory(context).showFlashMessage(context, message: 'No cart created for this business. Add products from this business first');
      return;
    }
    CartDetailPage.navigateToCartDetailPage(context, router, selectedCart);
  }

  // navigation helpers
  void navigateToProductDetails(BuildContext context, Product productInfo) {
    router.navigateTo(context, '/product/${productInfo.id!}', extra: {'name': productInfo.name?.localize('ENGLISH')});
    ProductDetailPage.navigate(context, router, productInfo, discounts: allDiscounts);
  }

  void navigateToBundleDetailPage(BuildContext context, ProductBundle bundle, {Widget? previousPage}) {
    BundleDetailPage.navigateToBundleDetailPage(context, router, bundle);
  }

  void navigateToBusinessSectionDetails(BuildContext context, BusinessSection section) {
    BusinessSectionPage.navigate(context, businessId, section: section);
  }

  void cleanupStateVariables() {
    isLoading(false);
    businessDetails.value = null;
    selectedBranch.value = null;
    exception.value = null;
    appViewmodel.setSelectedBusinessLoyaltyInfo(null);
    appViewmodel.setBusinessMembershipInfo(null);
  }

  @override
  void onClose() {
    super.onClose();
  }

  void showLanguageSelectorDialog(BuildContext context) {
    AppModalSheet.showModal(
      context,
      type: AppModalSheetType.BOTTOMSHEET,
      pages: [
        ModalContent(
          title: const Text(''),
          content: LanguageSelectorDialog(
            selectedLanguage: appViewmodel.selectedLanguageUpdated.value,
            onLanguageSelected: (value) {
              appViewmodel.updateLanguage(value, (locale) {
                MelegnaCustomerApp.of(context)?.setLocale(locale);
              });
              AppModalSheet.closeModal();
            },
          ),
        )
      ],
    );
  }

  Duration getBundleRemainingTime(ProductBundle bundle) {
    return DateHelper.getDateDifference(startDate: DateTime.now(), endDate: bundle.endDate);
  }

  void navigateToServiceOverviewDetails(BuildContext context, List<ServiceOverview> serviceOverviews) {
    ServiceOverviewListPage.navigate(context, serviceOverviews: serviceOverviews);
  }

  void navigateToPhotoViewerPage(BuildContext context, List<String> photoUrls, int startIndex) {
    PhotoViewerScreen.navigate(context, photoUrls, startIndex);
  }
}
