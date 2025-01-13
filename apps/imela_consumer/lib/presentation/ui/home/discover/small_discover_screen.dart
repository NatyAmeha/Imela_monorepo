import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/bundle/components/bundle_list_item.dart';
import 'package:imela/presentation/ui/business/component/business_list_tile.dart';
import 'package:imela/presentation/ui/home/components/feature_promo_banner.dart';
import 'package:imela/presentation/ui/home/home_page.viewmodel.dart';
import 'package:imela/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:imela/presentation/ui/product/components/product_item_badge.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela/presentation/ui/shared/list/list_header.dart';

class SmallDiscoverScreen extends StatelessWidget {
  final HomepageViewmodel homepageViewmodel;
  final WidgetFactory widgetFactory;
  final Widget? scaffoldScreen;
  const SmallDiscoverScreen({super.key, required this.homepageViewmodel, required this.widgetFactory, this.scaffoldScreen});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await homepageViewmodel.getBrowseData(fetchPolicy: ApiDataFetchPolicy.networkOnly);
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Obx(
              () => Column(
                children: [
                  const SizedBox(height: 24),
                  FeaturePromoBannerList(
                    promoCardData: homepageViewmodel.getAppFeaturesBannerData(),
                    widgetFactory: widgetFactory,
                    height: 230,
                    controller: homepageViewmodel.featureBannerPageController,
                  ),
                  ...homepageViewmodel.sequenceOneBusinessResponse.map(
                    (businessResponse) {
                      return AppListView<Business>(
                        header: ListHeader(
                            widgetFactory: widgetFactory,
                            title: businessResponse.title,
                            subtitle: businessResponse.subtitle,
                            action: IconButton(
                              onPressed: () {
                                homepageViewmodel.navigateToBusinessListPage(context);
                              },
                              icon: const Icon(Icons.arrow_forward_ios_rounded),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        scrollDirection: Axis.horizontal,
                        controller: homepageViewmodel.businessListController,
                        shrinkWrap: true,
                        height: 250,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        itemBuilder: (context, business, index) {
                          return BusinessListTile(
                            business: business,
                            width: 250,
                            widgetFactory: widgetFactory,
                            imageHeight: 110,
                            onTap: () {
                              homepageViewmodel.navigateToBusinessDetailPage(context, business, previousPage: this);
                            },
                          );
                        },
                      ).showIfTrue(homepageViewmodel.businessListController.items.isNotEmpty);
                    },
                  ),
                  const SizedBox(height: 24),
                  ...homepageViewmodel.sequenceOneProductResponse.map(
                    (productResponse) {
                      return AppGridView<Product>(
                        header: ListHeader(
                          widgetFactory: widgetFactory,
                          title: productResponse.title ?? '',
                          subtitle: productResponse.subtitle,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          action: IconButton(
                            onPressed: () {
                              homepageViewmodel.navigateToProductListPage(context, products: productResponse.items, title: productResponse.title);
                            },
                            icon: const Icon(Icons.keyboard_arrow_right),
                          ),
                        ),
                        controller: homepageViewmodel.sequenceZeroproductListController,
                        primary: false,
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        isStaggered: true,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemBuilder: (context, productData, index) {
                          return GridProductListItem(
                            product: productData,
                            imageHeight: 150,
                            imageWidth: double.infinity,
                            widgetFactory: widgetFactory,
                            badgeInfos: ProductBadgeInfo.getProductBadgeInfo(productData),
                            discounts: productData.getBusinessDiscounts(),
                            onTap: () {
                              homepageViewmodel.navigateToProductDetailPage(context, productData);
                            },
                          );
                        },
                      ).showIfTrue(homepageViewmodel.sequenceZeroproductListController.items.isNotEmpty);
                    },
                  ),
                  const SizedBox(height: 24),
                  ...homepageViewmodel.bundleResponse.map(
                    (bundleResponse) {
                      return AppListView(
                        header: ListHeader(
                          widgetFactory: widgetFactory,
                          title: bundleResponse.title,
                          subtitle: bundleResponse.subtitle,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          action: IconButton(
                            onPressed: () {
                              homepageViewmodel.navigateToBundleListPage(context, bundles: bundleResponse.items, title: bundleResponse.title);
                            },
                            icon: const Icon(Icons.arrow_forward_ios_rounded),
                          ),
                        ),
                        scrollDirection: Axis.horizontal,
                        controller: homepageViewmodel.bundleListController,
                        shrinkWrap: true,
                        height: 200,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        itemBuilder: (context, bundle, index) {
                          return BundleListItem(
                            bundleData: bundle,
                                                    remainingTime: homepageViewmodel.getBundleRemainingTime(bundle),

                            width: 300,
                            widgetFactory: widgetFactory,
                            onTap: () {
                              homepageViewmodel.moveToBundleDetailPage(context, bundle, previousPage: scaffoldScreen);
                            },
                          );
                        },
                      ).showIfTrue(homepageViewmodel.bundleListController.items.isNotEmpty);
                    },
                  ),
                  const SizedBox(height: 124),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
