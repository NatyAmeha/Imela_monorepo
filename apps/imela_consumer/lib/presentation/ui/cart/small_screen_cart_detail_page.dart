import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/cart/cart_list.viewmodel.dart';
import 'package:imela/presentation/ui/cart/components/cart_item_list_item.dart';
import 'package:imela/presentation/ui/cart/components/cart_summary.dart';
import 'package:imela/presentation/ui/cart/components/empty_cart.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class SmallScreenCartDetailPage extends StatelessWidget {
  final CartListViewmodel viewmodel;
  final WidgetFactory widgetFactory;
  const SmallScreenCartDetailPage({super.key, required this.viewmodel, required this.widgetFactory});

  String get title => viewmodel.selectedCart.value?.name.localize('ENGLISH') ?? '';
  String get selectedCurrency => AppController.getInstance.selectedCurrency.name;
  String get selectedLanguage => AppController.getInstance.selectedLanguage.name;
  bool get canShowCartList => viewmodel.selectedCart.value?.items?.isNotEmpty == true || viewmodel.cartItemListController.items.isNotEmpty;
  bool get canShowRewardProgram => (!(viewmodel.selectedCart.value?.isBundleCart ?? false));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(title)),
        actions: [Obx(() => viewmodel.getClearCartIcon(context, widgetFactory))],
      ),
      body: Stack(
        children: [
          Obx(
            () => canShowCartList
                ? Column(
                    children: [
                      if (viewmodel.isRewardLoading.value) const LinearProgressIndicator(),
                      Expanded(
                        child: AppListView<OrderItem>(
                          controller: viewmodel.cartItemListController,
                          padding: EdgeInsets.only(top: canShowRewardProgram ? 40 : 8, left: 8, right: 8),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, item, index) {
                            return CartItemListItem(
                              item: item,
                              widgetFactory: widgetFactory,
                              selectedCurrency: selectedCurrency,
                              canRemoveItem: !viewmodel.selectedCart.value!.isBundleCart,
                              onQtyChange: (qtyValue) {
                                viewmodel.updateItemQty(item.productId!, index, qtyValue);
                              },
                              onRemove: () {
                                viewmodel.removeItemsFromCart([item.productId!], [index]);
                              },
                              onDiscountClicked: (item) {
                                viewmodel.showDiscountsModal(context, item);
                              },
                            );
                          },
                        ),
                      ),
                      Obx(
                        () => CartSummary(
                          cart: viewmodel.selectedCart.value!,
                          selectedCurrency: selectedCurrency,
                          widgetFactory: widgetFactory,
                          callToActionText: viewmodel.callToActionText,
                          selectedLanguage: selectedLanguage,
                          usedLoyaltyPoints: viewmodel.appController.usedRewardPoints.value,
                          changeOrderConfigs: () {
                            viewmodel.changeOrderConfigs(context);
                          },
                          onContinue: () {
                            viewmodel.handleNextScreenNavigation(context);
                          },
                          onViewRewards: () {
                            viewmodel.showBusinessRewardsPage(context);
                          },
                          onClearUsedPoints: () {
                            viewmodel.clearUsedPoints();
                          },
                        ),
                      ),
                      if (viewmodel.configResult.value!.additionalItems?.isNotEmpty == true)
                        widgetFactory.createButton(
                          context: context,
                          content: widgetFactory.createText(context, 'See Additional items', style: Theme.of(context).textTheme.bodyMedium, color: Theme.of(context).colorScheme.secondary),
                          style: AppButtonStyle.textButtonStyle(context),
                          onPressed: () {
                            viewmodel.showAdditionalItems(context);
                          },
                        )
                    ],
                  )
                : EmptyCartCard(widgetFactory: widgetFactory),
          ),
          Positioned(child: _buildPointSection(context))
        ],
      ),
    );
  }

  Widget _buildPointSection(BuildContext context) {
    return Obx(() {
      if (!viewmodel.appController.isAuthenticated) {
        return widgetFactory.createCard(
          onTap: () {
            viewmodel.goToLoginPage(context);
          },
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.zero,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widgetFactory.createText(
                      context,
                      'Sign in to apply your rewards',
                      style: Theme.of(context).textTheme.bodySmall,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              widgetFactory.createText(context, 'Sign in', style: Theme.of(context).textTheme.bodySmall, color: Colors.white),
              widgetFactory.createIcon(materialIcon: Icons.keyboard_arrow_right, color: Colors.white, size: 24),
            ],
          ),
        );
      } else if (canShowRewardProgram) {
        return widgetFactory.createCard(
          onTap: () {
            viewmodel.navigatetoApplyRewardPage(context);
          },
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.zero,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => widgetFactory.createText(
                        context,
                        'Your points (${viewmodel.appController.remainingPoints.toStringAsFixed(0)})',
                        style: Theme.of(context).textTheme.bodySmall,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              widgetFactory.createText(context, 'See rewards', style: Theme.of(context).textTheme.bodySmall, color: Colors.white),
              widgetFactory.createIcon(materialIcon: Icons.keyboard_arrow_right, color: Colors.white, size: 24),
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
