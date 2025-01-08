import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/bundle/bundle_detail/bundle_detail.viewmodel.dart';
import 'package:imela/presentation/ui/bundle/components/bundle_summary.dart';
import 'package:imela/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
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
                widgetFactory.createText(context, viewmodel.bundleDescription, style: Theme.of(context).textTheme.bodyMedium, maxLines: 4),
                const SizedBox(height: 16),
                BundleSummary(widgetFactory: widgetFactory, bundle: viewmodel.bundle!, viewmodel: viewmodel),
                const SizedBox(height: 24),
                AppGridView(
                  header: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widgetFactory.createText(context, 'Items', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      widgetFactory.createCard(
                        padding: const EdgeInsets.all(8),
                        color: ColorManager.primaryBackground,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            widgetFactory.createIcon(materialIcon: Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Flexible(
                              child: widgetFactory.createText(
                                context,
                                '${viewmodel.bundle?.getBundleConditionValue(viewmodel.appViewmodel.selectedLanguageUpdated.value)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
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
                  () => widgetFactory.createCard(
                    onTap: () {
                      viewmodel.showSelectedProductsModal(context);
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    borderRadius: BorderRadius.zero,
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [widgetFactory.createText(context, 'Selected Products (${viewmodel.selectedBundleProducts.values.length})', style: Theme.of(context).textTheme.titleSmall), widgetFactory.createIcon(materialIcon: Icons.keyboard_arrow_up)],
                    ),
                  ),
                ),
                Obx(
                  () => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (viewmodel.originalProductPrice > 0)
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
                            widgetFactory.createText(context, viewmodel.bundlePriceString, style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
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
