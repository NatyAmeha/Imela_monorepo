import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/domain/product/model/product.model.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/product/components/product_addon_list_item.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.viewmodel.dart';
import 'package:imela/presentation/ui/shared/qty_modifier.component.dart';
import 'package:imela/presentation/utils/string_utils.dart';

class ProductOrderConfigModal extends StatelessWidget {
  final Product product;
  final double qty;
  final WidgetFactory widgetFactory;

  final double width;
  final double height;
  final ScrollController? scrollController;
  final Function? onContinue;
  final Function(double)? onQtyChange;
  final ProductDetailsViewmodel productDetailsViewmodel;

  const ProductOrderConfigModal({
    super.key,
    required this.product,
    required this.qty,
    required this.widgetFactory,
    this.width = double.infinity,
    this.height = 500,
    this.scrollController,
    this.onContinue,
    this.onQtyChange,
    required this.productDetailsViewmodel,
  });

  bool get isDeductQtyDisabled => qty <= product.minimumOrderQty;
  bool get isAddQtyDisabled => qty >= (product.remainingAmount ?? 0);

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      width: width,
      // height: height,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widgetFactory.createText(context, 'Configure your order', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widgetFactory.createText(context, 'Quantity', style: Theme.of(context).textTheme.titleMedium),
                      QuantityModifierComponent(
                        width: 150,
                        currentQty: qty,
                        widgetFactory: widgetFactory,
                        addQtyDisabled: isAddQtyDisabled,
                        deductQtyDisabled: isDeductQtyDisabled,
                        onQtyChange: (value) {
                          onQtyChange?.call(value);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (product.addons?.isNotEmpty ?? false) ...[
                    ListView.separated(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: product.addons!.length,
                      itemBuilder: (context, index) {
                        final selectedAddon = product.addons![index];
                        return Obx(
                          () => ProductAddonListItem(
                            addon: product.addons![index],
                            selectedDateRange: productDetailsViewmodel.getAddonOrderConfig(selectedAddon.id!)?.multipleValue.toDateRange(),
                            selectedSingleOption: productDetailsViewmodel.getAddonOrderConfig(selectedAddon.id!)?.singleValue,
                            widgetFactory: widgetFactory,
                            selectedNumberValue: productDetailsViewmodel.getSelectedAddonQty(selectedAddon.id!),
                            onSelectDateClicked: () {
                              productDetailsViewmodel.handleAddonDateSelection(context, product.addons![index], widgetFactory);
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
                      separatorBuilder: (context, index) => const Divider(height: 24),
                    ),
                  ]
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: Obx(
              () => widgetFactory.createCard(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: widgetFactory.createButton(
                  context: context,
                  content: const Text('Continue'),
                  onPressed: productDetailsViewmodel.canEnableAddonContinueBtn
                      ? () {
                          onContinue?.call();
                        }
                      : null,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
