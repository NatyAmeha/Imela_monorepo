import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/bundle/bundle_list/viewmodel.bundle_list.dart';
import 'package:imela/presentation/ui/bundle/components/bundle_list_item.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:imela/l10n/l10n.dart';

class BundleListPage extends StatefulWidget {
  static const String routeName = '/bundles';
  static const String titleQueryKey = 'title';

  static const BUNDLES_KEY = 'bundles';

  final List<ProductBundle>? bundles;
  final String? title;
  const BundleListPage({super.key, this.bundles, this.title});

  @override
  State<BundleListPage> createState() => _BundleListPageState();

  static navigateTo(BuildContext context, {List<ProductBundle> bundles = const [], String? title}) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName, extra: {BundleListPage.BUNDLES_KEY: bundles, BundleListPage.titleQueryKey: title});
  }
}

class _BundleListPageState extends State<BundleListPage> {
  final viewmodel = BundleListViewModel.getInstance();

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel(data: {BundleListPage.BUNDLES_KEY: widget.bundles});
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = viewmodel.appController.getWidgetFactory(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? context.l10n.bundles)),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          exception: viewmodel.exception.value,
          showContent: viewmodel.bundles.isNotEmpty,
          hasError: viewmodel.exception.value != null,
          content: AppGridView(
            items: viewmodel.bundles,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            crossAxisCount: Responsive.getGridCount(context, itemWidth: 250),
            itemExtent: 225,
            itemBuilder: (context, bundle, index) {
              return BundleListItem(bundleData: bundle, widgetFactory: widgetFactory);
            },
          ),
        ),
      ),
    );
  }
}
