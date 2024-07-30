import 'dart:collection';

import 'package:dartx/dartx.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/domain/bundle/model/product_bundle.model.dart';
import 'package:melegna_customer/domain/discovery/discovery.usecase.dart';
import 'package:melegna_customer/domain/discovery/model/bundle_discovery.model.dart';
import 'package:melegna_customer/domain/discovery/model/business_discovery.model.dart';
import 'package:melegna_customer/domain/discovery/model/discovery_response.dart';
import 'package:melegna_customer/domain/discovery/model/product_discovery.model.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/presentation/ui/bundle/bundle_detail/bundle_detail.page.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/home/discover/discover.page.dart';
import 'package:melegna_customer/presentation/ui/home/foryou.page.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';
import 'package:melegna_customer/presentation/utils/screen_size_utils.dart';
import 'package:melegna_customer/services/routing_service.dart';
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

  // State variables
  var browseData = Rxn<DiscoveryResponse>();
  var forYouData = Rxn<DiscoveryResponse>();
  var isBrowseDataLoading = false.obs;
  var isForYouDataLoading = false.obs;
  var exception = Rxn<AppException>();

  // Getters
  Map<int, List<ProductDiscoveryResponse>>? get browseProductsResponse => browseData.value?.productsResponse?.groupBy((response) => response.sequence ?? 0);
  Map<int, List<BusinessDiscovery>>? get browseBusinessesResponse => browseData.value?.businessesResponse?.groupBy((response) => response.sequence ?? 0);

  List<ProductDiscoveryResponse> get sequenceOneProductResponse => browseProductsResponse?[0] ?? [];
  List<BundleDiscovery> get bundleResponse => browseData.value?.bundlesResponse ?? [];

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
      Destination(title: 'For You', icon: widgetFactory.createIcon(materialIcon: Icons.search, cupertinoIcon: CupertinoIcons.search), page: ForYouPage()),
    ];
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) async {
    final bool fetchBrowseData = data?.getOrElse(FETCH_BROWSEDATA, () => false) ?? false;
    final bool fetchForYouData = data?.getOrElse(FETCH_FORYOU_DATA, () => false) ?? false;
    if (fetchBrowseData) {
      await getBrowseData();
      if (browseData.value != null) {
        sequenceZeroproductListController.setItems(sequenceOneProductResponse.map((e) => e.items).flatten().toList());
        sequence1productListController.setItems(browseProductsResponse?[1]?.map((e) => e.items).flatten().toList() ?? []);
        bundleListController.setItems(bundleResponse.map((bundleRes) => bundleRes.items).flatten().toList());
      }
    }
  }

  // data operation

  Future<void> getBrowseData() async {
    isBrowseDataLoading.value = true;
    try {
      final response = await discoverUsecase.getDiscoveryDetails();
      if (response == null) {
        exception(AppException(message: 'No data found'));
      }
      browseData.value = response;
    } catch (e) {
      exception.value = exceptiionHandler.getException(e as Exception);
    } finally {
      isBrowseDataLoading.value = false;
    }
  }

  navigateToBusinessDetailPage(BuildContext context, String businessId) {
    Navigator.of(context).pushNamed('/business/$businessId');
  }

  void moveToBundleDetailPage(BuildContext context, ProductBundle bundle, {Widget? previousPage}) {
    BundleDetailPage.navigateToBundleDetailPage(context, router, bundle, previousPage: previousPage);
  }
}
