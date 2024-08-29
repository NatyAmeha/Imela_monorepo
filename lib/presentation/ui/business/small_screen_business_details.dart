import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/domain/bundle/model/product_bundle.model.dart';
import 'package:imela/domain/shared/list_header.component.dart';
import 'package:imela/domain/shared/localized_field.model.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/bundle/components/bundle_list_item.dart';
import 'package:imela/presentation/ui/business/business_details.viewmodel.dart';
import 'package:imela/presentation/ui/business/component/business_details_header.componenet.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:imela/presentation/ui/shared/app_tabview.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela/presentation/utils/button_style.dart';
import 'package:imela/presentation/utils/localization_utils.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';

class BusinessDetailsSmallScreen extends StatefulWidget {
  final BusinessDetailsViewModel businessDetailsViewmodel;
  final String? businessName;
  const BusinessDetailsSmallScreen({super.key, required this.businessDetailsViewmodel, this.businessName});

  @override
  State<BusinessDetailsSmallScreen> createState() => _BusinessDetailsSmallScreenState();
}

class _BusinessDetailsSmallScreenState extends State<BusinessDetailsSmallScreen> with SingleTickerProviderStateMixin {
  late TabController controller;
  late WidgetFactory appWidgetFactory;

  BusinessDetailsViewModel get viewmodel => widget.businessDetailsViewmodel;

  @override
  void initState() {
    super.initState();
    viewmodel.assignTabController(viewmodel.sectionsWithProductsControllers.keys.length, this);
    viewmodel.listenAppbarHeaderScroll();
  }

  @override
  Widget build(BuildContext context) {
    appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return NestedScrollView(
      controller: viewmodel.businessHeaderScrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        Obx(
          () => SliverAppBar(
            expandedHeight: 225,
            collapsedHeight: 60,
            pinned: true,
            title: viewmodel.isAppbarExpanded.value ? null : Text('${viewmodel.businessData?.getLocalizedBusinessName(AppLanguage.ENGLISH.name)}'),
            floating: false,
            backgroundColor: ColorManager.alternate,
            automaticallyImplyLeading: false,
            leading: appWidgetFactory.createIcon(
              materialIcon: Icons.arrow_back_ios,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            actions: const [],
            toolbarHeight: 60,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              expandedTitleScale: 1.0,
              background: BusinessDetailsHeader(
                business: viewmodel.businessData!,
                width: double.infinity,
                height: 150,
                controller: PageController(initialPage: 0),
              ),
            ),
            bottom: viewmodel.isAppbarExpanded.value ? null : TabBar(controller: viewmodel.businessSectionTabControllers, tabs: viewmodel.getBusinessSectionTabs()),
          ),
        ),
      ],
      body: AppTabView(
        tabs: viewmodel.getBusinessSectionTabs(),
        controller: viewmodel.businessSectionTabControllers,
        tabViews: viewmodel.sectionsWithProductsControllers.entries.map((entry) {
          if (entry.key == 'Overview') {
            return buildBusinessOverview(appWidgetFactory);
          }
          return SingleChildScrollView(
            primary: true,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: AppGridView(
              items: entry.value.items,
              crossAxisCount: 2,
              shrinkWrap: true,
              isStaggered: true,
              mainAxisSpacing: 16,
              primary: false,
              itemBuilder: (context, productData, index) {
                return GridProductListItem(
                  product: productData,
                  imageHeight: 150,
                  imageWidth: double.infinity,
                  widgetFactory: appWidgetFactory,
                  onTap: () {
                    viewmodel.navigateToProductDetails(context, productData);
                  },
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('business details dispose');
    }
    viewmodel.dispose();
    super.dispose();
  }

  Widget buildBusinessOverview(WidgetFactory widgetFactory) {
    final businessDescription = viewmodel.businessData?.description;
    return SingleChildScrollView(
      primary: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          appWidgetFactory.createCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                appWidgetFactory.createText(context, businessDescription.localize(), style: Theme.of(context).textTheme.labelMedium, maxLines: 3, overflow: TextOverflow.ellipsis).showIfTrue(businessDescription?.isNotEmpty == true),
                const SizedBox(height: 16),
                // const BusinessAddressQuickActionComponenet(),
                // const SizedBox(height: 16),
                widgetFactory.createButton(
                    context: context,
                    content: const Text('Get more info'),
                    style: AppButtonStyle.outlinedButtonStyle(context, borderRadius: 32, padding: const EdgeInsets.all(4)),
                    onPressed: () {
                      viewmodel.showBusinessInfoDialog(context, widgetFactory);
                    }),
                
              ],
            ),
          ),
          AppListView<ProductBundle>(
            header: AppListHeader(
              title: 'Bundles',
              padding: const EdgeInsets.all(16),
              trailing: widgetFactory.createIcon(materialIcon: Icons.arrow_forward_ios, cupertinoIcon: CupertinoIcons.chevron_right),
              onActionClicked: () {},
            ),
            scrollDirection: Axis.horizontal,
            items: viewmodel.businessBundles,
            shrinkWrap: true,
            height: 225,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, bundle, index) {
              return BundleListItem(
                bundleData: bundle,
                width: 300,
                widgetFactory: widgetFactory,
                onTap: () {
                  viewmodel.navigateToBundleDetailPage(context, bundle);
                },
              );
            },
          ).showIfTrue(viewmodel.businessBundles.isNotEmpty),
          const SizedBox(height: 24),
          AppGridView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            items: viewmodel.featuredProducts,
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            primary: false,
            isStaggered: true,
            header: AppListHeader(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              title: 'Featured Products',
              subtitle: 'View all fetured products from this business',
              trailing: appWidgetFactory.createIcon(materialIcon: Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, backgroundColor: Theme.of(context).colorScheme.primaryContainer, padding: const EdgeInsets.all(8)),
              onActionClicked: () {
                viewmodel.navigateToFeaturedProductListPage(context);
              },
            ),
            itemBuilder: (context, productData, index) {
              return GridProductListItem(
                  product: productData,
                  imageHeight: 150,
                  imageWidth: double.infinity,
                  widgetFactory: widgetFactory,
                  onTap: () {
                    viewmodel.navigateToProductDetails(context, productData);
                  });
            },
          ),
          widgetFactory.createButton(
            context: context,
            content: const Text('View all products'),
            style: AppButtonStyle.outlinedButtonStyle(context),
            onPressed: () {
              viewmodel.navigateToAllProductsPage(context);
            },
          ).withPaddingAll(16),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
