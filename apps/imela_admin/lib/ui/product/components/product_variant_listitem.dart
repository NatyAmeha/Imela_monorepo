import 'package:flutter/material.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/product/components/product_options_form.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';

class ProductVariantListItem extends StatelessWidget {
  final ProductVariant variant;
  final Function(bool? isSelected)? onVariantSelected;
  const ProductVariantListItem({super.key, required this.variant, this.onVariantSelected});

  String get variantName => variant.options?.entries.map((e) => '${e.key}: ${e.value}').join(', ') ?? variant.name;

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
        child: Row(
      children: [
        AppImage(imageUrl: variant.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
        const SizedBox(width: 10),
        Expanded(child: widgetFactory.createText(context, variantName)),
        Expanded(
          child: widgetFactory.createCheckboxListTile(context, title: '', value: variant.isSelected, onChanged: (value) {
            onVariantSelected?.call(value);
          }),
        ),
      ],
    ));
  }
}
