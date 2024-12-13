import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/bundle/bundle_detail/bundle_detail.viewmodel.dart';
import 'package:imela/presentation/ui/bundle/components/bundle_summary.dart';
import 'package:imela/presentation/ui/bundle/components/selected_product_from_bundle.list_item.dart';
import 'package:imela/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class SmallBundleDetailScreen extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final BundleDetailViewmodel viewmodel;
  final Widget scaffoldScreen;
  const SmallBundleDetailScreen({super.key, required this.widgetFactory, required this.viewmodel, required this.scaffoldScreen});

  double get getSelectedProductContainerHeight => viewmodel.selectedBundleProducts.isNotEmpty ? 150 : 0;

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
                widgetFactory.createText(context, viewmodel.bundle?.name?.localize('ENGLISH') ?? '', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                widgetFactory.createText(context, viewmodel.bundleDescription, style: Theme.of(context).textTheme.labelLarge, maxLines: 4),
                const SizedBox(height: 16),
                BundleSummary(widgetFactory: widgetFactory, bundle: viewmodel.bundle!, viewmodel: viewmodel),
                const SizedBox(height: 24),
                AppGridView(
                  header: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widgetFactory.createText(context, 'Items', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      widgetFactory.createCard(
                        padding: const EdgeInsets.all(8),
                        color: ColorManager.accent1,
                        child: Row(
                          children: [
                            widgetFactory.createIcon(materialIcon: Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Flexible(child: widgetFactory.createText(context, '${viewmodel.bundle?.getBundleConditionValue(viewmodel.appViewmodel.selectedLanguageUpdated.value)}', style: Theme.of(context).textTheme.bodyMedium)),
                          ],
                        ),
                      ),
                    ],
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
                      discounts: viewmodel.bundleDiscounts,
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
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(
                  () => ExpansionTile(
                    collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                    dense: true,
                    expandedAlignment: Alignment.centerLeft,
                    enableFeedback: true,
                    title: widgetFactory.createText(context, 'Selected Products (${viewmodel.selectedBundleProducts.values.length})', style: Theme.of(context).textTheme.titleSmall),
                    children: [
                      AppListView(
                        // width: 600,
                        height: getSelectedProductContainerHeight,
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        scrollDirection: Axis.horizontal,
                        items: viewmodel.selectedBundleProducts.values.toList(),
                        itemBuilder: (context, product, index) {
                          return SelectedProductFromBundlListItem(
                            name: product.name.localize('ENGLISH'),
                            image: product.getImageUrl(),
                            qty: product.qty,
                            price: product.getPrice().toSelectedPriceString('ETB'),
                            width: 120,
                            widgetFactory: widgetFactory,
                            onRemove: () {
                              viewmodel.removeConfiguredProduct(product);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          widgetFactory.createText(
                            context,
                            '${viewmodel.originalProductPrice}'.withCurrencySymbol('ETB'),
                            style: Theme.of(context).textTheme.titleSmall,
                            textDecoration: TextDecoration.lineThrough,
                          ),
                          const SizedBox(width: 8),
                          widgetFactory.createText(context, '${viewmodel.bundlePrice}'.withCurrencySymbol('ETB'), style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ).showIfTrue(viewmodel.originalProductPrice > 0),
                      const SizedBox(height: 8),
                      widgetFactory
                          .createButton(
                            context: context,
                            content: const Text('Order'),
                            onPressed: viewmodel.enableBundlePurchase
                                ? () {
                                    viewmodel.addSelectedProductsToCart(context);
                                  }
                                : null,
                          )
                          .showIfTrue(viewmodel.originalProductPrice > 0),
                    ],
                  ).withPaddingSymetric(horizontal: 16, vertical: 8),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
