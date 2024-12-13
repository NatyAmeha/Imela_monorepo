import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';

class CartDynamicPricingComponenet extends StatefulWidget {
  final OrderItem cartItem;
  final List<Discount> dynamicPricingDiscounts;
  final Discount selectedDynamicPriceDiscount;
  final double height;

  const CartDynamicPricingComponenet({
    super.key,
    required this.dynamicPricingDiscounts,
    required this.selectedDynamicPriceDiscount,
    required this.cartItem,
    this.height = 40,
  });

  @override
  _CartDynamicPricingComponenetState createState() => _CartDynamicPricingComponenetState();
}

class _CartDynamicPricingComponenetState extends State<CartDynamicPricingComponenet> {
  late ScrollController scrollController;
  var previouslySelectedIndex = 0;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(CartDynamicPricingComponenet oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the selected price has changed
    _scrollToSelectedPrice();
  }

  void _scrollToSelectedPrice() {
    final selectedIndex = widget.cartItem.product!.getDynamicPriceList('ETB').indexWhere(
          (dynamicPrice) => dynamicPrice.amount == widget.cartItem.product!.selectedDynamicPrice('ETB', qty: widget.cartItem.quantity).amount,
        );

    if (selectedIndex != -1) {
      // Calculate the offset to bring the selected price to the first visible position
      final double offset = selectedIndex * 75.0;

      // Debugging: Print the selected index and offset

      if (previouslySelectedIndex != selectedIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.animateTo(
            offset,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
      previouslySelectedIndex = selectedIndex;
    } else {
      print('Selected price not found in the list.');
    }
  }

  @override
  Widget build(BuildContext context) {
    var widgetFactory = AppController.getInstance.getWidgetFactory(context);

    return AppListView(
      width: double.infinity,
      height: 30,
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      primary: false,
      scrollController: scrollController,
      items: widget.cartItem.product!.getDynamicPriceList('ETB'),
      itemBuilder: (context, dynamicPrice, index) {
        final selectedPrice = widget.cartItem.product!.selectedDynamicPrice('ETB', qty: widget.cartItem.quantity).amount;

        return widgetFactory.createCard(
          width: 75,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: dynamicPrice.amount == selectedPrice ? ColorManager.primary : ColorManager.primaryBackground),
          child: widgetFactory.createText(context, '${dynamicPrice.amount}', style: Theme.of(context).textTheme.labelMedium),
        );
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
