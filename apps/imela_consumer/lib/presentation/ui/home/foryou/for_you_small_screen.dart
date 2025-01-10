import 'package:flutter/material.dart';
import 'package:imela/l10n/l10n.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/bundle/components/bundle_list_item.dart';
import 'package:imela/presentation/ui/business/component/business_list_tile.dart';
import 'package:imela/presentation/ui/home/home_page.viewmodel.dart';
import 'package:imela/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:imela/presentation/ui/product/components/product_item_badge.dart';
import 'package:imela/presentation/ui/shared/list/list_header.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ForYouSmallScreen extends StatefulWidget {
  const ForYouSmallScreen({
    super.key,
  });

  @override
  State<ForYouSmallScreen> createState() => _ForYouSmallScreenState();
}

class _ForYouSmallScreenState extends State<ForYouSmallScreen> {
  late WidgetFactory widgetFactory;
  var homepageViewmodel = HomepageViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        homepageViewmodel.getForYouData(context, fetchPolicy: ApiDataFetchPolicy.networkOnly);
      },
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            homepageViewmodel.getForYouData(context, fetchPolicy: ApiDataFetchPolicy.networkOnly);
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  AppListView(
                    header: ListHeader(
                      widgetFactory: widgetFactory,
                      title: context.l10n.favoriteBusiness,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      action: IconButton(
                        onPressed: () {
                          homepageViewmodel.navigateToBusinessListPage(context);
                        },
                        icon: const Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                    scrollDirection: Axis.horizontal,
                    items: homepageViewmodel.forYouData.value?.favoriteBusinesses ?? [],
                    shrinkWrap: true,
                    height: 250,
                    padding: const EdgeInsets.only(right : 8),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (context, business, index) {
                      return BusinessListTile(
                        business: business,
                        width: 250,
                        widgetFactory: widgetFactory,
                        imageHeight: 125,
                        onTap: () {
                          homepageViewmodel.navigateToBusinessDetailPage(context, business);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildBundleSection(context),
                  const SizedBox(height: 24),
                  _buildProductSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBundleSection(BuildContext context) {
    final bundles = homepageViewmodel.forYouData.value?.bundles ?? [];
    return Column(
      children: bundles.map((bundle) {
        return AppListView(
          header: ListHeader(
            widgetFactory: widgetFactory,
            title: bundle.title,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            action: IconButton(
              onPressed: () {
                homepageViewmodel.navigateToBundleListPage(context, bundles: bundle.items, title: bundle.title);
              },
              icon: const Icon(Icons.arrow_forward_ios),
            ),
          ),
          scrollDirection: Axis.horizontal,
          items: bundle.items,
          shrinkWrap: true,
          height: 225,
          padding: const EdgeInsets.only(right: 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          itemBuilder: (context, bundle, index) {
            return BundleListItem(
              bundleData: bundle,
              widgetFactory: widgetFactory,
              width: 300,
              height: 250,
              onTap: () {
                homepageViewmodel.navigateToBundleDetailPage(context, bundle);
              },
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildProductSection(BuildContext context) {
    final topProducts = homepageViewmodel.forYouData.value?.topProductsByBusiness ?? [];
    return Column(
      children: topProducts.map((product) {
        if (product.items.isEmpty) return const SizedBox.shrink();
        return AppListView(
          header: ListHeader(
            widgetFactory: widgetFactory,
            title: product.title,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            action: IconButton(
              onPressed: () {
                homepageViewmodel.navigateToProductListPage(context, products: product.items, title: product.title);
              },
              icon: const Icon(Icons.keyboard_arrow_right),
            ),
          ),
          scrollDirection: Axis.horizontal,
          items: product.items,
          shrinkWrap: true,
          height: 300,
          width: MediaQuery.sizeOf(context).width,
          padding: const EdgeInsets.only(right: 8),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          itemBuilder: (context, product, index) {
            return SizedBox(
              width: 200,
              child: GridProductListItem(
                product: product,
                widgetFactory: widgetFactory,
                discounts: product.getBusinessDiscounts(),
                imageHeight: 125,
                badgeInfos: ProductBadgeInfo.getProductBadgeInfo(product),
                onTap: () {
                  homepageViewmodel.navigateToProductDetailPage(context, product);
                },
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
