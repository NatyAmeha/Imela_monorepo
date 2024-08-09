import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/product/components/product_call_to_action_bottom.component.dart';
import 'package:melegna_customer/presentation/ui/product/components/product_option_item.dart';
import 'package:melegna_customer/presentation/ui/shared/list/gridview.component.dart';
import 'package:melegna_customer/presentation/utils/widget_extesions.dart';

class BundleProductConfigModal extends StatefulWidget {
  final Product product;
  final WidgetFactory widgetFactory;
  final ScrollController? controller;
  final Function(Product selectedProduct) onConfirm;
  const BundleProductConfigModal({super.key, required this.product, required this.widgetFactory, required this.onConfirm, this.controller});

  @override
  State<BundleProductConfigModal> createState() => _BundleProductConfigModalState();
}

class _BundleProductConfigModalState extends State<BundleProductConfigModal> {
  bool get productOptionAvailable => widget.product.variants != null && widget.product.variants!.isNotEmpty;
  List<Product> get productOptions => widget.product.variants ?? [];
  Product? selectedProductOption;
  bool get enableCallToActionBtn => selectedProductOption != null;

  @override
  void initState() {
    super.initState();
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
                widget.widgetFactory.createText(context, widget.product.name.localize(), style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                widget.widgetFactory.createText(context, widget.product.description.localize(), maxLines: 4, style: Theme.of(context).textTheme.bodyLarge),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    widget.widgetFactory.createText(context, 'Available options', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    AppGridView(
                      height: 160,
                      itemExtent: 250,
                      scrollDirection: Axis.horizontal,
                      items: productOptions,
                      crossAxisCount: 2,
                      itemBuilder: (context, productOption, index) {
                        return ProductOptionItemComponent(
                          productOption: productOption,
                          isOptionSelected: isProductOptionSelected(productOption),
                          widgetFactory: widget.widgetFactory,
                          onOptionSelected: () {
                            setState(() {
                              selectedProductOption = productOption;
                            });
                          },
                        );
                      },
                    ),
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

  bool isProductOptionSelected(Product selecteProduct){
    if(selectedProductOption == null){
      return false;
    }
    return selectedProductOption!.id == selecteProduct.id;

  }
}
