import 'package:flutter/material.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/resources/colors.dart';
import 'package:imela_ui_kit/components/badge/badge_list.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/qty_modifier.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class CartListItem extends StatefulWidget {
  final OrderItem cartItem;
  final double width;
  final double? height;
  final double imageWidth;
  final double imageHeight;
  final Function(double qty) onQtyChange;
  final List<DiscountInfo> appliedDiscounts;
  final Function() onDelete;
  final Function onDiscountInfoClicked;
  final String selectedCurrency;
  const CartListItem({
    super.key,
    required this.cartItem,
    this.imageWidth = 50,
    this.imageHeight = 50,
    required this.onQtyChange,
    this.width = double.infinity,
    this.height,
    required this.onDelete,
    this.appliedDiscounts = const [],
    required this.onDiscountInfoClicked,
    required this.selectedCurrency,
  });

  @override
  State<CartListItem> createState() => _CartListItemState();
}

class _CartListItemState extends State<CartListItem> {
  String get selectedLanguage => AppViewmodel.getInstance().selectedLanguage;
  bool get haveDynamicPricing => widget.cartItem.product!.haveDynamicPricing;

  late WidgetFactory widgetFactory;
  Discount? selectedDiscount;
  late ScrollController _scrollController;

  bool get deductQtyDisabled => widget.cartItem.quantity <= (widget.cartItem.product?.minimumOrderQty ?? 0);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedPrice();
    });
  }

  void _scrollToSelectedPrice() {
    final dynamicPrices = widget.cartItem.product!.getDynamicPriceList(widget.selectedCurrency);
    final selectedPrice = widget.cartItem.product!.selectedDynamicPrice(widget.selectedCurrency, qty: widget.cartItem.quantity);
    final selectedIndex = dynamicPrices.indexWhere((price) => price.amount == selectedPrice.amount);

    if (selectedIndex != -1) {
      final position = selectedIndex * 160.0; // Assuming each item has a width of 160
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
      width: widget.width,
      height: widget.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage(imageUrl: widget.cartItem.image, width: widget.imageWidth, height: widget.imageHeight),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widgetFactory.createText(context, widget.cartItem.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleSmall),
                          if (haveDynamicPricing) buildDynamicPriceDiscountItem(context),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        widgetFactory.createText(context, '${widget.cartItem.subtotalAmountString(widget.selectedCurrency)} ', style: Theme.of(context).textTheme.titleMedium).withPaddingSymetric(horizontal: 8),
                        if (widget.appliedDiscounts.isNotEmpty)
                          widgetFactory.createCard(
                            onTap: () {
                              widget.onDiscountInfoClicked();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                widgetFactory.createText(
                                  context,
                                  widget.cartItem.getTotalDiscountAmountPOSString(currency: 'ETB'),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  color: ColorManager.error,
                                  // textDecoration: TextDecoration.lineThrough,
                                ),
                                const SizedBox(width: 4),
                                widgetFactory.createIcon(materialIcon: Icons.keyboard_arrow_down, color: ColorManager.error),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (widget.cartItem.config?.isNotEmpty ?? false) getOrderConfigAndAddon(context, widget.cartItem.config!),
                Row(
                  children: [
                    QuantityModifierComponent(
                      currentQty: widget.cartItem.quantity,
                      onQtyChange: (qty) {
                        widget.onQtyChange(qty);
                      },
                      width: 150,
                      widgetFactory: widgetFactory,
                      deductQtyDisabled: deductQtyDisabled,
                    ),
                    const Spacer(),
                    Wrap(
                      // mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        widgetFactory.createIcon(
                            materialIcon: Icons.delete,
                            onPressed: () {
                              widget.onDelete();
                            }),
                        widgetFactory.createIcon(materialIcon: Icons.more_vert, onPressed: () {}),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getOrderConfigAndAddon(BuildContext context, List<OrderConfig> orderConfigs) {
    return widgetFactory.createCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.all(8),
      child: AppListView(
        items: orderConfigs,
        shrinkWrap: true,
        itemBuilder: (context, orderConfig, index) {
          return Text(orderConfig.getConfigNameForPOSCart(selectedLanguage) ?? '', style: Theme.of(context).textTheme.labelMedium);
        },
      ),
    );
  }

  Widget buildDynamicPriceDiscountItem(BuildContext context) {
    final dynamicPrices = widget.cartItem.product!.getDynamicPriceList('ETB');
    final selectedPrice = widget.cartItem.product!.selectedDynamicPrice('ETB', qty: widget.cartItem.quantity);
    return SizedBox(
      height: 30,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BadgeList(
            values: const ['Dynamic pricing'],
            width: 110,
            colors: const [ColorManager.primary],
            textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 6),
            widgetFactory: widgetFactory,
            height: 25,
          ),
          AppListView(
            scrollDirection: Axis.horizontal,
            scrollController: _scrollController,
            primary: false,
            items: dynamicPrices,
            itemBuilder: (context, dynamicPrice, index) {
              final isSelected = selectedPrice.amount == dynamicPrice.amount;
              return widgetFactory.createCard(
                width: 160,
                borderRadius: BorderRadius.zero,
                padding: const EdgeInsets.all(6),
                border: Border.all(color: isSelected ? ColorManager.primary : ColorManager.primaryBackground),
                child: widgetFactory.createText(context, dynamicPrice.amountWithCurrency, style: Theme.of(context).textTheme.bodyMedium),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
