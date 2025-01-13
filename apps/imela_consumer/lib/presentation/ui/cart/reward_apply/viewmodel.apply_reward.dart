import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/cart/cart_list.viewmodel.dart';
import 'package:imela/presentation/ui/cart/reward_apply/apply_reward_page.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_tier/loyalty_tier_page.dart';
import 'package:imela/presentation/ui/product/components/product_dynamic_pricing.dart';
import 'package:imela/presentation/ui/product/components/product_options_list_component.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/loyalty/model/loyalty_tier.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/loyalty/model/reward_info.model.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/order/order.usecase.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class ApplyRewardViewModel extends GetxController with BaseViewmodel {
  final OrderUsecase orderUsecase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;

  static const SELECTED_REWARD_KEY = "SELECTED_REWARD_INFO";

  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var currentPoints = 0.0;
  var rewards = <Reward>[].obs;
  var remainingPoint = 0.0.obs;

  var selectedRewardsInfo = <SelectedRewardInfo>[].obs;

  // getters
  AppController get appController => AppController.getInstance;
  final cartViewmodel = CartListViewmodel.getInstance();

  ApplyRewardViewModel({
    required this.orderUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  String get selectedLanguage => appController.selectedLanguage.name;
  LoyaltyTier? get selectedBusinessLoyaltyTier => appController.selectedBusinessLoyaltyInfo.value?.tier;
  double get remainingPoints => appController.remainingPoints;

  static ApplyRewardViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<ApplyRewardViewModel>());
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () {
      rewards.value = data?[ApplyRewardPage.REWARDS_KEY] ?? [];
      currentPoints = data?[ApplyRewardPage.REMAINING_POINT_KEY] ?? 0;
      selectedRewardsInfo.value = data?[ApplyRewardPage.SELECTED_REWARD_KEY] ?? [];
      remainingPoint.value = currentPoints;
      listenRewardSelectionChanges();
    });
  }

  void listenRewardSelectionChanges() {
    selectedRewardsInfo.listen((value) {
      double usedPoints = value.fold(0, (previous, info) => previous + info.reward.minPointsToRedeem.toDouble());
      remainingPoint.value = currentPoints - usedPoints;
    });
  }

  bool isRewardSelected(Reward reward) {
    return (selectedRewardsInfo.any((info) => info.reward.id == reward.id && info.products?.isNotEmpty == true)) || (selectedRewardsInfo.any((info) => info.reward.id == reward.id && info.discount != null) || selectedRewardsInfo.any((info) => info.reward.id == reward.id && info.deliveryFeeDiscount != null));
  }

  void handleProductOptionAndConfig(BuildContext context, Reward reward, RewardProductInfo productInfo) async {
    final widgetFactory = appController.getWidgetFactory(context);
    var selectedProduct = productInfo.product!;
    final selectedReward = selectedRewardsInfo.firstWhereOrNull((info) => info.reward.id == reward.id);

    // If product is already selected, remove it and return
    if (selectedReward != null && isProductSelected(selectedReward.reward.id, selectedProduct)) {
      // remove the product from the selected reward
      // var productsAfterRemove = List<Product>.from(selectedReward.products ?? []).where((p) => p.id != selectedProduct.id).toList();
      // selectedRewardsInfo.updateByRewardId(reward.id, updatedInfo: selectedReward.setProducts(productsAfterRemove));
      // selectedRewardsInfo.refresh();
      return;
    }

    // Handle product variants and quantity selection
    if (selectedProduct.variants?.isNotEmpty == true) {
      selectedProduct = await showProductOptionModal(context, selectedProduct, widgetFactory);
    }

    final qty = await showQtyModifierModal(context, selectedProduct: selectedProduct, minQty: productInfo.minQty, maxQty: productInfo.maxQty);

    final updatedProduct = selectedProduct.copyWith(qty: qty, minimumOrderQty: productInfo.minQty.toInt(), maximumOrderQty: productInfo.maxQty.toInt(), discounts: productInfo.discount != null ? [productInfo.discount!] : []);

    // Add product to existing reward or create new reward entry
    if (selectedReward != null) {
      selectedRewardsInfo.updateByRewardId(reward.id, updatedInfo: selectedReward.setProducts([...selectedReward.products ?? [], updatedProduct]));
    } else {
      selectedRewardsInfo.add(SelectedRewardInfo(reward: reward, products: [updatedProduct]));
    }
    selectedRewardsInfo.refresh();
  }

  bool isProductSelected(String rewardId, Product product) {
    return selectedRewardsInfo.any((info) => info.reward.id == rewardId && info.products?.any((p) => p.id == product.id) == true);
  }

  Future<Product> showProductOptionModal(BuildContext context, Product product, WidgetFactory widgetFactory) async {
    final selectedOption = await AppModalSheet.showModal<Product>(
      context,
      type: AppModalSheetType.SIDESHEET,
      pages: [
        ModalContent(
          title: const Text('Select Option'),
          content: ProductOptionsListComponent(
            productOptions: product.variants ?? [],
            widgetFactory: widgetFactory,
            onTap: (productOption) {
              AppModalSheet.closeModal(context: context, result: productOption);
            },
          ),
        )
      ],
    );
    return selectedOption;
  }

  Future<double> showQtyModifierModal(BuildContext context, {Product? selectedProduct, double minQty = 1, double maxQty = 10}) async {
    double? basePrice = selectedProduct?.getTotalPriceUpdated('ETB', qtyInput: 1, discounts: []);
    final qtyResult = await AppModalSheet.showModal(
      context,
      type: AppModalSheetType.DIALOG,
      pages: [
        ModalContent(
          title: const Text('Modify Quantity'),
          content: ProductDynamicPricing(
            dynamicPricingDiscounts: selectedProduct?.sortedDynamicPricingDiscounts ?? [],
            basePrice: basePrice!,
            product: selectedProduct!,
            minQty: minQty,
            maxQty: maxQty,
            initialQty: minQty,
            showFinishBtn: true,
            onFinish: (modalContext, qty) {
              AppModalSheet.closeModal(context: modalContext, result: qty);
            },
          ),
        )
      ],
    );
    return qtyResult;
  }

  void navigateBack(BuildContext context) {
    appController.router.goBack(context);
  }

  Future<void> applyRewards(BuildContext context) async {
    generateUpdatedCartBasedOnSelectedReward();
    cartViewmodel.setSelectedRewardInfo(selectedRewardsInfo.value);
    appController.router.goBack(context, returnValue: {SELECTED_REWARD_KEY: selectedRewardsInfo.value});
  }

  

  void generateUpdatedCartBasedOnSelectedReward() {
    var updatedCart = cartViewmodel.selectedCart.value;
    for (var info in selectedRewardsInfo.value) {
      if (info.discount != null) {
        var discount = info.discount!;
        final updatedDiscount = discount.copyWith(id: info.reward.id, source: DiscountSource.LOYALTY);
        var selectedProductIds = cartViewmodel.selectedCart.value?.items?.map((product) => product.productId).filterNotNull().toList() ?? [];
        var discountItem = updatedDiscount.toItemDiscount(defaultName: [const LocalizedField(key: 'ENGLISH', value: 'Reward discount')]);
        updatedCart = updatedCart?.applyDiscountOnOrderItems(discountList: [discountItem], selectedProductsForDiscount: selectedProductIds, removeExistingDiscount: false);
        updateCartState(updatedCart);
      }
    }
    var selectedProducts = selectedRewardsInfo.map((info) => info.products ?? []).flattened.filterNotNull().toList();
    var orderItems = selectedProducts.map((product) => product.getOrderItem(product.qty ?? 1, discounts: product.discounts ?? [], minQty: product.minimumOrderQty.toDouble(), maxQty: product.maximumOrderQty?.toDouble() ?? 10)).toList();
    updatedCart = updatedCart?.addOrUpdateItems(orderItems);
    updateCartState(updatedCart);
  }

  void updateCartState(Cart? cart) {
    if (cart != null) {
      cartViewmodel.updateCartState(cart);
      cartViewmodel.selectedCart.value = cartViewmodel.selectedCart.value?.copyWith(items: cart.items);
      cartViewmodel.cartItemListController.setItems(cartViewmodel.selectedCart.value!.items ?? []);
    }
  }

  List<Product> getSelectedProducts(String id) {
    return selectedRewardsInfo.firstWhereOrNull((info) => info.reward.id == id)?.products ?? [];
  }

  void handleRedeemTap(BuildContext context, Reward reward) {
    var selectedReward = selectedRewardsInfo.firstWhereOrNull((info) => info.reward.id == reward.id);
    if (reward.isDiscountReward()) {
      if (selectedReward?.discount != null) {
        selectedRewardsInfo.removeWhere((info) => info.reward.id == reward.id);
      } else {
        selectedRewardsInfo.add(SelectedRewardInfo(reward: reward, discount: reward.rewardInfo?.firstOrNullWhere((t) => true)?.discount));
      }
    } else if (reward.isDeliveryReward()) {
      if (selectedReward == null) {
        selectedRewardsInfo.add(SelectedRewardInfo(reward: reward, deliveryFeeDiscount: reward.rewardInfo?.firstOrNullWhere((t) => true)?.deliveryRewardInfo?.discount?.value));
      } else {
        selectedRewardsInfo.updateByRewardId(reward.id, updatedInfo: selectedReward.setDeliveryFeeDiscount(reward.rewardInfo?.firstOrNullWhere((t) => true)?.deliveryRewardInfo?.discount?.value ?? 0));
      }
    }
  }

  void removeSelectedReward(BuildContext context, Reward reward) {
    final rewardInfo = selectedRewardsInfo.firstWhereOrNull((info) => info.reward.id == reward.id);
    if (rewardInfo != null) {
      cartViewmodel.removeAppliedRewards(rewardInfo.reward);
    }
    selectedRewardsInfo.removeWhere((info) => info.reward.id == reward.id);
  }

  void navigateToLoyaltyTierPage(BuildContext context) {
    var selectedBusinessId = cartViewmodel.selectedCart.value?.businessIds?.firstOrNullWhere((t) => true);
    if (selectedBusinessId != null) {
      LoyaltyTierListPage.navigate(context, businessId: selectedBusinessId);
    }
  }
}
