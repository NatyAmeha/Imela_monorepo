import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/product/components/product_option_item.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class ProductOptionsListComponent extends StatelessWidget {
  final List<Product> productOptions;
  final WidgetFactory widgetFactory;
  final bool isOptionSelected;
  final Function(Product) onTap;
  const ProductOptionsListComponent({
    super.key,
    required this.productOptions,
    required this.widgetFactory,
    required this.onTap,
    this.isOptionSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        widgetFactory.createText(context, 'Choose option', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        AppGridView(
          shrinkWrap: true,
          primary: false,
          itemExtent: 90,
          scrollDirection: Axis.vertical,
          crossAxisCount: Responsive.getGridCount(context, itemWidth: 200),
          items: productOptions,
          itemBuilder: (context, productOption, index) {
            return ProductOptionItemComponent(
              productOption: productOption,
              isOptionSelected: isOptionSelected,
              widgetFactory: widgetFactory,
              onOptionSelected: () {
                onTap(productOption);
              },
            );
          },
        ),
      ],
    );
  }
}
