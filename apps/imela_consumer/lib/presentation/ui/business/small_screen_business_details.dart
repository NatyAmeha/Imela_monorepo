import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/bundle/components/bundle_list_item.dart';
import 'package:imela/presentation/ui/business/component/business_loyalty_banner.dart';
import 'package:imela/presentation/ui/business/component/business_section_list_item.dart';
import 'package:imela/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:imela/presentation/ui/shared/discount/business_discount_card.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

import 'business_details.viewmodel.dart';
import 'component/business_details_header.componenet.dart';

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
    final businessDescription = viewmodel.businessData?.description;

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
            actions: [
              appWidgetFactory.createIcon(
                materialIcon: Icons.shopping_cart,
                onPressed: () {
                  viewmodel.navigateToCartDetailsPage(context);
                },
              )
            ],
            toolbarHeight: 60,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              expandedTitleScale: 1.0,
              background: Obx(
                () => BusinessDetailsHeader(
                  business: viewmodel.businessData!,
                  width: double.infinity,
                  height: 150,
                  selectedLanguage: viewmodel.appViewmodel.selectedLanguageUpdated.value,
                  controller: PageController(initialPage: 0),
                  onLanguageSelected: () {
                    viewmodel.showLanguageSelectorDialog(context);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
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
                        if (viewmodel.allDiscounts.isNotEmpty) ...[
                          Obx(
                            () => BusinessDiscountCard(
                              discounts: viewmodel.allDiscounts,
                              selectedCurrency: viewmodel.appViewmodel.selectedCurrency.name,
                              selectedLanguage: viewmodel.appViewmodel.selectedLanguage.name,
                              onDiscountSelected: (discount) {},
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        AppGridView(
                          shrinkWrap: true,
                          items: viewmodel.sections,
                          itemExtent: 100,
                          crossAxisCount: Responsive.getGridCount(context, itemWidth: 100),
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                          itemBuilder: (context, section, index) {
                            return BusinessSectionListItem(
                              businessSection: section,
                              widgetFactory: appWidgetFactory,
                              selectedLanguage: viewmodel.appViewmodel.selectedLanguage.name,
                              onTap: () {
                                viewmodel.navigateToBusinessSectionDetails(context, section);
                              },
                            );
                          },
                        ),
                        appWidgetFactory.createText(context, businessDescription.localize('ENGLISH'), style: Theme.of(context).textTheme.labelMedium, maxLines: 3, overflow: TextOverflow.ellipsis).showIfTrue(businessDescription?.isNotEmpty == true),
                        const SizedBox(height: 16),
                        // const BusinessAddressQuickActionComponenet(),
                        // const SizedBox(height: 16),
                        appWidgetFactory.createButton(
                            context: context,
                            content: const Text('Get more info'),
                            style: AppButtonStyle.outlinedButtonStyle(context, borderRadius: 32, padding: const EdgeInsets.all(4)),
                            onPressed: () {
                              viewmodel.showBusinessInfoDialog(context, appWidgetFactory);
                            }),
                      ],
                    ),
                  ),
                  AppListView<ProductBundle>(
                    header: appWidgetFactory.createText(context, 'Bundles', style: Theme.of(context).textTheme.titleMedium),
                    scrollDirection: Axis.horizontal,
                    items: viewmodel.businessBundles,
                    shrinkWrap: true,
                    height: 230,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (context, bundle, index) {
                      return BundleListItem(
                        bundleData: bundle,
                        remainingTime: viewmodel.getBundleRemainingTime(bundle),
                        width: 310,
                        widgetFactory: appWidgetFactory,
                        onTap: () {
                          viewmodel.navigateToBundleDetailPage(context, bundle);
                        },
                      );
                    },
                  ).showIfTrue(viewmodel.businessBundles.isNotEmpty),
                  const SizedBox(height: 24),
                  AppGridView(
                    header: appWidgetFactory.createText(context, 'Featured products', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.start),

                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: viewmodel.featuredProducts,
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    primary: false,
                    isStaggered: true,
                    // header: AppListHeader(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16),
                    //   title: 'Featured Products',
                    //   subtitle: 'View all fetured products from this business',
                    //   trailing: appWidgetFactory.createIcon(materialIcon: Icons.arrow_forward_ios, color: Theme.of(context).primaryColor, backgroundColor: Theme.of(context).colorScheme.primaryContainer, padding: const EdgeInsets.all(8)),
                    //   onActionClicked: () {
                    //     viewmodel.navigateToFeaturedProductListPage(context);
                    //   },
                    // ),
                    itemBuilder: (context, productData, index) {
                      return GridProductListItem(
                          product: productData,
                          imageHeight: 150,
                          imageWidth: double.infinity,
                          widgetFactory: appWidgetFactory,
                          badgeInfos: viewmodel.getProductBadgeInfo(productData),
                          discounts: viewmodel.allDiscounts,
                          onTap: () {
                            viewmodel.navigateToProductDetails(context, productData);
                          });
                    },
                  ),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
          Obx(
            () => Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Column(
                children: [
                  BusinessLoyaltyBanner(
                    loyaltyInfo: viewmodel.businessLoyaltyInfo,
                    loyaltyProgramName: viewmodel.businessLoyaltyProgramName,
                    membershipInfo: viewmodel.businessMembershipInfo,
                    onLoyaltCardClicked: () {
                      viewmodel.showLoyaltyProgramDetailModel(context);
                    },
                    onMembershipCardClicked: () {
                      viewmodel.navigateToMembership(context);
                    },
                  ),
                  if (viewmodel.selectedBranch.value != null)
                    appWidgetFactory.createCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Colors.white,
                      borderRadius: BorderRadius.zero,
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(
                              () => Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  appWidgetFactory.createText(context, 'Selected branch', style: Theme.of(context).textTheme.bodySmall),
                                  appWidgetFactory.createText(context, viewmodel.selectedBranchName, style: Theme.of(context).textTheme.titleSmall),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          appWidgetFactory.createButton(
                            context: context,
                            content: const Text('Change'),
                            style: AppButtonStyle.textButtonStyle(context),
                            onPressed: () {
                              viewmodel.showBusinessBranchSelectionModal(context);
                            },
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
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
}
