import 'package:flutter/material.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/cart/cart.viewmodel.dart';
import 'package:imela_pos/ui/cart/cart_list_item.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';

class CartListComponent extends StatelessWidget {
  final Cart cart;
  final double width;
  final double? height;
  final Function(OrderItem item, int index, double qty) onQtyChange;
  final Function(OrderItem item, int index) onDelete;
  final Function? onCartClear;
  final Function() onCheckout;
  CartListComponent({
    super.key,
    required this.cart,
    required this.onQtyChange,
    required this.onDelete,
    this.width = double.infinity,
    this.height = double.infinity,
    required this.onCheckout,
    this.onCartClear,
  });

  final cartViewmodel = CartViewmodel.getInstance();

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Cart', style: Theme.of(context).textTheme.titleLarge),
              widgetFactory.createIcon(
                materialIcon: Icons.delete,
                onPressed: () {
                  onCartClear?.call();
                },
              )
            ],
          ),
          const SizedBox(height: 16),
          if (cart.items?.isNotEmpty == true)
            AppListView(
              items: cart.items,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, item, index) {
                return CartListItem(
                  cartItem: item, 
                  onQtyChange: (qty){
                    onQtyChange(item, index, qty);
                  },
                  onDelete: () => onDelete(item, index),
                );
              },
            )
          else
            const Expanded(child: Center(child: Text("Empty cart"))),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'subtotal', style: Theme.of(context).textTheme.titleSmall),
              widgetFactory.createText(context, '${cart.getSubtotal}', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Tax', style: Theme.of(context).textTheme.titleSmall),
              widgetFactory.createText(context, '${cart.getTotalTaxAmount}', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Discount', style: Theme.of(context).textTheme.titleSmall),
              widgetFactory.createText(context, '${cart.getTotalDiscountAmount}', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Total', style: Theme.of(context).textTheme.titleSmall),
              widgetFactory.createText(context, '${cart.getTotalPrice}', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const Divider(height: 32),
          widgetFactory.createButton(
              context: context,
              content: const Text('Continue'),
              onPressed: () {
                onCheckout();
              })
        ],
      ),
    );
  }
}
