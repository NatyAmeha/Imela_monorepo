import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/bundle/bundle_detail/bundle_detail.page.dart';
import 'package:imela/presentation/ui/business/business_details.page.dart';
import 'package:imela/presentation/ui/cart/cart_list_page.dart';
import 'package:imela/presentation/ui/order/order_list/order_list_page.dart';
import 'package:imela/presentation/ui/shared/base_viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:imela/presentation/utils/screen_size_utils.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/discovery/model/bundle_discovery.model.dart';
import 'package:imela_core/discovery/model/business_discovery.model.dart';
import 'package:imela_core/discovery/model/discovery_response.dart';
import 'package:imela_core/discovery/model/product_discovery.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';
import 'components/feature_promo_banner.dart';
import 'discover/discover.page.dart';
import 'foryou.page.dart';
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

  HomepageViewmodel({
    required this.discoverUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  Widget? page;

  // State variables
  var browseData = Rxn<DiscoveryResponse>();
  var forYouData = Rxn<DiscoveryResponse>();
  var isBrowseDataLoading = false.obs;
  var isForYouDataLoading = false.obs;
  var exception = Rxn<AppException>();

  // Getters
  Map<int, List<ProductDiscoveryResponse>>? get browseProductsResponse => browseData.value?.productsResponse?.groupBy((response) => response.sequence ?? 0);

  List<ProductDiscoveryResponse> get sequenceOneProductResponse => browseProductsResponse?[0] ?? [];
  List<BundleDiscovery> get bundleResponse => browseData.value?.bundlesResponse ?? [];

  Map<int, List<BusinessDiscovery>>? get browseBusinessesResponse => browseData.value?.businessesResponse?.groupBy((response) => response.sequence ?? 0);
  List<BusinessDiscovery> get sequenceOneBusinessResponse => browseBusinessesResponse?[0] ?? [];
  final businessListController = Get.put(CustomListController<Business>(), tag: 'businessListController');

  // widget Controllers
  PersistentTabController persistentTabController = PersistentTabController(initialIndex: 0);
  final sequenceZeroproductListController = Get.put(CustomListController<Product>(), tag: 'sequence1productListController');
  final sequence1productListController = Get.put(CustomListController<Product>(), tag: 'sequence2productListController');
  final bundleListController = Get.put(CustomListController<ProductBundle>(), tag: 'bundleListController');

  List<Destination> getDistinations(BuildContext context) {
    final platform = Theme.of(context).platform;
    final widgetFactory = WidgetFactory(platform);
    widgetFactory.createIcon(materialIcon: Icons.home, cupertinoIcon: CupertinoIcons.home);
    return [
      Destination(
          title: 'Home',
          icon: widgetFactory.createIcon(materialIcon: Icons.home, cupertinoIcon: CupertinoIcons.home),
          page: BrowsePage(
            homepageViewmodel: this,
          )),
      Destination(title: 'For You', icon: widgetFactory.createIcon(materialIcon: Icons.search, cupertinoIcon: CupertinoIcons.search), page: const ForYouPage()),
      Destination(title: 'Cart', icon: widgetFactory.createIcon(materialIcon: Icons.shopping_cart, cupertinoIcon: CupertinoIcons.cart), page: CartListPage()),
      Destination(title: 'Orders', icon: widgetFactory.createIcon(materialIcon: Icons.paid, cupertinoIcon: CupertinoIcons.paw_solid), page: OrderListPage()),
    ];
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) async {
    final bool fetchBrowseData = data?.getOrElse(FETCH_BROWSEDATA, () => false) ?? false;
    final bool fetchForYouData = data?.getOrElse(FETCH_FORYOU_DATA, () => false) ?? false;
    if (data?['WIDGET'] != null) {
      page = data?['WIDGET'];
    }
    if (fetchBrowseData) {
      await getBrowseData();
    }
  }

  // data operation

  Future<void> getBrowseData() async {
    try {
      cleanupStateVariables();
      final response = await discoverUsecase.getDiscoveryDetails();
      if (response?.isBrowseDataFetchSuccessfull() == true) {
        browseData.value = response;
        sequenceZeroproductListController.setItems(sequenceOneProductResponse.map((e) => e.items).flatten().toList());
        sequence1productListController.setItems(browseProductsResponse?[1]?.map((e) => e.items).flatten().toList() ?? []);
        bundleListController.setItems(bundleResponse.map((bundleRes) => bundleRes.items).flatten().toList());
        businessListController.setItems(browseBusinessesResponse?[0]?.map((e) => e.items).flatten().toList() ?? []);
      }
    } catch (e) {
      print("exception ${e.toString()}");
      exception.value = exceptiionHandler.getException(e as Exception);
    } finally {
      isBrowseDataLoading(false);
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
    BusinessDetailsPage.navigateToBusinessDetailPage(context, router, business, previousPage: null);
  }

  void moveToBundleDetailPage(BuildContext context, ProductBundle bundle, {Widget? previousPage}) {
    BundleDetailPage.navigateToBundleDetailPage(context, router, bundle, previousPage: null);
  }


  void cleanupStateVariables() {
    exception.value = null;
    isBrowseDataLoading.value = true;
    browseData.value = null;
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    super.dispose();
  }
}
