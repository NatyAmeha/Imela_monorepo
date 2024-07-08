import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/injection.dart';
import 'package:melegna_customer/presentation/ui/bundle/bundle_detail/bundle_detail.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/bundle/bundle_detail/small_bundle_detail.page.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';

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
}

class _BundleDetailPageState extends State<BundleDetailPage> {
  BundleDetailViewmodel get viewmodel => widget.bundleDetailViewmodel ?? Get.put(getIt<BundleDetailViewmodel>());

  void initViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {"id": widget.id});
    });
  }

  @override
  void initState() {
    super.initState();
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
          isLoading: viewmodel.isLoading.value,
          showContent: viewmodel.bundle != null,
          content: ResponsiveWrapper(
            smallScreen: SmallBundleDetailScreen(viewmodel: viewmodel, widgetFactory: appWidgetFactory),
          ),
        ),
      ),
    );
  }
}
