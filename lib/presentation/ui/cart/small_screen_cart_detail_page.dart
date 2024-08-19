import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:melegna_customer/domain/order/model/order_item.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/ui/app_controller.dart';
import 'package:melegna_customer/presentation/ui/cart/cart_detail.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/cart/components/cart_item_list_item.dart';
import 'package:melegna_customer/presentation/ui/cart/components/cart_summary.dart';
import 'package:melegna_customer/presentation/ui/cart/components/empty_cart.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/list/listview.component.dart';

class SmallScreenCartDetailPage extends StatelessWidget {
  final CartDetailViewmodel viewmodel;
  final WidgetFactory widgetFactory;
  const SmallScreenCartDetailPage({super.key, required this.viewmodel, required this.widgetFactory});

  String get title => viewmodel.selectedCart.value?.name.localize() ?? '';
  String get selectedCurrency => AppController.getInstance.selectedCurrency.name;

  bool get canShowCartList => viewmodel.selectedCart.value?.items?.isNotEmpty == true || viewmodel.cartListController.items.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    print("cart detail payment ${viewmodel.selectedCart.value?.paymentOptions}");
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Obx(
        () => canShowCartList
            ? Column(
                children: [
                  Expanded(
                    child: AppListView<OrderItem>(
                      controller: viewmodel.cartListController,
                      itemBuilder: (context, item, index) {
                        return CartItemListItem(
                          item: item,
                          widgetFactory: widgetFactory,
                          selectedCurrency: selectedCurrency,
                          onQtyChange: (qtyValue) {
                            viewmodel.updateItemQty(item.productId!, index, qtyValue);
                          },
                          onRemove: () {
                            viewmodel.removeItemsFromCart([item.productId!], [index]);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  CartSummary(
                    cart: viewmodel.selectedCart.value!,
                    widgetFactory: widgetFactory,
                    onContinue: () {
                      viewmodel.navigateToOrderConfigurePage(context);
                    },
                  )
                ],
              )
            : EmptyCartCard(widgetFactory: widgetFactory),
      ),
    );
  }
}
