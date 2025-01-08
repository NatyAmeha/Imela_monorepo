import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/bundle/bundle_detail/bundle_detail.page.dart';
import 'package:imela/presentation/ui/bundle/bundle_list/bundle_list_page.dart';
import 'package:imela/presentation/ui/business/business_details.page.dart';
import 'package:imela/presentation/ui/business/business_list/business_list_page.dart';
import 'package:imela/presentation/ui/cart/cart_list_page.dart';
import 'package:imela/presentation/ui/home/foryou/foryou.page.dart';
import 'package:imela/presentation/ui/home/home.page.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.page.dart';
import 'package:imela/presentation/ui/product/product_list/product_list_page.dart';
import 'package:imela/presentation/ui/profile/profile_page.dart';
import 'package:imela/presentation/utils/screen_size_utils.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/discovery/model/bundle_discovery.model.dart';
import 'package:imela_core/discovery/model/business_discovery.model.dart';
import 'package:imela_core/discovery/model/discovery_response.dart';
import 'package:imela_core/discovery/model/foryou_response.dart';
import 'package:imela_core/discovery/model/product_discovery.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_ui_kit/components/list/list_componenet.viewmodel.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';
import 'components/feature_promo_banner.dart';
import 'discover/discover.page.dart';
import 'package:imela_core/discovery/discovery.usecase.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

@injectable
class HomepageViewmodel extends GetxController with BaseViewmodel {
  final DiscoveryUsecase discoverUsecase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;

  // const
  static const FETCH_BROWSEDATA = 'FETCH_BROWSE_DATA';
  static const FETCH_FORYOU_DATA = 'FETCH_FORYOU_DATA';

  static HomepageViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<HomepageViewmodel>());
  }

  HomepageViewmodel({
    required this.discoverUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  Widget? page;

  // State variables
  var browseData = Rxn<DiscoveryResponse>();
  var forYouData = Rxn<ForYouResponse>();
  var isBrowseDataLoading = false.obs;
  var isForYouDataLoading = false.obs;
  var foryouPageException = Rxn<AppException>();
  var browsePageException = Rxn<AppException>();

  // Getters
  AppController get appviewmodel => AppController.getInstance;
  Map<int, List<ProductDiscoveryResponse>>? get browseProductsResponse => browseData.value?.productsResponse?.groupBy((response) => response.sequence ?? 0);

  List<ProductDiscoveryResponse> get sequenceOneProductResponse => browseProductsResponse?[0] ?? [];
  List<BundleDiscovery> get bundleResponse => browseData.value?.bundlesResponse ?? [];

  Map<int, List<BusinessDiscovery>>? get browseBusinessesResponse => browseData.value?.businessesResponse?.groupBy((response) => response.sequence ?? 0);
  List<BusinessDiscovery> get sequenceOneBusinessResponse => browseBusinessesResponse?[0] ?? [];
  final businessListController = Get.put(CustomListController<Business>(), tag: 'businessListController');

  // widget Controllers
  final persistentTabController = Rxn<PersistentTabController>();
  final sequenceZeroproductListController = Get.put(CustomListController<Product>(), tag: 'sequence1productListController');
  final sequence1productListController = Get.put(CustomListController<Product>(), tag: 'sequence2productListController');
  final bundleListController = Get.put(CustomListController<ProductBundle>(), tag: 'bundleListController');

  var destinations = <Destination>[].obs;


  @override
  void initViewmodel({Map<String, dynamic>? data}) async {
    final bool fetchBrowseData = data?.getOrElse(FETCH_BROWSEDATA, () => false) ?? false;
    final bool fetchForYouData = data?.getOrElse(FETCH_FORYOU_DATA, () => false) ?? false;
    if (data?['WIDGET'] != null) {
      page = data?['WIDGET'];
    }
    var context = data?['CONTEXT'] as BuildContext;

    listenToUserChanges(context);
    appviewmodel.getCurrentUser();
    
    if (fetchBrowseData) {
      await getBrowseData();
    }
    if (fetchForYouData) {
      await getForYouData(context);
    }
  }

  void listenToUserChanges(BuildContext context) {
    appviewmodel.loggedInUser.listen((value) {
      appviewmodel.getCurrentUser();
    });
  }

  Future<void> getDestinations(BuildContext context) async {
    final widgetFactory = appviewmodel.getWidgetFactory(context);
    destinations.value = [];
    await Future.delayed(const Duration(milliseconds: 50));
    persistentTabController.value = PersistentTabController(initialIndex: 0);
    destinations.value = [
      if (appviewmodel.loggedInUser.value != null) ...[
        Destination(title: 'Favorites', icon: widgetFactory.createIcon(materialIcon: Icons.favorite, cupertinoIcon: CupertinoIcons.heart), page: const ForYouPage()),
      ],
      Destination(title: 'Discover', icon: widgetFactory.createIcon(materialIcon: Icons.explore_sharp, cupertinoIcon: CupertinoIcons.home), page: BrowsePage(homepageViewmodel: this)),
      Destination(title: 'Cart', icon: widgetFactory.createIcon(materialIcon: Icons.shopping_cart, cupertinoIcon: CupertinoIcons.cart), page: CartListPage()),
      Destination(title: appviewmodel.loggedInUser.value?.username ?? 'Profile', icon: widgetFactory.createIcon(materialIcon: Icons.person, cupertinoIcon: CupertinoIcons.person), page: ProfilePage()),
    ];
    appviewmodel.reloadHomePageDestination(false);
  }

  // data operation

  Future<void> getBrowseData({ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    try {
      cleanupStateVariables();
      final response = await discoverUsecase.getDiscoveryDetails(fetchPolicy: fetchPolicy);
      if (response?.isBrowseDataFetchSuccessfull() == true) {
        browseData.value = response;
        sequenceZeroproductListController.setItems(sequenceOneProductResponse.map((e) => e.items).flatten().toList());
        sequence1productListController.setItems(browseProductsResponse?[1]?.map((e) => e.items).flatten().toList() ?? []);
        bundleListController.setItems(bundleResponse.map((bundleRes) => bundleRes.items).flatten().toList());
        businessListController.setItems(browseBusinessesResponse?[0]?.map((e) => e.items).flatten().toList() ?? []);
      }
    } catch (e) {
      print("exception ${e.toString()}");
      browsePageException.value = exceptiionHandler.getException(e as Exception);
    } finally {
      isBrowseDataLoading(false);
    }
  }

  Future<void> getForYouData(BuildContext context, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    try {
      cleanupForYouStateVariables();
      isForYouDataLoading.value = true;
      final response = await discoverUsecase.getForYouData(fetchPolicy: fetchPolicy);
      if (response?.isForYouDataFetchSuccessfull() == true) {
        forYouData.value = response;
        appviewmodel.setFavoriteBusinesses(response?.favoriteBusinesses ?? []);
      }
    } catch (e) {
      var ex = exceptiionHandler.getException(e as Exception);
      if (ex.isUnAuthorizedException == true) {
        await appviewmodel.refreshTokenOrLogout(context, moveToLogin: true, showLoginMessage: true, redirectUrl: HomePage.routeName);
        return;
      }
      foryouPageException.value = ex;
    } finally {
      isForYouDataLoading(false);
    }
  }

  final PageController featureBannerPageController = PageController();
  Timer? _autoScrollTimer;
  List<BannerData> getAppFeaturesBannerData() {
    return [
      BannerData(
        title: 'Online presense for your business',
        description: 'Create online store for your business and reach more customers, accept online orders and payments',
        imageUrl: 'https://www.shutterstock.com/image-vector/concept-online-shop-store-transfer-260nw-1066200437.jpg',
        backgroundColor: ColorManager.primary,
      ),
      BannerData(
        title: 'Membership and subscription',
        description: 'Create membership and subscription plans for your customers and increase your revenue and customer loyalty',
        imageUrl: 'https://www.shutterstock.com/image-photo/man-hand-showing-smartphone-mock-260nw-2322526537.jpg',
        backgroundColor: ColorManager.tertiary,
      ),
      BannerData(
        title: 'Create Loyal customers',
        description: 'Create loyalty programs and reward your customers for their loyalty and increase your repeat customers',
        imageUrl: 'https://www.shutterstock.com/image-vector/3d-discount-coupon-sale-banner-260nw-2040195605.jpg',
        backgroundColor: ColorManager.secondary,
      ),
    ];
  }

  void startAutoScrollFeatureBanner() {
    // _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
    //   if (featureBannerPageController.hasClients) {
    //     int nextPage = featureBannerPageController.page!.round() + 1;
    //     if (nextPage >= 3) {
    //       nextPage = 0;
    //     }
    //     featureBannerPageController.animateToPage(nextPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    //   }
    // });
  }

  void navigateToBusinessDetailPage(BuildContext context, Business business, {Widget? previousPage}) {
    BusinessDetailsPage.navigateToBusinessDetailPage(context, router, business);
  }

  void moveToBundleDetailPage(BuildContext context, ProductBundle bundle, {Widget? previousPage}) {
    BundleDetailPage.navigateToBundleDetailPage(context, router, bundle, previousPage: null);
  }

  void cleanupStateVariables() {
    browsePageException.value = null;
    isBrowseDataLoading.value = true;
    browseData.value = null;
  }

  void cleanupForYouStateVariables() {
    foryouPageException.value = null;
    isForYouDataLoading.value = true;
    forYouData.value = null;
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void navigateToProductDetailPage(BuildContext context, Product product) {
    ProductDetailPage.navigateBeta(context, product: product, discounts: product.getBusinessDiscounts());
  }

  void navigateToBundleDetailPage(BuildContext context, ProductBundle bundle) {
    BundleDetailPage.navigateToBundleDetailPage(context, router, bundle);
  }

  void navigateToProductListPage(BuildContext context, {required List<Product> products, required String title}) {
    ProductListPage.navigate(context, products: products, title: title);
  }

  void navigateToBundleListPage(BuildContext context, {required List<ProductBundle> bundles, required String title}) {
    BundleListPage.navigateTo(context, bundles: bundles, title: title);
  }

  void navigateToBusinessListPage(BuildContext context, {String? title}) {
    BusinessListPage.navigate(context, businesses: businessListController.items, title: title ?? 'Business List');
  }
}
