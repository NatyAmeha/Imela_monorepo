import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/cart/cart.viewmodel.dart';
import 'package:imela_pos/ui/cart/cart_list_item.dart';
import 'package:imela_pos/ui/cart/component/cart_action_list_item.dart';
import 'package:imela_pos/ui/home/home_page.viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class CartListPage extends StatefulWidget {
  final double width;
  final double? height;

  const CartListPage({
    super.key,
    this.width = double.infinity,
    this.height,
  });

  @override
  State<CartListPage> createState() => _CartListPageState();

  static const routeName = '/cart-list';
  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _CartListPageState extends State<CartListPage> {
  final cartViewmodel = CartViewmodel.getInstance();
  final homePageviewmodel = HomePageViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    cartViewmodel.initViewmodel(data: {'context': context});
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Scaffold(
      appBar: Responsive.isSmallScreen(context) ? AppBar(title: const Text('Cart')) : null,
      body: widgetFactory.createCard(
        elevation: 2,
        borderRadius: BorderRadius.zero,
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (Responsive.isSmallScreen(context)) ...[Obx(() => cartViewmodel.isLoading.value ? const LinearProgressIndicator() : const SizedBox.shrink())],
              if (!Responsive.isSmallScreen(context)) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widgetFactory.createText(context, 'Cart', style: Theme.of(context).textTheme.titleLarge),
                    widgetFactory.createIcon(
                      materialIcon: Icons.delete,
                      onPressed: () {
                        cartViewmodel.clearCart(context);
                      },
                    )
                  ],
                ).withPaddingSymetric(horizontal: 16, vertical: 8),
                Divider(height: 3, color: Colors.grey),
              ],
              if (cartViewmodel.cart.items?.isNotEmpty == true)
                AppListView(
                  items: cartViewmodel.cart.items,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemBuilder: (context, item, index) {
                    return Obx(
                      () => CartListItem(
                        cartItem: item,
                        appliedDiscounts: cartViewmodel.appliedDiscounts,
                        selectedCurrency: cartViewmodel.appViewmodel.selectedCurrency,
                        onQtyChange: (qty) {
                          cartViewmodel.updateProductQty(item.productId!, qty: qty, reset: true);
                        },
                        onDiscountInfoClicked: () {
                          cartViewmodel.onDiscountInfoClicked(context, item);
                        },
                        onDelete: () {
                          cartViewmodel.removeProductFromCart(item.productId!);
                        },
                      ),
                    );
                  },
                )
              else
                const Expanded(child: Center(child: Text('Empty cart'))),
              const Divider(height: 16),
              Obx(() => CartActionList(actions: cartViewmodel.cartActions.value).withPaddingSymetric(horizontal: 8, vertical: 8)),
              // const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (cartViewmodel.orderconfigurations.isNotEmpty) ...[
                      buildOrderConfigurationActionUI(widgetFactory),
                      const Divider(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widgetFactory.createText(context, 'subtotal', style: Theme.of(context).textTheme.titleSmall),
                        widgetFactory.createText(context, cartViewmodel.cart.getSubtotalPOSUpdatedFormatted(cartViewmodel.appViewmodel.selectedCurrency), style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widgetFactory.createText(context, 'Discount', style: Theme.of(context).textTheme.titleSmall),
                        widgetFactory.createText(context, cartViewmodel.cart.getTotalDiscountAmountPOSFormatted(cartViewmodel.appViewmodel.selectedCurrency), style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widgetFactory.createText(context, 'Total', style: Theme.of(context).textTheme.titleSmall),
                        widgetFactory.createText(context, cartViewmodel.cart.getTotalAmountPOSFormatted('ETB'), style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    widgetFactory
                        .createButton(
                          context: context,
                          content: const Text('Continue'),
                          onPressed: cartViewmodel.canEnableCheckout
                              ? () {
                                  cartViewmodel.navigateToNextPage(context);
                                }
                              : null,
                        )
                        .withPaddingSymetric(vertical: 16),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOrderConfigurationActionUI(WidgetFactory widgetFactory) {
    return widgetFactory.createCard(
      padding: const EdgeInsets.all(8),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, '${cartViewmodel.orderconfigurations.length} Additional configurations', style: Theme.of(context).textTheme.bodyLarge),
              widgetFactory.createButton(
                context: context,
                content: widgetFactory.createText(context, cartViewmodel.configuredOrderAddons.isNotEmpty ? 'Edit' : 'Configure', style: Theme.of(context).textTheme.labelMedium, color: Theme.of(context).colorScheme.secondary),
                style: AppButtonStyle.textButtonStyle(context),
                onPressed: () {
                  cartViewmodel.showOrderConfigurationPopup(context);
                },
              ),
            ],
          ),
          getOrderConfigAndAddon(widgetFactory, context, cartViewmodel.configuredOrderAddons),
        ],
      ),
    );
  }

  Widget getOrderConfigAndAddon(WidgetFactory widgetFactory, BuildContext context, List<OrderConfig> orderConfigs) {
    return widgetFactory.createCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.all(8),
      child: AppListView(
        items: orderConfigs,
        shrinkWrap: true,
        itemBuilder: (context, orderConfig, index) {
          final configValue = orderConfig.selectedConfigValue(cartViewmodel.orderconfigurations, cartViewmodel.appViewmodel.selectedLanguage);
          final orderConfigPrice = '+${orderConfig.getAdditionalPrice(cartViewmodel.appViewmodel.selectedCurrency)}';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widgetFactory.createText(context, orderConfig.name.localize(cartViewmodel.appViewmodel.selectedLanguage), style: Theme.of(context).textTheme.labelMedium),
                  widgetFactory.createText(context, orderConfigPrice.toString(), style: Theme.of(context).textTheme.labelMedium),
                ],
              ),
              // const Spacer(),
              const SizedBox(width: 16),
              widgetFactory.createText(
                context,
                configValue.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              // widgetFactory.createIcon(
              //     materialIcon: Icons.delete,
              //     onPressed: () {
              //       cartViewmodel.removeOrderConfig(context, orderConfig);
              //     })
            ],
          );
        },
      ),
    );
  }
}
