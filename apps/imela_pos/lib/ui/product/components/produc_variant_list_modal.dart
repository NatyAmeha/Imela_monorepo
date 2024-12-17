import 'package:flutter/material.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_pos/ui/product/components/product_list_item.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductVariantListModal extends StatefulWidget {
  final List<Product> variants;
  final String selectedLanguage;
  final String currency;
  final Product? selectedProduct;
  final Function(Product) onVariantSelected;
  final double width;
  final double? height;
  final WidgetFactory widgetFactory;
  const ProductVariantListModal({
    super.key,
    required this.variants,
    required this.selectedLanguage,
    required this.currency,
     this.selectedProduct,
    required this.widgetFactory,
    required this.onVariantSelected,
    this.width = double.infinity,
    this.height,
  });

  @override
  State<ProductVariantListModal> createState() => _ProductVariantListModalState();
}

class _ProductVariantListModalState extends State<ProductVariantListModal> {
  Product? selectedVariant;
  bool get enableSelectButton => selectedVariant != null;
  @override
  void initState() {
    super.initState();
    selectedVariant = widget.selectedProduct;
  }

  @override
  Widget build(BuildContext context) {
    return widget.widgetFactory.createCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.widgetFactory.createText(context, 'Select a variant', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          AppListView(
            items: widget.variants,
            shrinkWrap: true,
            itemBuilder: (context, item, index) => HorizontalProductListItem(
              product: item,
              onTap: () => onVariantSelected(item),
              selectedLanguage: widget.selectedLanguage,
              currency: widget.currency,
              isSelected: isVariantSelected(item),
            ),
          ),
          const SizedBox(height: 16),
          widget.widgetFactory.createButton(
            context: context,
            content: const Text('Select'),
            onPressed: enableSelectButton
                ? () {
                    widget.onVariantSelected(selectedVariant!);
                  }
                : null,
          )
        ],
      ),
    );
  }

  bool isVariantSelected(Product item) {
    return item.id == selectedVariant?.id;
  }

  void onVariantSelected(Product item) {
    setState(() {
      selectedVariant = item;
    });
  }
}
