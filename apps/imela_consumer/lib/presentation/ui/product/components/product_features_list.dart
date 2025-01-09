import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductFeature {
  final String name;
  final IconData? icon;
  final Color? color;
  final String? description;
  const ProductFeature({required this.name, this.icon, this.color = ColorManager.primary, this.description});
}

class ProductFeaturesListComponent extends StatelessWidget {
  final List<ProductFeature> features;
  final WidgetFactory widgetFactory;
  final Function(ProductFeature)? onTap;

  const ProductFeaturesListComponent({super.key, required this.widgetFactory, required this.features, this.onTap});

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
      borderRadius: BorderRadius.circular(8),
      child: AppGridView(
          items: features,
          padding: const EdgeInsets.symmetric(vertical: 8),
          primary: false,
          itemExtent: 20,
          crossAxisCount: 2,
          shrinkWrap: true,
          itemBuilder: (context, feature, index) {
            return widgetFactory.createCard(
              onTap: () {
                onTap?.call(feature);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widgetFactory.createIcon(materialIcon: feature.icon ?? Icons.check_circle_outline, color: feature.color, size: 16),
                  const SizedBox(width: 10),
                  widgetFactory.createText(context, feature.name, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }),
    );
  }
}
