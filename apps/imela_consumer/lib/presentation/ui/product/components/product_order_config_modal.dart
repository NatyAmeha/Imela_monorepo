import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/product/components/dynamic_price_viewmodel.dart';
import 'package:imela/presentation/ui/product/components/product_addon_list_item.dart';
import 'package:imela/presentation/ui/product/components/product_dynamic_pricing.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela/presentation/utils/string_utils.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductOrderConfigModal extends StatelessWidget {
  final Product product;
  final double qty;
  final WidgetFactory widgetFactory;

  final double width;
  final double height;
  final ScrollController? scrollController;
  final Function(double selectedQty, List<Discount> selectedDiscounts)? onContinue;
  final ProductDetailsViewmodel productDetailsViewmodel;

  ProductOrderConfigModal({
    super.key,
    required this.product,
    required this.qty,
    required this.widgetFactory,
    this.width = double.infinity,
    this.height = 500,
    this.scrollController,
    this.onContinue,
    required this.productDetailsViewmodel,
  });

  bool get isDeductQtyDisabled => qty <= product.minimumOrderQty;
  bool get isAddQtyDisabled => qty >= (product.remainingAmount ?? 0);

  final dynamicPriceViewmodel = DynamicPriceViewmodel.getInstance();

  double get basePrice => product.getTotalPriceUpdated('ETB', qtyInput: 1, discounts: productDetailsViewmodel.discounts.value);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          var appliedDiscounts = [...productDetailsViewmodel.discounts.value, ...dynamicPriceViewmodel.selectedDiscounts];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widgetFactory.createText(context, 'Configuration', style: Theme.of(context).textTheme.headlineMedium).withPaddingAll(16),
              ProductDynamicPricing(
                dynamicPricingDiscounts: product.sortedDynamicPricingDiscounts,
                basePrice: basePrice,
                product: product,
              ),
              const Divider(height: 16),
              if (product.addons?.isNotEmpty ?? false) ...[
                AppListView(
                  primary: false,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  items: product.addons,
                  itemBuilder: (context, selectedAddon, index) {
                    return Obx(
                      () => ProductAddonListItem(
                        addon: product.addons![index],
                        selectedDateRange: productDetailsViewmodel.getAddonOrderConfig(selectedAddon.id!)?.multipleValue.toDateRange(),
                        selectedSingleOption: productDetailsViewmodel.getAddonOrderConfig(selectedAddon.id!)?.singleValue,
                        widgetFactory: widgetFactory,
                        selectedNumberValue: double.tryParse(productDetailsViewmodel.getAddonOrderConfig(selectedAddon.id!)?.singleValue ?? ''),
                        onSelectDateClicked: () {
                          // productDetailsViewmodel.handleAddonDateSelection(context, product.addons![index], widgetFactory);
                        },
                        onNumberInputChanged: (newValue) {
                          productDetailsViewmodel.handleProductAddonQtyChange(context, product.addons![index], value: newValue, widgetFactory: widgetFactory);
                        },
                        onSingleOptionSelection: (newValue) {
                          productDetailsViewmodel.handleProductAddonsingleSelection(context, product.addons![index], value: newValue, widgetFactory: widgetFactory);
                        },
                      ),
                    );
                  },
                  separator: const Divider(height: 24),
                ),
                const Divider(height: 24),
              ],
              Row(
                children: [
                  widgetFactory.createText(context, 'Total', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  widgetFactory.createText(
                    context,
                    product.getTotalPriceUpdatedString('ETB', qty: dynamicPriceViewmodel.selectedQty.value, discounts: appliedDiscounts, additionalPrice: productDetailsViewmodel.totalAddonPrice),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ).withPaddingSymetric(horizontal: 16),
              widgetFactory
                  .createButton(
                    context: context,
                    content: const Text('Continue'),
                    onPressed: productDetailsViewmodel.canEnableAddonContinueBtn
                        ? () {
                            onContinue?.call(dynamicPriceViewmodel.selectedQty.value, appliedDiscounts);
                          }
                        : null,
                  )
                  .withPaddingAll(16)
            ],
          );
        }),
      ],
    );
  }
}
