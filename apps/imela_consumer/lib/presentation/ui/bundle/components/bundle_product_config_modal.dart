import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/product/components/product_call_to_action_bottom.component.dart';
import 'package:imela/presentation/ui/product/components/product_option_item.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class BundleProductConfigModal extends StatefulWidget {
  final Product product;
  final WidgetFactory widgetFactory;
  final ScrollController? controller;
  final List<Discount> discounts;
  final bool Function(Product productOption)? isOptionSelected;
  final Function(Product selectedProduct, double qty) onConfirm;
  final Function(double value)? onQtyChange;
  const BundleProductConfigModal({
    super.key,
    required this.product,
    required this.widgetFactory,
    this.isOptionSelected,
    required this.onConfirm,
    this.onQtyChange,
    this.controller,
    this.discounts = const [],
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

  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    selectedProductOption = productOptionAvailable ? null : widget.product;
    qty = selectedProductOption?.qty ?? 1.0;
    widgetFactory = widget.widgetFactory;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16) ,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.widgetFactory.createText(context, widget.product.name.localize('ENGLISH'), style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              widget.widgetFactory.createText(context, widget.product.description.localize('ENGLISH'), maxLines: 4, style: Theme.of(context).textTheme.bodyLarge),
              if (productOptionAvailable)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    widget.widgetFactory.createText(context, 'Choose option', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    AppGridView(
                      shrinkWrap: true,
                      primary: false,
                      itemExtent: 90,
                      padding: const EdgeInsets.only(bottom: 130),
                      items: productOptions,
                      crossAxisCount: Responsive.getGridCount(context, itemWidth: 200),
                      itemBuilder: (context, productOption, index) {
                        return ProductOptionItemComponent(
                          productOption: productOption,
                          isOptionSelected: isOptionSelected(productOption),
                          widgetFactory: widget.widgetFactory,
                          discounts: widget.discounts,
                          onOptionSelected: () {
                            setState(() {
                              selectedProductOption = productOption;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
            ],
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
            discounts: widget.discounts,
            enableCallToActionBtn: enableCallToActionBtn,
            onPressed: () {
              widget.onConfirm(selectedProductOption!, qty);
            },
          ),
        ),
      ],
    );
  }

  bool isOptionSelected(Product productOption) {
    return (widget.isOptionSelected?.call(productOption) ?? false) || selectedProductOption?.id == productOption.id;
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
