import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductFeature {
  final String name;
  final IconData? icon;
  final Color? color;
  const ProductFeature({required this.name, this.icon, this.color = ColorManager.primary});
}

class ProductFeaturesListComponent extends StatefulWidget {
  final List<ProductFeature> features;
  final WidgetFactory widgetFactory;

  const ProductFeaturesListComponent({super.key, required this.widgetFactory, required this.features});

  @override
  State<ProductFeaturesListComponent> createState() => _ProductFeaturesListComponentState();
}

class _ProductFeaturesListComponentState extends State<ProductFeaturesListComponent> {
  @override
  void initState() {
    super.initState();
  } 

  @override
  Widget build(BuildContext context) {
    return widget.widgetFactory.createCard(
      padding: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: ColorManager.primaryBackground, width: 1),
      child: AppGridView(
          items: widget.features,
          padding: const EdgeInsets.symmetric(vertical: 8),
          primary: false,
          itemExtent: 20,
          crossAxisCount: 2,
          shrinkWrap: true,
          itemBuilder: (context, feature, index) {
            return  Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.widgetFactory.createIcon(materialIcon: feature.icon ?? Icons.check_circle_outline, color: feature.color, size: 20),
                const SizedBox(width: 10),
                widget.widgetFactory.createText(context, feature.name, style: Theme.of(context).textTheme.titleSmall),
              ],
            );
          }),
    );
  }

  @override
  void dispose() {
    super.dispose(); 
  }
}
