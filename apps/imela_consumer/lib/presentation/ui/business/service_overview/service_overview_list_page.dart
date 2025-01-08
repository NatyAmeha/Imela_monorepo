import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/business/service_overview/service_overview_listitem.dart';
import 'package:imela/presentation/ui/business/service_overview/viewmodel.service_overview.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela_core/business/model/service_overview.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class ServiceOverviewListPage extends StatefulWidget {
  static const routeName = '/service-overview-list';
  static const SERVICE_OVERVIEWS_KEY = 'serviceOverviews';

  final List<ServiceOverview> serviceOverviews;

  const ServiceOverviewListPage({super.key, required this.serviceOverviews});
  static void navigate(BuildContext context, {List<ServiceOverview>? serviceOverviews}) {
    AppController.getInstance.router.navigateTo(context, routeName, extra: {SERVICE_OVERVIEWS_KEY: serviceOverviews});
  }

  @override
  State<ServiceOverviewListPage> createState() => _ServiceOverviewListPageState();
}

class _ServiceOverviewListPageState extends State<ServiceOverviewListPage> {
  late WidgetFactory widgetFactory;
  var viewmodel = ServiceOverviewViewModel.getInstance();

  @override
  void initState() {
    super.initState();
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
    viewmodel.initViewmodel(data: {ServiceOverviewListPage.SERVICE_OVERVIEWS_KEY: widget.serviceOverviews});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Overview'),
        leading: IconButton(onPressed: () => viewmodel.goBack(context), icon: const Icon(Icons.close)),
      ),
      body: Obx(
        () => PageContentLoader(
          showContent: viewmodel.serviceOverviews.isNotEmpty,
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viewmodel.featuredServiceOverviews.isNotEmpty) ...[
                  AppListView(
                    header: Column(
                      children: [
                        widgetFactory.createText(context, 'Featured', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ).withPaddingSymetric(horizontal: 16, vertical: 4),
                    items: viewmodel.featuredServiceOverviews,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    primary: false,
                    itemBuilder: (context, overview, index) {
                      return ServiceOverviewListItem(
                        serviceOverview: overview,
                        widgetFactory: widgetFactory,
                        selectedLanguage: viewmodel.appViewmodel.selectedLanguage.name,
                        showFullContent: true,
                        color: viewmodel.getColor(index),
                        galleryHeight: Responsive.getHeight(context, small: 100, medium: 150, large: 200),
                        onGalleryTap: (index) {
                          viewmodel.displayGallery(context, overview, index);
                        },
                        onCallToActionPressed: (){
                          viewmodel.handleCallToAction(context, overview);
                        }
                      );
                    },
                  ),
                  const Divider(height: 40),
                ],
                AppListView(
                  items: viewmodel.nonFeaturedServiceOverview,
                  shrinkWrap: true,
                  primary: false,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  itemBuilder: (context, overview, index) {
                    return ServiceOverviewListItem(
                      serviceOverview: overview,
                      widgetFactory: widgetFactory,
                      selectedLanguage: viewmodel.appViewmodel.selectedLanguage.name,
                      showFullContent: true,
                      // color: viewmodel.colorLists[index % viewmodel.colorLists.length],
                      galleryHeight: Responsive.getHeight(context, small: 100, medium: 150, large: 200),
                      onGalleryTap: (index) {
                        viewmodel.displayGallery(context, overview, index);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
