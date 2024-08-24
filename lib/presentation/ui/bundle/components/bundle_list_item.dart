import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/bundle/model/product_bundle.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/app_image.dart';
import 'package:melegna_customer/presentation/ui/shared/list/listview.component.dart';
import 'package:melegna_customer/presentation/utils/widget_extesions.dart';

class BundleListItem extends StatelessWidget {
  final ProductBundle bundleData;
  final WidgetFactory widgetFactory;
  final double? height;
  final double width;
  final Function? onTap;
  const BundleListItem({
    super.key,
    required this.bundleData,
    required this.widgetFactory,
    this.height,
    this.width = double.infinity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final productImages = bundleData.getBundleProductImages().take(5);
    return widgetFactory.createCard(
      onTap: () {
        onTap?.call();
      },
      width: width,
      height: height,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                widgetFactory.createText(context, bundleData.name.localize(), style: Theme.of(context).textTheme.titleMedium),
                widgetFactory
                    .createText(
                      context,
                      bundleData.description.localize(),
                      maxLines: 2,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                    .showIfNotNull(bundleData.description),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widgetFactory.createText(context, 'Total price', padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0), style: Theme.of(context).textTheme.labelSmall),
                          widgetFactory.createText(context, '${bundleData.products?.length}', style: Theme.of(context).textTheme.titleSmall, enableResize: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30, child: VerticalDivider(thickness: 1)),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widgetFactory.createText(context, 'Products', padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0), style: Theme.of(context).textTheme.bodySmall),
                          widgetFactory.createText(context, bundleData.getBundleProducts(), style: Theme.of(context).textTheme.labelSmall, enableResize: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30, child: VerticalDivider(thickness: 1)),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widgetFactory.createText(context, 'Ends with', padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0), style: Theme.of(context).textTheme.labelSmall),
                          widgetFactory.createText(context, '4h : 32m : 12s', style: Theme.of(context).textTheme.bodySmall, enableResize: true, maxLines: 1),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                child: AppListView(
                  shrinkWrap: true,
                  height: 50,
                  scrollDirection: Axis.horizontal,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  items: productImages.toList(),
                  itemBuilder: (context, imageUrl, index) {
                    return AppImage(imageUrl: imageUrl, width: 50, height: 50, fit: BoxFit.cover, borderRadius: BorderRadius.circular(8));
                  },
                ).showIfNotNull(productImages.isNotEmpty),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
