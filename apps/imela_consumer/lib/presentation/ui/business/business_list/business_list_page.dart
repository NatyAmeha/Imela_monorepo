import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/business/business_list/business_list.viewmodel.dart';
import 'package:imela/presentation/ui/business/component/business_list_tile.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class BusinessListPage extends StatefulWidget {
  static const baseRouteName = '/businesses';
  static const routeName = '$baseRouteName/:query';

  static const BUSINESS_LIST_KEY = 'businesses';
  static const TITLE_KEY = 'title';

  final BusinessListViewmodel? businessListViewmodel;
  final String title;
  final List<Business>? businesses;

  const BusinessListPage({
    super.key,
    required this.title,
    this.businessListViewmodel,
    this.businesses,
  });

  @override
  State<BusinessListPage> createState() => _BusinessListPageState();

  static navigate(BuildContext context, {List<Business> businesses = const [], BusinessListViewmodel? businessListViewmodel, String title = ''}) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName, extra: {BusinessListPage.BUSINESS_LIST_KEY: businesses, BusinessListPage.TITLE_KEY: title});
  }
}

class _BusinessListPageState extends State<BusinessListPage> {
  BusinessListViewmodel get viewmodel => widget.businessListViewmodel ?? Get.put(getIt<BusinessListViewmodel>());
  late WidgetFactory widgetFactory;

  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {BusinessListPage.BUSINESS_LIST_KEY: widget.businesses, BusinessListPage.TITLE_KEY: widget.title});
    });
  }

  @override
  void initState() {
    super.initState();
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    widgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          showContent: viewmodel.businesses.value?.isNotEmpty ?? false,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          content: AppGridView(
            items: viewmodel.businesses.value ?? [],
            isStaggered: true,
            crossAxisCount: Responsive.getGridCount(context, itemWidth: 250),
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 20,
            itemBuilder: (context, business, index) {
              return BusinessListTile(
                business: business,
                widgetFactory: widgetFactory,
                imageHeight: 150,
                showScrollableImage: true,
                onTap: () {
                  viewmodel.navigateToBusinessDetail(context, business);
                },

              );
            },
          ),
        ),
      ),
    );
  }
}

class BusinessGridItem extends StatelessWidget {
  final Business business;
  final WidgetFactory widgetFactory;
  final VoidCallback onTap;

  const BusinessGridItem({
    super.key,
    required this.business,
    required this.widgetFactory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (business.gallery?.logoImage != null)
              Image.network(
                business.gallery!.logoImage!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    business.name?.first.value ?? 'Unnamed Business',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (business.description?.isNotEmpty ?? false)
                    Text(
                      business.description!.first.value ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
