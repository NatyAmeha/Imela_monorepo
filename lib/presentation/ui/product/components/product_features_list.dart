import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/list/gridview.component.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';

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
  late final controller = CustomListController<ProductFeature>();
  @override
  void initState() {
    super.initState();
    controller.addItems(widget.features);
  }

  @override
  Widget build(BuildContext context) {
    return widget.widgetFactory.createCard(
      padding: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: ColorManager.primaryBackground, width: 1),
      child: AppGridView(
          controller: controller,
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
    controller.dispose();
    super.dispose();
  }
}
