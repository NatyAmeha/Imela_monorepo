import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/branch/branch.usecase.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/branch/model/branch.response.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/loyalty/loyalty_usecase.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_core/shared/utils/navigation_destination.dart';
import 'package:imela_core/user/model/access/access.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/l10n/l10n.dart';
import 'package:imela_pos/ui/cart/cart.viewmodel.dart';
import 'package:imela_pos/ui/cart/component/cart_list_component.dart';
import 'package:imela_pos/ui/chat/chat_room_list_page.dart';
import 'package:imela_pos/ui/customer/customer_list_page.dart';
import 'package:imela_pos/ui/home/home_page.dart';
import 'package:imela_pos/ui/membership/pos_membership_list_page.dart';
import 'package:imela_pos/ui/order/order_list_page.dart';
import 'package:imela_pos/ui/order/schedule/order_schedule_page.dart';
import 'package:imela_pos/ui/product/components/pos_product_addon_list_modal.dart';
import 'package:imela_pos/ui/product/components/produc_variant_list_modal.dart';
import 'package:imela_pos/ui/product/product_list_page.dart';
import 'package:imela_pos/ui/section/section_page.dart';
import 'package:imela_pos/ui/staff/staff_list/staff_list_page.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_pos/ui/inventory/inventory_list_page.dart';
import 'package:imela_pos/ui/calendar/calendar_list_page.dart';
import 'package:imela_pos/ui/product_price/product_price_list_page.dart';

@injectable
class HomePageViewmodel extends GetxController with BaseViewmodel {
  final BranchUsecase branchUsecase;
  final LoyaltyUsecase loyaltyUsecase;
  final IExceptiionHandler exceptiionHandler;

  HomePageViewmodel({
    required this.branchUsecase,
    required this.loyaltyUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static HomePageViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<HomePageViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var categories = <String>[].obs;
  var selectedCategory = 'All'.obs;

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  final cartViewmodel = CartViewmodel.getInstance();

  Cart? get cart => appViewmodel.cartInfo.value;
  String get cartTotalAmount => '${appViewmodel.selectedCurrency} ${cart?.getTotalPrice ?? 0}';
  String get cartTotalItems => cart!.getTotalItems();
  Branch? get selectedBranch => appViewmodel.selectedBranch.value;

  String? get businessName => appViewmodel.selectedBusiness.value?.name.localize(appViewmodel.selectedLanguage);
  List<BusinessSection> get sections => appViewmodel.selectedBusiness.value?.sections ?? [];
  String? get selectedSectionId => appViewmodel.selectedSection.value?.id;

  List<Product> get getProductsByCategoryAndSection {
    var products = appViewmodel.allProducts.where((product) => product.sectionId?.contains(selectedSectionId) ?? false).toList();
    if (selectedCategory.value == 'All') {
      return products;
    } else {
      return products.where((product) => product.category!.contains(selectedCategory.value)).toList();
    }
  }

  late TabController businessSectionTabControllers;
  ScrollController businessHeaderScrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initViewmodel({Map<String, dynamic>? data}) async {
    super.initViewmodel(data: data);
    final context = data?['context'] as BuildContext;
    final tickerProvider = data?['tickerProvider'];
    assignCategoryTabController(categories.length, tickerProvider);
    getCustomerBusinessLoyalty(context, appViewmodel.selectedBusinessId);
    appViewmodel.loadCustomers(context);
    appViewmodel.getBusinessMemberships();
  }

  List<AppNavigationDestination> getDestinations(BuildContext context) {
    var defaultDestinations = [
      AppNavigationDestination(name: context.l10n.homeTitle, icon: Icons.home, screen: HomePage(), onTap: () => HomePage.navigate(context)),
      AppNavigationDestination(name: context.l10n.salesTitle, icon: Icons.inventory_2, screen: OrderListPage(), onTap: () => OrderListPage.navigate(context)),
      AppNavigationDestination(name: context.l10n.inventoryTitle, icon: Icons.inventory_2, screen: CustomerListPage(), onTap: () => CustomerListPage.navigate(context)),
      AppNavigationDestination(name: 'Memberships', icon: Icons.wallet_membership_rounded, screen: POSMembershipListPage(), onTap: () => POSMembershipListPage.navigateTo(context)),
      
      // Add Product Management category with destinations
      AppNavigationDestination(
        name: 'Products',
        icon: Icons.shopping_bag,
        category: 'Product Management',
        screen: ProductListPage(),
        onTap: () => ProductListPage.navigate(context)
      ),
      
      // These destinations are placeholders for now
      AppNavigationDestination(
        name: 'Inventory',
        icon: Icons.inventory,
        category: 'Product Management',
        screen: const InventoryListPage(),
        onTap: () => InventoryListPage.navigate(context)
      ),
      
      AppNavigationDestination(
        name: 'Calendar',
        icon: Icons.calendar_today,
        category: 'Product Management',
        screen: const CalendarListPage(),
        onTap: () => CalendarListPage.navigate(context)
      ),
      
      // Add a new destination to the Product Management category
      AppNavigationDestination(
        name: 'Price Lists',
        icon: Icons.price_change,
        category: 'Product Management',
        screen: const ProductPriceListPage(),
        onTap: () => ProductPriceListPage.navigate(context)
      ),
    ];
    
    if (appViewmodel.loggedInStaffAccesses.canAccessStaff()) {
      defaultDestinations.add(AppNavigationDestination(name: 'Staff', icon: Icons.people, screen: StaffListPage(), onTap: () => StaffListPage.navigate(context)));
    }
    defaultDestinations.add(AppNavigationDestination(name: 'Schedules', icon: Icons.calendar_month, screen: OrderSchedulePage(), onTap: () => OrderSchedulePage.navigateTo(context)));
    var sectionDestinations = sections.map(
      (e) => AppNavigationDestination(
        name: e.name.localize(appViewmodel.selectedLanguage),
        icon: Icons.settings,
        category: 'Sections',
        screen: SectionPage(businessId: appViewmodel.selectedBusinessId, sectionId: e.id!, sectionName: e.name.localize(appViewmodel.selectedLanguage)),
        onTap: () => SectionPage.navigate(context, businessId: appViewmodel.selectedBusinessId, sectionId: e.id!, sectionName: e.name.localize(appViewmodel.selectedLanguage)),
      ),
    );
    defaultDestinations.addAll(sectionDestinations);
    return defaultDestinations;
  }

  void assignCategoryTabController(int length, TickerProvider vsync) {
    var productCategories = appViewmodel.allProducts.flatMap((e) => e.category ?? []).toSet()..removeWhere((element) => element.isEmpty);
    categories.assignAll(['All', ...productCategories]);
    selectedCategory.value = categories[0];
    businessSectionTabControllers = TabController(length: categories.length, vsync: vsync);
    businessSectionTabControllers.addListener(() {
      selectedCategory.value = categories[businessSectionTabControllers.index];
    });
  }

  Future<void> syncPOS(BuildContext context) async {
    try {
      isLoading.value = true;
      final result = await branchUsecase.getPosBranchDetails(appViewmodel.selectedBusinessId, selectedBranch!.id!);
      if (!result.isPosBranchFetchSuccessfull) {
        exception.value = AppException(message: result!.message ?? 'Unable to get branch details', isMainError: false);
        return;
      }
      appViewmodel.selectBranch(result!.branch);
    } catch (e) {
      print('error syncing pos: $e');
      exception.value = exceptiionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getCustomerBusinessLoyalty(BuildContext context, String businessId) async {
    try {
      final loyaltyInfo = await loyaltyUsecase.getCustomerBusinessLoyalty(businessId);
      appViewmodel.setSelectedBusinessLoyaltyInfo(loyaltyInfo);
    } catch (e) {
      AppViewmodel.getWidgetFactory(context).showFlashMessage(context, message: 'Unable to get loyalty info');
      // exception(exceptiionHandler.getException(e as Exception));
    }
  }

  List<Widget> geCategoryTabs() {
    return categories.map((e) => Tab(text: e)).toList();
  }

  void navigateToCartPage(BuildContext context) {
    CartListPage.navigate(context);
  }

  void addProductToCartOrUpdateQty(BuildContext context, {double qty = 1, required Product product}) async {
    var selectedProductInfo = product;
    try {
      var orderConfigs = List<OrderConfig>.empty(growable: true);
      if (product.hasVariants()) {
        selectedProductInfo = await showVariantModal(context, product);
      }
      if (product.hasAddons()) {
        final addonConfig = await showAddonModal(context, product);
        orderConfigs = List<OrderConfig>.from(addonConfig.orderConfigs);
        var qtyFromConfigString = orderConfigs.firstWhereOrNull((e) => e.addonId == OrderConfig.QTY_CONFIG_ID)?.singleValue;
        var qtyFromConfigDouble = double.tryParse(qtyFromConfigString ?? '1');
        if (qtyFromConfigDouble != null) {
          qty = qtyFromConfigDouble;
        }
      }
      orderConfigs.removeWhere((e) => e.addonId == OrderConfig.QTY_CONFIG_ID);
      final isProductInCart = cartViewmodel.isCartContainsProduct(selectedProductInfo.id!);
      if (isProductInCart) {
        cartViewmodel.updateProductQty(selectedProductInfo.id!, qty: qty);
      } else {
        final orderItem = selectedProductInfo.getOrderItem(qty, config: orderConfigs);
        cartViewmodel.addProductToCart(orderItem);
      }
    } catch (ex) {
      print('error adding product to cart: $ex');
    }
  }

  Future<AddonConfig> showAddonModal(BuildContext context, Product product) async {
    final configResult = await AppModalSheet.showModal<AddonConfig>(context, type: AppModalSheetType.SIDESHEET, pages: [
      ModalContent(
          title: const Text('Product Add-ons/configurations'),
          content: Obx(
            () => PosProductAddonModal(
              product: product,
              productAddons: List.from(product.getAddons(forPOS: true)),
              customer: appViewmodel.selectedCustomer.value,
              callToAction: 'Add to Cart',
            ),
          )),
    ]);

    return configResult;
  }

  Future<Product> showVariantModal(BuildContext context, Product product) async {
    final variantResult = await AppModalSheet.showModal<Product>(
      context,
      type: AppModalSheetType.SIDESHEET,
      pages: [
        ModalContent(
            title: const Text('Product Variants'),
            content: ProductVariantListModal(
              variants: product.variants ?? [],
              // selectedProduct: product,
              selectedLanguage: appViewmodel.selectedLanguage,
              currency: appViewmodel.selectedCurrency,
              widgetFactory: AppViewmodel.getWidgetFactory(context),
              onVariantSelected: (variant) {
                AppModalSheet.closeModal(result: variant);
              },
            )),
      ],
    );
    return variantResult.copyWith(membershipIds: product.membershipIds);
  }

  void updateProductQty(OrderItem item, double qty) {
    cartViewmodel.updateProductQty(item.productId!, qty: qty, reset: true);
  }

  void removeProductFromCart(String productId) {
    cartViewmodel.removeProductFromCart(productId);
  }

  void showSectionSelectorDialog(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    AppModalSheet.showModal<BusinessSection>(
      context,
      type: AppModalSheetType.BOTTOMSHEET,
      pages: [
        ModalContent(
          title: const Text('Select Section'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widgetFactory.createText(context, 'Select Section', style: Theme.of(context).textTheme.titleMedium).withPaddingSymetric(horizontal: 16),
              const SizedBox(height: 16),
              AppListView(
                items: sections,
                shrinkWrap: true,
                itemBuilder: (context, section, index) {
                  final isSelected = appViewmodel.selectedSection.value?.id == section.id;
                  return widgetFactory.createCard(
                    padding: Responsive.paddingSymetric(context, smallVertical: 12, smallHorizontal: 16),
                    onTap: () {
                      appViewmodel.setSelectedSection(section);
                      AppModalSheet.closeModal(result: section);
                    },
                    child: Row(
                      children: [
                        if (isSelected) ...[
                          const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
                          const SizedBox(width: 8),
                        ],
                        if (!isSelected) const SizedBox(width: 32),
                        widgetFactory.createText(context, section.name.localize(appViewmodel.selectedLanguage), style: Theme.of(context).textTheme.labelLarge),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void navigateToChatPage(BuildContext context) {
    ChatRoomListPage.navigate(context);
  }
}
