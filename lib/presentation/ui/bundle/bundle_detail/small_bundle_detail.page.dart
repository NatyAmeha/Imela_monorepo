import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/domain/shared/list_header.component.dart';
import 'package:imela/domain/shared/localized_field.model.dart';
import 'package:imela/presentation/ui/bundle/bundle_detail/bundle_detail.viewmodel.dart';
import 'package:imela/presentation/ui/bundle/components/bundle_summary.dart';
import 'package:imela/presentation/ui/bundle/components/selected_product_from_bundle.list_item.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
import 'package:imela/presentation/utils/currency_utils.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';

class SmallBundleDetailScreen extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final BundleDetailViewmodel viewmodel;
  final Widget scaffoldScreen;
  const SmallBundleDetailScreen({super.key, required this.widgetFactory, required this.viewmodel, required this.scaffoldScreen});

  double get getSelectedProductContainerHeight => viewmodel.selectedBundleProducts.isNotEmpty ? 125 : 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                widgetFactory.createText(context, viewmodel.bundleDescription, style: Theme.of(context).textTheme.labelLarge, maxLines: 4),
                const SizedBox(height: 16),
                BundleSummary(widgetFactory: widgetFactory, bundle: viewmodel.bundle!, viewmodel: viewmodel),
                const SizedBox(height: 24),
                AppGridView(
                  header: AppListHeader(
                    title: 'Products',
                    subtitle: 'Choose ${viewmodel.productListController.items.length} or more products from bundle',
                  ),
                  shrinkWrap: true,
                  primary: false,
                  itemExtent: 350,
                  isStaggered: true,
                  controller: viewmodel.productListController,
                  itemBuilder: (context, product, index) {
                    return GridProductListItem(
                      product: product,
                      widgetFactory: widgetFactory,
                      imageHeight: 150,
                      showRemainingItem: false,
                      isSelected: viewmodel.isProductSelected(product),
                      onTap: () {
                        viewmodel.displayBundleProductConfigModal(context, product, widgetFactory);
                      },
                    );
                  },
                ),
                const SizedBox(height: 250),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: widgetFactory.createCard(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(
                  () => SizedBox(
                    height: getSelectedProductContainerHeight,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: viewmodel.selectedBundleProducts.values
                          .map(
                            (product) => SelectedProductFromBundlListItem(
                              name: product.name.localize(),
                              image: product.getImageUrl(),
                              price: product.getPrice().toSelectedPriceString(),
                              width: 100,
                              widgetFactory: widgetFactory,
                              onRemove: () {
                                viewmodel.removeConfiguredProduct(product);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widgetFactory.createText(context, viewmodel.remainingStatusMsg.value).showIfTrue(viewmodel.remainingStatusMsg.value.isNotEmpty),
                            Row(
                              children: [
                                widgetFactory.createText(context, 'Total', style: Theme.of(context).textTheme.titleSmall),
                                const SizedBox(width: 8),
                                widgetFactory.createText(
                                  context,
                                  '${viewmodel.originalProductPrice}'.withCurrencySymbol(),
                                  style: Theme.of(context).textTheme.titleSmall,
                                  textDecoration: TextDecoration.lineThrough,
                                )
                              ],
                            ),
                            widgetFactory.createText(context, '${viewmodel.bundlePrice}'.withCurrencySymbol(), style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                      ).showIfTrue(viewmodel.originalProductPrice > 0),
                      Expanded(
                        child: widgetFactory.createButton(
                          context: context,
                          content: const Text('Order'),
                          onPressed: viewmodel.enableBundlePurchase ? () {} : null,
                        ),
                      ).showIfTrue(viewmodel.originalProductPrice > 0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
