import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/cart/component/cart_list_component.dart';
import 'package:imela_pos/ui/home/component/cart_bottom_nav.dart';
import 'package:imela_pos/ui/home/component/home_page_navbar.dart';
import 'package:imela_pos/ui/home/component/home_page_sidenav.dart';
import 'package:imela_pos/ui/home/component/home_product_list_item.dart';
import 'package:imela_pos/ui/home/home_page.viewmodel.dart';
import 'package:imela_pos/ui/search/search_list_page.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  static void navigate(BuildContext context, {bool replace = false, bool toBackStack = false}) {
    final router = AppViewmodel.getInstance().appRouter;
    if (toBackStack) {
      router.goNamed(context, routeName);
    } else {
      router.navigateTo(context, routeName, replace: replace);
    }
  }
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  var viewmodel = HomePageViewmodel.getInstance();
  var selectedLanguage = AppViewmodel.getInstance().selectedLanguage;
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewmodel.initViewmodel(data: {'tickerProvider': this, 'context': context});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = viewmodel.getDestinations(context);
    return Scaffold(
      drawer: HomePageSidenav(
        selectedIndex: 0,
        destinations: destinations,
        onDestinationSelected: (index) {
          destinations[index].onTap?.call();
        },
      ),
      body: SafeArea(
        child: Obx(
          () => PageContentLoader(
            showContent: viewmodel.selectedBranch != null,
            isLoading: viewmodel.isLoading.value || viewmodel.cartViewmodel.isLoading.value,
            content: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: NestedScrollView(
                        controller: viewmodel.businessHeaderScrollController,
                        headerSliverBuilder: (context, innerBoxIsScrolled) => [
                          SliverAppBar(
                            pinned: true,
                            expandedHeight: Responsive.getHeight(context, small: 60, medium: 70, large: 75),
                            collapsedHeight: Responsive.getHeight(context, small: 60, medium: 70, large: 75),
                            flexibleSpace: FlexibleSpaceBar(
                              background: Obx(
                                () => HomePageNavbar(
                                  branchName: viewmodel.selectedBranch!.name.localize(selectedLanguage),
                                  businessName: viewmodel.businessName ?? '',
                                  staff: viewmodel.appViewmodel.loggedInStaffInfo.value?.staff,
                                  controller: viewmodel.searchController,
                                  selectedSectionId: viewmodel.selectedSectionId,
                                  selectedLanguage: selectedLanguage,
                                  onSync: () {
                                    viewmodel.syncPOS(context);
                                  },
                                  onSearchClicked: () {
                                    SearchListPage.navigate(context);
                                  },
                                  onLogout: () {
                                    viewmodel.appViewmodel.logout(context, showLogoutPopup: true);
                                  },
                                ),
                              ),
                            ),
                            bottom: PreferredSize(
                              preferredSize: Size(MediaQuery.sizeOf(context).width, 40),
                              child: Row(
                                children: [
                                  _buildSectionSelector(),
                                  Expanded(
                                    child: TabBar(tabAlignment: TabAlignment.start, controller: viewmodel.businessSectionTabControllers, tabs: viewmodel.geCategoryTabs(), isScrollable: true, padding: EdgeInsets.zero),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                        body: Row(
                          children: [
                            Expanded(
                              child: AppGridView(
                                padding: Responsive.paddingSymetric(context, smallHorizontal: 6),
                                items: viewmodel.getProductsByCategoryAndSection,
                                itemExtent: 250,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                crossAxisCount: Responsive.getGridCount(context, itemWidth: Responsive.isSmallScreen(context) ? 150 : 270),
                                itemBuilder: (context, product, index) {
                                  return HomeProductListItem(
                                    widgetFactory: widgetFactory,
                                    product: product,
                                    badgeInfos: product.getBadgeInfos(forPOS: true),
                                    selectedCurrency: viewmodel.appViewmodel.selectedCurrency,
                                    imageHeight: 150,
                                    onTap: () {
                                      viewmodel.addProductToCartOrUpdateQty(context, product: product);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (Responsive.isLargeScreen(context))
                      const Expanded(
                        flex: 2,
                        child: CartListPage(width: 300),
                      )
                  ],
                ),
                if (Responsive.isSmallScreen(context))
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CartBottomNav(
                      totalAmountString: viewmodel.cartTotalAmount,
                      totalItemsString: viewmodel.cartTotalItems,
                      onTap: () {
                        viewmodel.navigateToCartPage(context);
                      },
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionSelector() {
    final selectedSection = viewmodel.appViewmodel.selectedSection.value;
    return widgetFactory.createCard(
      onTap: () {
        viewmodel.showSectionSelectorDialog(context);
      },
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      child: Row(
        children: [
          widgetFactory.createText(context, selectedSection?.name.localize(selectedLanguage) ?? ''),
          const SizedBox(width: 10),
          widgetFactory.createIcon(materialIcon: Icons.arrow_drop_down, size: 20),
        ],
      ),
    );
  }
}
