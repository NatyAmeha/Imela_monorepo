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
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    cartViewmodel.initViewmodel(data: {'context': context});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Responsive.isSmallScreen(context) ? AppBar(title: const Text('Cart')) : null,
      body: widgetFactory.createCard(
        elevation: 2,
        borderRadius: BorderRadius.zero,
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (Responsive.isSmallScreen(context)) ...[
                Obx(() => cartViewmodel.isLoading.value ? const LinearProgressIndicator() : const SizedBox.shrink()),
                buildOrderNoteUI(),
              ],
              if (!Responsive.isSmallScreen(context)) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: widgetFactory.createText(context, 'Cart', style: Theme.of(context).textTheme.titleLarge),
                    ),
                    widgetFactory.createIcon(
                      materialIcon: Icons.delete,
                      onPressed: () {
                        cartViewmodel.clearCart(context);
                      },
                    )
                  ],
                ).withPaddingSymetric(horizontal: 16, vertical: 8),
                buildOrderNoteUI(),
                const Divider(height: 3, color: Colors.grey),
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

  Widget buildOrderNoteUI() {
    return Obx(() => widgetFactory.createCard(
          padding: const EdgeInsets.all(8),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (cartViewmodel.ordernote.value != null) ...[
                widgetFactory.createText(context, cartViewmodel.ordernote.value!, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 2),
              ],
              widgetFactory.createButton(
                context: context,
                content: const Text('Add Order note'),
                style: AppButtonStyle.textButtonStyle(context, padding: EdgeInsets.zero),
                onPressed: () {
                  cartViewmodel.showOrderNotePopup(context);
                },
              ),
            ],
          ).withPaddingAll(8),
        ));
  }

  Widget buildOrderConfigurationActionUI(WidgetFactory widgetFactory) {
    return widgetFactory.createCard(
      padding: const EdgeInsets.all(8),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widgetFactory.createText(context, orderConfig.name.localize(cartViewmodel.appViewmodel.selectedLanguage), style: Theme.of(context).textTheme.labelMedium),
                  const Spacer(),
                  widgetFactory.createText(context, orderConfigPrice.toString(), style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(width: 8),
                  InkWell(
                      child: widgetFactory.createIcon(materialIcon: Icons.delete, size: 20),
                      onTap: () {
                        cartViewmodel.removeOrderConfig(context, orderConfig);
                      })
                ],
              ),
              // const Spacer(),
              const SizedBox(width: 16),
              widgetFactory.createText(
                context,
                configValue.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          );
        },
      ),
    );
  }
}
