import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/domain/order/model/cart.model.dart';
import 'package:imela/presentation/ui/cart/cart_list.viewmodel.dart';
import 'package:imela/presentation/ui/cart/components/cart_list_item.dart';
import 'package:imela/presentation/ui/cart/components/empty_cart.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';

import 'package:imela/presentation/ui/shared/list/listview.component.dart';

class SmallCartListScreen extends StatelessWidget {
  final CartListViewmodel viewmodel;
  final WidgetFactory widgetFactory;
  const SmallCartListScreen({super.key, required this.viewmodel, required this.widgetFactory});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        viewmodel.getCartsFromApi();
      },
      child: Scaffold(
          appBar: AppBar(title: const Text('Carts')),
          body: Obx(
            () => viewmodel.carts.isNotEmpty
                ? AppListView<Cart>(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    controller: viewmodel.cartListController,
                    itemBuilder: (context, cartInfo, index) {
                      return CartListItem(
                        cartInfo: cartInfo,
                        widgetFactory: widgetFactory,
                        onclick: () {
                          viewmodel.handleCartSelection(context, cartInfo);
                        },
                      );
                    },
                  )
                : EmptyCartCard(widgetFactory: widgetFactory),
          )),
    );
  }
}
