import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/product/components/product_addon_list_item.dart';
import 'package:imela/presentation/ui/product/components/product_call_to_action_bottom.component.dart';
import 'package:imela/presentation/ui/product/components/product_option_item.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela/presentation/ui/shared/qty_modifier.component.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BundleProductConfigModal extends StatefulWidget {
  final Product product;
  final WidgetFactory widgetFactory;
  final ScrollController? controller;
  final bool Function(Product productOption)? isOptionSelected;
  final Function(Product selectedProduct) onConfirm;
  final Function(double value)? onQtyChange;
  const BundleProductConfigModal({
    super.key,
    required this.product,
    required this.widgetFactory,
    this.isOptionSelected,
    required this.onConfirm,
    this.onQtyChange,
    this.controller,
  });

  @override
  State<BundleProductConfigModal> createState() => _BundleProductConfigModalState();
}

class _BundleProductConfigModalState extends State<BundleProductConfigModal> {
  // setter
  Product? selectedProductOption;
  double qty = 1.0;

  // getters
  bool get productOptionAvailable => widget.product.variants != null && widget.product.variants!.isNotEmpty;
  List<Product> get productOptions => widget.product.variants ?? [];
  bool get enableCallToActionBtn => selectedProductOption != null;
  bool get isDeductQtyDisabled => qty <= (selectedProductOption ?? widget.product).minimumOrderQty;
  bool get isAddQtyDisabled => qty >= ((selectedProductOption ?? widget.product).remainingAmount ?? 0);

  @override
  void initState() {
    super.initState();
    selectedProductOption = productOptionAvailable ? null : widget.product;
    qty = selectedProductOption?.qty ?? 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            controller: widget.controller,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                widget.widgetFactory.createText(context, widget.product.name.localize('ENGLISH'), style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                widget.widgetFactory.createText(context, widget.product.description.localize('ENGLISH'), maxLines: 4, style: Theme.of(context).textTheme.bodyLarge),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    widget.widgetFactory.createText(context, 'Available options', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    AppGridView(
                      height: 80,
                      itemExtent: 250,
                      scrollDirection: Axis.horizontal,
                      items: productOptions,
                      crossAxisCount: 1,
                      itemBuilder: (context, productOption, index) {
                        return ProductOptionItemComponent(
                          productOption: productOption,
                          isOptionSelected: isOptionSelected(productOption),
                          widgetFactory: widget.widgetFactory,
                          onOptionSelected: () {
                            setState(() {
                              selectedProductOption = productOption;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        widget.widgetFactory.createText(context, 'Quantity', style: Theme.of(context).textTheme.titleMedium),
                        QuantityModifierComponent(
                          width: 150,
                          currentQty: qty,
                          widgetFactory: widget.widgetFactory,
                          addQtyDisabled: isAddQtyDisabled,
                          deductQtyDisabled: isDeductQtyDisabled,
                          onQtyChange: (value) {
                            handleQty(value);
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (widget.product.addons?.isNotEmpty ?? false) ...[
                      AppListView<ProductAddon>(
                        primary: false,
                        shrinkWrap: true,
                        items: selectedProductOption?.addons ?? [],
                        separator: const Divider(height: 24),
                        itemBuilder: (context, selectedAddon, index) {
                          return ProductAddonListItem(
                            addon: selectedAddon,
                            // selectedDateRange: productDetailsViewmodel.getAddonOrderConfig(selectedAddon.id!)?.multipleValue.toDateRange(),
                            // selectedSingleOption: productDetailsViewmodel.getAddonOrderConfig(selectedAddon.id!)?.singleValue,
                            widgetFactory: widget.widgetFactory,
                            // selectedNumberValue: double.tryParse(productDetailsViewmodel.getAddonOrderConfig(selectedAddon.id!)?.singleValue ?? ''),
                            onSelectDateClicked: () {
                              // productDetailsViewmodel.handleAddonDateSelection(context, product.addons![index], widgetFactory);
                            },
                            onNumberInputChanged: (newValue) {
                              // productDetailsViewmodel.handleProductAddonQtyChange(context, product.addons![index], value: newValue, widgetFactory: widgetFactory);
                            },
                            onSingleOptionSelection: (newValue) {
                              // productDetailsViewmodel.handleProductAddonsingleSelection(context, product.addons![index], value: newValue, widgetFactory: widgetFactory);
                            },
                          );
                        },
                      ),
                    ]
                  ],
                ).showIfTrue(productOptionAvailable),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ProductCallToActionBottomComponenet(
            product: selectedProductOption ?? widget.product,
            widgetFactory: widget.widgetFactory,
            callToActionText: 'Select',
            enableCallToActionBtn: enableCallToActionBtn,
            onPressed: () {
              widget.onConfirm(selectedProductOption!);
            },
          ),
        ),
      ],
    );
  }

  bool isOptionSelected(Product productOption) {
    return (widget.isOptionSelected?.call(productOption) ?? false) || selectedProductOption == productOption;
  }

  void handleQty(double newQty) {
    setState(() {
      if (selectedProductOption?.canOrderWithQty(newQty) == true) {
        selectedProductOption = selectedProductOption?.updateQty(newQty);
        setState(() {
          qty = newQty;
        });
      }
    });
  }
}
