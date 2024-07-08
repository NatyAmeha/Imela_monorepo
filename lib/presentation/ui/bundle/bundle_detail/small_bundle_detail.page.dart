import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/shared/list_header.component.dart';
import 'package:melegna_customer/presentation/ui/bundle/bundle_detail/bundle_detail.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/bundle/components/bundle_summary.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:melegna_customer/presentation/ui/shared/list/gridview.component.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';

class SmallBundleDetailScreen extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final BundleDetailViewmodel viewmodel;
  final AppLanguage selectedLanguage;
  const SmallBundleDetailScreen({super.key, required this.widgetFactory, required this.viewmodel, this.selectedLanguage = AppLanguage.ENGLISH});

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
                      onActionClicked: () {},
                    ),
                    shrinkWrap: true,
                    primary: false,
                    itemExtent: 350,
                    controller: viewmodel.productListController,
                    itemBuilder: (context, product, index) {
                      return GridProductListItem(product: product, widgetFactory: widgetFactory, imageHeight: 150, onTap: (){
                        viewmodel.navigateToProductDetailPage(context, product );
                      },);
                    })
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
            color: Theme.of(context)!.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
            child: widgetFactory.createButton(context: context, content: const Text('Continue to buy'), onPressed: () {}),
          ),
        )
      ],
    );
  }
}
