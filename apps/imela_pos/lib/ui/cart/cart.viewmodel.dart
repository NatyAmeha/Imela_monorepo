import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/product/discount.usecase.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';

import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/cart/component/cart_action_list_item.dart';
import 'package:imela_pos/ui/cart/component/cart_applied_discount_list_modal.dart';
import 'package:imela_pos/ui/cart/component/discount_list_component.dart';
import 'package:imela_pos/ui/customer/component/customer_details_modal.dart';
import 'package:imela_pos/ui/customer/component/search_customer_list_modal.dart';
import 'package:imela_pos/ui/payment/payment_page.dart';
import 'package:imela_pos/ui/product/components/pos_product_addon_list_modal.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class CartViewmodel extends GetxController with BaseViewmodel {
  final DiscountUseCase discountUseCase;

  CartViewmodel({required this.discountUseCase});
  static CartViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<CartViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  final RxList<CartActionInfo> cartActions = <CartActionInfo>[].obs;

  RxList<DiscountInfo> eligableDiscounts = <DiscountInfo>[].obs;

  var configuredOrderAddons = <OrderConfig>[].obs;
  var ordernote = Rxn<String>();

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  Cart get cart => appViewmodel.cartInfo.value;

  String? get customerId => appViewmodel.selectedCustomer.value?.id;

  List<DiscountInfo> get appliedDiscounts => eligableDiscounts.where((e) => e.isApplied).toList();

  List<ProductAddon> get orderconfigurations => appViewmodel.selectedSection.value?.getAddons(forPOS: true) ?? [];

  bool get canEnableCheckout {
    return cart.items?.isNotEmpty ?? false;
  }

  var contextB = Rxn<BuildContext>();

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () {
      final context = data?['context'] as BuildContext;
      contextB.value = context;
      fecthAvailableDiscounts(resetAvialableDiscounts: false);
      initCartActions();
    });
  }

  void initCartActions() {
    cartActions.value = [
      CartActionInfo(
        actionName: 'Customer',
        selectedValue: appViewmodel.selectedCustomer.value?.name ?? 'Select Customer',
        onTap: () async {
          showAllCustomerLists();
        },
        icon: Icons.person,
        clearIcon: appViewmodel.selectedCustomer.value != null ? const Icon(Icons.clear) : null,
        onClear: () {
          appViewmodel.setSelectedCustomer(null);
          fecthAvailableDiscounts();
          initCartActions();
        },
      ),
      // CartActionInfo(
      //   actionName: 'Price List',
      //   selectedValue: 'Default',
      //   onTap: () {},
      //   icon: Icons.list_alt,
      // ),
      CartActionInfo(
          actionName: 'Discounts',
          selectedValue: appliedDiscounts.isNotEmpty ? '${appliedDiscounts.length} applied' : '${eligableDiscounts.length} available',
          onTap: () {
            applyDiscounts(contextB.value!); // Set up discounts before showing the dialog.
          },
          icon: Icons.discount,
          clearIcon: appliedDiscounts.isNotEmpty ? const Icon(Icons.clear) : null,
          onClear: () {
            removeAppliedDiscounts();
            initCartActions();
          }),
    ];
  }

  void showAllCustomerLists() async {
    try {
      isLoading(true);
      await appViewmodel.getBusinessMemberships(forceReload: false);
      final allCustomers = await appViewmodel.loadCustomers(contextB.value!);
      await showCustomerListModal(contextB.value!, customers: allCustomers, title: 'Select customers');
    } catch (e) {
      print('error $e');
    } finally {
      isLoading(false);
    }
  }

  bool isCartContainsProduct(String? productId) {
    if (productId == null) return false;
    return appViewmodel.cartInfo.value.items?.any((element) => element.productId == productId) ?? false;
  }

  void fecthAvailableDiscounts({bool resetAvialableDiscounts = true}) {
    if (resetAvialableDiscounts) removeAppliedDiscounts();
    var businessDiscounts = appViewmodel.selectedBusiness.value?.discounts ?? [];
    var customerLoyalty = appViewmodel.getCustomerLoyaltyInfo(appViewmodel.selectedCustomer.value);
    final existingDiscounts = List<DiscountInfo>.from(eligableDiscounts.where((e) => e.isApplied));
    var discounthandlers = discountUseCase.resetAddedDiscount().createBusinessOfferDiscounts(businessDiscounts).createLoyaltyDiscount(customerLoyalty, appViewmodel.branchRewards);
    if (appViewmodel.selectedCustomer.value != null) {
      discounthandlers = discounthandlers.createMembershipDiscount(appViewmodel.selectedCustomer.value!.getCustomerMemberships(appViewmodel.allMemberships));
    }
    eligableDiscounts.value = discounthandlers.build(existingDiscounts);
  }

  void removeAppliedDiscounts() {
    eligableDiscounts.value = eligableDiscounts.value.map((e) => e.resetToggle()).toList();
    appliedDiscounts.clear();
    appViewmodel.cartInfo.value = appViewmodel.cartInfo.value.resetAllDiscounts();
    initCartActions();
  }

  void updateProductQty(String productId, {required double qty, bool reset = false}) {
    final item = appViewmodel.cartInfo.value.items?.firstOrNullWhere((element) => element.productId == productId);
    if (item != null) {
      final qtyToAdd = reset ? qty : item.quantity + qty;
      final updatedItem = item.copyWith(quantity: qtyToAdd);
      final updatedItems = appViewmodel.cartInfo.value.items?.map((e) => e.productId == productId ? updatedItem : e).toList() ?? [];
      appViewmodel.cartInfo.value = appViewmodel.cartInfo.value.copyWith(items: updatedItems);
    }
  }

  void addProductToCart(OrderItem item) {
    appViewmodel.cartInfo.value = appViewmodel.cartInfo.value.copyWith(items: [...appViewmodel.cartInfo.value.items ?? [], item]);
    applyEligableDiscountsProactive(item);
  }

  void removeProductFromCart(String productId) {
    appViewmodel.cartInfo.value = appViewmodel.cartInfo.value.copyWith(items: appViewmodel.cartInfo.value.items?.where((element) => element.productId != productId).toList());
  }

  Future<void> clearCart(BuildContext context) async {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cart'),
        content: const Text('Are you sure you want to clear the cart?'),
        actions: [
          widgetFactory.createButton(
            context: context,
            content: const Text('Clear'),
            onPressed: () {
              appViewmodel.resetCartInfo();
            },
          )
        ],
      ),
    );
  }

  Future<void> showCustomerListModal(BuildContext context, {required List<Customer> customers, String? title, String? description, bool showCreateCustomer = true}) async {
    final pageId = UniqueKey().toString();
    final customerDetailsPageId = UniqueKey().toString();
    await AppModalSheet.showModal(
      context,
      type: AppModalSheetType.DIALOG,
      pages: [
        ModalContent(
          id: pageId,
          title: const Text('Select customer'),
          content: SearchCustomerListModal(
            customers: customers,
            selectedCustomer: appViewmodel.selectedCustomer.value,
            title: title ?? 'Select customer',
            description: description,
            showCustomerCreate: showCreateCustomer,
            onCustomerSelected: (contextt, selectedCustomer) {
              addCustomerDetailPage(contextt, customerDetailsPageId, selectedCustomer);
            },
          ),
        ),
      ],
    );
  }

  void addCustomerDetailPage(BuildContext context, String customerDetailsPageId, Customer customer) {
    final eligableRewards = appViewmodel.getEligibleRewards(customer);
    AppModalSheet.addPageToModal(
      context,
      ModalContent(
        id: customerDetailsPageId,
        title: const Text('Customer Details'),
        content: CustomerDetailsModal(
          customer: customer,
          customerMemberships: customer.getCustomerMemberships(appViewmodel.allMemberships),
          customerLoyalty: appViewmodel.getCustomerLoyaltyInfo(customer),
          eligableRewards: eligableRewards,
          businessRewards: appViewmodel.branchRewards,
          selectedLanguage: 'ENGLISH',
          onCustomerSelected: (cont, selectedReward) {
            appViewmodel.setSelectedCustomer(customer);
            fecthAvailableDiscounts();
            initCartActions();
            AppModalSheet.closeModal();
          },
        ),
      ),
    );
  }

  void applyDiscounts(BuildContext context) async {
    fecthAvailableDiscounts(resetAvialableDiscounts: false);
    await AppModalSheet.showModal(
      context,
      type: AppModalSheetType.DIALOG,
      pages: [
        ModalContent(
          id: 'discount',
          title: const Text('Discount List'),
          content: DiscountListDialog(
            onDiscountToggle: (discount) => toggleDiscount(discount),
            onFinish: () async {
              await AppModalSheet.closeModal();
              initCartActions();
            },
          ),
        ),
      ],
    );
  }

  void applyEligableDiscountsProactive(OrderItem item) {
    final discount = appliedDiscounts.where((e) => e.isApplied).toList();
    if (discount.isNotEmpty) {
      final cartDiscountInfo = discount.map((e) => e.toItemDiscount()).toList();
      appViewmodel.cartInfo.value = appViewmodel.cartInfo.value.applyDiscountOnOrderItems(discountList: cartDiscountInfo, selectedProductsForDiscount: [item.productId!], removeExistingDiscount: false);
    }
  }

  void toggleDiscount(DiscountInfo discount) {
    discount = discount.copyWith(isApplied: !discount.isApplied); 
    final discountIndex = eligableDiscounts.indexWhere((e) => e.id == discount.id);
    if (discountIndex != -1) {
      if (discount.source == DiscountSource.LOYALTY) {
        if (discount.isApplied &&  !isCustomerHasEnoughPointsForLoyaltyDiscount(discount)) {
          AppViewmodel.getWidgetFactory(contextB.value!).showFlashMessage(contextB.value!, message: 'Customer don\'t have enough points to apply this discount');
          return;
        }
      }
      eligableDiscounts.value[discountIndex] = discount;
      final cartDiscountInfo = discount.toItemDiscount();
      final allItems = appViewmodel.cartInfo.value.items?.map((e) => e.productId!).toList() ?? [];
      appViewmodel.cartInfo.value = appViewmodel.cartInfo.value.applyDiscountOnOrderItems(discountList: [cartDiscountInfo], selectedProductsForDiscount: allItems, removeExistingDiscount: !discount.isApplied);
      eligableDiscounts.refresh();
    }
  }

  bool isCustomerHasEnoughPointsForLoyaltyDiscount(DiscountInfo discount) {
    var customerLoyalty = appViewmodel.getCustomerLoyaltyInfo(appViewmodel.selectedCustomer.value);
    final totalExistingLoyaltyDiscountsPoints = appliedDiscounts.getLoyaltyDiscounts().getTotalPointApplied();
    final newLoyaltyDiscountPoints = discount.pointApplied;
    if ((totalExistingLoyaltyDiscountsPoints + newLoyaltyDiscountPoints) > (customerLoyalty?.currentPoints ?? 0)) {
      return false;
    }
    return true;
  }

  void navigateToNextPage(BuildContext context) async {
    if (cart.haveMembershipProducts()) {
      var membershipIds = cart.getMembershipIds().firstOrNull;
      if (membershipIds != null) {
        var customerMembership = appViewmodel.selectedCustomer.value?.getCustomerMembershipInfo(membershipIds, appViewmodel.allMemberships);
        if (!(customerMembership?.subscription?.isSubscriptionActive() ?? false)) {
          // no customer selected
          showCustomerListModal(
            context,
            customers: appViewmodel.getMemberCustomers(membershipIds),
            title: 'Select Membership Customer',
            description: 'You need to select a customer with active membership',
            showCreateCustomer: false,
          );
          return;
        }
      }
    }
    if (orderconfigurations.isNotEmpty && configuredOrderAddons.isEmpty) {
      final addonConfig = await showOrderConfigurationPopup(context);
      if (addonConfig != null) {
        PaymentPage.navigate(context);
      }
    } else {
      PaymentPage.navigate(context);
    }
  }

  void onDiscountInfoClicked(BuildContext context, OrderItem item) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    AppModalSheet.showModal(
      context,
      type: AppModalSheetType.DIALOG,
      pages: [
        ModalContent(
          id: 'discount',
          title: const Text('Applied Discounts'),
          content: CartAppliedDiscountListModal(
            item: item,
            widgetFactory: widgetFactory,
            selectedLanguage: appViewmodel.selectedLanguage,
            selectedCurrency: appViewmodel.selectedCurrency,
            onDelete: (discount) {
              // remove(discount);
            },
          ),
        ),
      ],
    );
  }

  Future<AddonConfig?> showOrderConfigurationPopup(BuildContext context) async {
    final configResult = await AppModalSheet.showModal<AddonConfig?>(context, type: AppModalSheetType.SIDESHEET, pages: [
      ModalContent(title: const Text('Product Add-ons/configurations'), content: PosProductAddonModal(productAddons: orderconfigurations, initialConfigs: configuredOrderAddons)),
    ]);
    if (configResult != null) {
      var fetchedOrderConfigs = List<OrderConfig>.from(configResult.orderConfigs);
      fetchedOrderConfigs.removeWhere((e) => e.addonId == OrderConfig.QTY_CONFIG_ID);
      configuredOrderAddons.value = fetchedOrderConfigs;

      appViewmodel.cartInfo.value = appViewmodel.cartInfo.value.copyWith(configs: configuredOrderAddons);
    }
    return configResult;
  }

  void removeOrderConfig(BuildContext context, OrderConfig orderConfig) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    final selectedAddonInfo = orderconfigurations.firstWhereOrNull((e) => e.id == orderConfig.addonId);
    if (!(selectedAddonInfo?.isRequired ?? false)) {
      configuredOrderAddons.value = configuredOrderAddons.value.where((e) => e.addonId != orderConfig.addonId).toList();
      appViewmodel.cartInfo.value = appViewmodel.cartInfo.value.copyWith(configs: configuredOrderAddons);
    } else {
      widgetFactory.showFlashMessage(context, message: 'This is a required addon, You can\'t remove it');
    }
  }

  void showOrderNotePopup(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    final controller = TextEditingController();
    AppModalSheet.showModal(
      context,
      type: AppModalSheetType.DIALOG,
      pages: [
        ModalContent(
          title: const Text('Order Note'),
          content: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                widgetFactory.createText(context, 'Order Note', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                widgetFactory.createTextField(controller: controller, hintText: 'Enter order note', maxLines: 3),
                const SizedBox(height: 24),
                widgetFactory.createButton(
                  context: context,
                  content: const Text('Save'),
                  onPressed: () {
                    ordernote.value = controller.text;
                    AppModalSheet.closeModal();
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void resetOrderNote(String? s) {
    ordernote.value = s;
  }
}
