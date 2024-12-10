import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/cart/cart.viewmodel.dart';
import 'package:imela_pos/ui/cart/component/discount_list_item.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class DiscountListDialog extends StatefulWidget {
  final Function(DiscountInfo discountInfo) onDiscountToggle;
  final Function() onFinish;
  DiscountListDialog({required this.onDiscountToggle, required this.onFinish});

  @override
  State<DiscountListDialog> createState() => _DiscountListDialogState();
}

class _DiscountListDialogState extends State<DiscountListDialog> {
  CartViewmodel get viewModel => CartViewmodel.getInstance();
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
  }

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widgetFactory.createText(context, 'Available Discounts', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Obx(
            () => AppListView(
              items: viewModel.eligableDiscounts.value,
              shrinkWrap: true,
              itemBuilder: (context, item, index) {
                final discount = item;
                return DiscountListItem(
                    discount: discount,
                    widgetFactory: widgetFactory,
                    onToggle: () {
                      widget.onDiscountToggle(discount);
                    });
              },
            ),
          ),
          Padding(
            padding: Responsive.paddingSymetric(context, smallHorizontal: 0, smallVertical: 24),
            child: widgetFactory.createButton(
              context: context,
              content: const Text('Finish'),
              onPressed: () {
                widget.onFinish();
              },
            ),
          )
        ],
      ),
    );
  }
}
