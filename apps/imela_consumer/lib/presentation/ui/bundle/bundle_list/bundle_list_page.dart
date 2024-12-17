import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/bundle/bundle_list/viewmodel.bundle_list.dart';
import 'package:imela/presentation/ui/bundle/components/bundle_list_item.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class BundleListPage extends StatefulWidget {
  static const String routeName = '/bundle-list';
  static const FETCH_POLICY_KEY = 'fetchPolicy';
  static const BUNDLES_KEY = 'bundles';

  final List<ProductBundle> bundles;
  final String? fetchPolicy;
  const BundleListPage({super.key, required this.bundles,  this.fetchPolicy});

  @override
  State<BundleListPage> createState() => _BundleListPageState();

  static navigateTo(BuildContext context, {List<ProductBundle> bundles = const [], BundleListFetchPolicy fetchPolicy = BundleListFetchPolicy.all}) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName, extra: {BUNDLES_KEY: bundles, FETCH_POLICY_KEY: fetchPolicy});
  }
}

class _BundleListPageState extends State<BundleListPage> {
  final viewmodel = BundleListViewModel.getInstance();

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel(data: {BundleListPage.BUNDLES_KEY: widget.bundles, BundleListPage.FETCH_POLICY_KEY: widget.fetchPolicy});
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = viewmodel.appController.getWidgetFactory(context);
    return Scaffold(
      appBar: AppBar(),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          exception: viewmodel.exception.value,
          showContent: viewmodel.bundles.isNotEmpty,
          hasError: viewmodel.exception.value != null,
          content: AppGridView(
            items: viewmodel.bundles,
            crossAxisCount: Responsive.getGridCount(context, itemWidth: 250),
            itemBuilder: (context, bundle, index) {
              return BundleListItem(bundleData: bundle, widgetFactory: widgetFactory);
            },
          ),
        ),
      ),
    );
  }
}
