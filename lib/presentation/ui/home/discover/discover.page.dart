import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/home/discover/small_discover_screen.dart';
import 'package:melegna_customer/presentation/ui/home/home_page.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';

class BrowsePage extends StatefulWidget {
  final HomepageViewmodel homepageViewmodel;
  const BrowsePage({super.key, required this.homepageViewmodel});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  HomepageViewmodel get viewmodel => widget.homepageViewmodel;

  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {HomepageViewmodel.FETCH_BROWSEDATA: true});
    });
  }

  @override
  void initState() {
    super.initState();
    initializeViewmodel();
    viewmodel.startAutoScrollFeatureBanner();
  }

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
        body: Obx(
      () => PageContentLoader(
        isDataLoading: viewmodel.isBrowseDataLoading.value,
        hasError: viewmodel.exception.value?.isMainError ?? false,
        showContent: viewmodel.browseData.value != null,
        content: ResponsiveWrapper(
          smallScreen: SmallDiscoverScreen(homepageViewmodel: viewmodel, widgetFactory: appWidgetFactory, scaffoldScreen: widget),
        ),
      ),
    ));
  }
}
