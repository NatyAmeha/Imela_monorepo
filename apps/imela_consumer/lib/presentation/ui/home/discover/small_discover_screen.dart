import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/bundle/components/bundle_list_item.dart';
import 'package:imela/presentation/ui/business/component/business_list_tile.dart';
import 'package:imela/presentation/ui/home/components/feature_promo_banner.dart';
import 'package:imela/presentation/ui/home/home_page.viewmodel.dart';
import 'package:imela/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.page.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

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
          await homepageViewmodel.getBrowseData();
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
                      return AppListView(
                        // header: AppListHeader(
                        //   title: businessResponse.title,
                        //   subtitle: businessResponse.subtitle,
                        //   onActionClicked: () {},
                        //   padding: const EdgeInsets.all(16),
                        // ),
                        scrollDirection: Axis.horizontal,
                        controller: homepageViewmodel.businessListController,
                        shrinkWrap: true,
                        height: 250,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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
                        // header: AppListHeader(
                        //   title: productResponse.title ?? '',
                        //   subtitle: productResponse.subtitle,
                        //   padding: const EdgeInsets.symmetric(horizontal: 16),
                        //   onActionClicked: () {},
                        // ),
                        controller: homepageViewmodel.sequenceZeroproductListController,
                        primary: false,
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        isStaggered: true,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        itemBuilder: (context, productData, index) {
                          return GridProductListItem(
                            product: productData,
                            imageHeight: 150,
                            imageWidth: double.infinity,
                            widgetFactory: widgetFactory,
                            onTap: () {
                              ProductDetailPage.navigate(context, homepageViewmodel.router, productData, previousPage: this);
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
                        // header: AppListHeader(
                        //   title: bundleResponse.title,
                        //   subtitle: bundleResponse.subtitle,
                        //   padding: const EdgeInsets.all(16),
                        //   trailing: widgetFactory.createIcon(materialIcon: Icons.arrow_forward_ios, cupertinoIcon: CupertinoIcons.chevron_right),
                        //   onActionClicked: () {},
                        // ),
                        scrollDirection: Axis.horizontal,
                        controller: homepageViewmodel.bundleListController,
                        shrinkWrap: true,
                        height: 200,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        itemBuilder: (context, bundle, index) {
                          return BundleListItem(
                            bundleData: bundle,
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
