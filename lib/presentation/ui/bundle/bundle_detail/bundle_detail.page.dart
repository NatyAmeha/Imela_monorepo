import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/domain/bundle/model/product_bundle.model.dart';
import 'package:imela/domain/shared/localized_field.model.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/bundle/bundle_detail/bundle_detail.viewmodel.dart';
import 'package:imela/presentation/ui/bundle/bundle_detail/small_bundle_detail.page.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';
import 'package:imela/services/routing_service.dart';

class BundleDetailPage extends StatefulWidget {
  // routing constants
  static const idQueryKey = 'id';
  static const nameQueryKey = 'name';
  static const baseRouteName = '/bundle';
  static const routeName = '$baseRouteName/:$idQueryKey';

  final String id;
  final String? bundleName;
  final BundleDetailViewmodel? bundleDetailViewmodel;

  const BundleDetailPage({super.key, required this.id, this.bundleName, this.bundleDetailViewmodel});

  @override
  State<BundleDetailPage> createState() => _BundleDetailPageState();

  static void navigateToBundleDetailPage(BuildContext context, IRoutingService router, ProductBundle bundle, {Widget? previousPage}) {
    router.navigateTo(context, '${BundleDetailPage.baseRouteName}/${bundle.id}', extra: {'name': '${bundle.name?.localize()}', GoRouterService.PREVIOUS_PAGE_KEY: previousPage});
  }
}

class _BundleDetailPageState extends State<BundleDetailPage> {
  BundleDetailViewmodel get viewmodel => widget.bundleDetailViewmodel ?? Get.put(getIt<BundleDetailViewmodel>());

  void initViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {'id': widget.id});
    });
  }

  @override
  void initState() {
    super.initState();
    print("bundle detail page called");
    initViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bundleName ?? 'Bundle Detail'),
      ),
      body: Obx(
        () => PageContentLoader(
          isDataLoading: viewmodel.isLoading.value,
          showContent: viewmodel.bundle != null,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          exception: viewmodel.exception.value,
          onTryAgain: () {
            viewmodel.getBundleDetails(widget.id);
          },
          content: ResponsiveWrapper(
            smallScreen: SmallBundleDetailScreen(viewmodel: viewmodel, widgetFactory: appWidgetFactory, scaffoldScreen: widget),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("bundle detail dispose");
    viewmodel.dispose();
    super.dispose();
  }
}
