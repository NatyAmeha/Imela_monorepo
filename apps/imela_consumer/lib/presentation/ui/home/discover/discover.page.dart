import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/home/discover/small_discover_screen.dart';
import 'package:imela/presentation/ui/home/home_page.viewmodel.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';

class BrowsePage extends StatefulWidget {
  final HomepageViewmodel homepageViewmodel;
  const BrowsePage({super.key, required this.homepageViewmodel});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  HomepageViewmodel get viewmodel => widget.homepageViewmodel;

  void initializeViewmodel() {
    Future.delayed(Duration.zero, () async {
      viewmodel.initViewmodel(data: {HomepageViewmodel.FETCH_BROWSEDATA: true, 'CONTEXT': context});
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
    final appWidgetFactory = AppController.getInstance.getWidgetFactory(context);
    return Scaffold(
      body: Obx(
        () => PageContentLoader(
          isDataLoading: viewmodel.isBrowseDataLoading.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          showContent: viewmodel.browseData.value != null,
          exception: viewmodel.exception.value,
          content: ResponsiveWrapper(
            smallScreen: SmallDiscoverScreen(homepageViewmodel: viewmodel, widgetFactory: appWidgetFactory, scaffoldScreen: widget),
          ),
          onTryAgain: () {
            viewmodel.getBrowseData(fetchPolicy: ApiDataFetchPolicy.networkOnly);
          },
        ),
      ),
    );
  }
}
