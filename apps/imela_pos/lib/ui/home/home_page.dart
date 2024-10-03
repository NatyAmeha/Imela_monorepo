import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/cart/component/cart_list_component.dart';
import 'package:imela_pos/ui/home/component/home_page_navbar.dart';
import 'package:imela_pos/ui/home/component/home_product_list_item.dart';
import 'package:imela_pos/ui/home/home_page.viewmodel.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

  static void navigate(BuildContext context, {bool replace = false}) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName, replace: replace);
  }
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  var viewmodel = HomePageViewmodel.getInstance();
  var selectedLanguage = AppViewmodel.getInstance().selectedLanguage;

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel(data: {'tickerProvider': this});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => PageContentLoader(
          showContent: viewmodel.selectedBranch != null,
          isLoading: viewmodel.isLoading.value,
          content: Row(
            children: [
              Expanded(
                flex: 5,
                child: NestedScrollView(
                  controller: viewmodel.businessHeaderScrollController,
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverAppBar(
                      pinned: true,
                      title: HomePageNavbar(
                        branchName: viewmodel.selectedBranch!.name.localize(selectedLanguage),
                        businessName: "Business name",
                        userName: "Natnael",
                        controller: viewmodel.searchController,
                        onSync: () {
                          viewmodel.syncPOS(context);
                        },
                      ),
                      bottom: TabBar(controller: viewmodel.businessSectionTabControllers, tabs: viewmodel.geCategoryTabs(), isScrollable: true),
                    )
                  ],
                  body: Row(
                    children: [
                      Expanded(
                        child: AppGridView(
                          padding: Responsive.paddingSymetric(context),
                          items: viewmodel.getProductsByCategory,
                          itemExtent: 250,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          crossAxisCount: Responsive.getGridCount(context, itemWidth: Responsive.isSmallScreen(context) ? 150 : 270),
                          itemBuilder: (context, product, index) {
                            return HomeProductListItem(
                              product: product,
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
                Expanded(
                  flex: 2,
                  child: Obx(
                    () => CartListComponent(
                      width: 300,
                      cart: viewmodel.cartViewmodel.cart,
                      onQtyChange: (item, index, qty) {
                        viewmodel.updateProductQty(item, qty);
                      },
                      onDelete: (item, index) {
                        viewmodel.removeProductFromCart(item.productId!);
                      },
                      onCheckout: () {
                        viewmodel.navigateToPaymentPage(context);
                      },
                      onCartClear: () {
                        viewmodel.clearCart();
                      },
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
