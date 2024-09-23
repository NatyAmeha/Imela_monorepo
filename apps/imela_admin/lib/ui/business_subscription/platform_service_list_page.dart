import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/resources/values.dart';
import 'package:imela_admin/ui/business_subscription/components/platform_service_list_item.dart';
import 'package:imela_admin/ui/business_subscription/platform_service.viewmodel.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class PlatformServiceListPage extends StatefulWidget {
  static const routeName = '/platform/services';
  const PlatformServiceListPage({super.key});

  @override
  State<PlatformServiceListPage> createState() => _PlatformServiceListPageState();

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _PlatformServiceListPageState extends State<PlatformServiceListPage> {
  final viewmodel = PlatformServiceViewmodel.getInstance();

  void initViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel();
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
        title: const Text('Select services'),
        actions: [
          Obx(
            () => appWidgetFactory.createButton(
              context: context,
              content: Text(viewmodel.getTotalSelectedServiceString()),
              onPressed: () {
                viewmodel.showSelectedPlatformServiceListModal(context);
              },
            ),
          ),
        ],
      ),
      body: Obx(
        () => PageContentLoader(
          showContent: viewmodel.allServices.isNotEmpty,
          isLoading: viewmodel.isLoading.value,
          exception: viewmodel.exception.value,
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appWidgetFactory.createCard(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
                  padding: Responsive.paddingSymetric(context, largeHorizontal: 40, largeVertical: 30),
                  width: MediaQuery.sizeOf(context).width,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            appWidgetFactory.createText(context, 'Select services that fits with your business', style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 8),
                            appWidgetFactory.createText(context, 'Select one or mulitple services that fits with your business', style: Theme.of(context).textTheme.labelLarge),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppGridView(
                  shrinkWrap: true,
                  primary: false,
                  crossAxisCount: Responsive.getGridCount(context, itemWidth: 310),
                  padding: Responsive.paddingSymetric(context),
                  // height: MediaQuery.sizeOf(context).height * 0.6,
                  itemExtent: viewmodel.gridItemWidth(context),
                  crossAxisSpacing: 24,
                  items: viewmodel.allServices,
                  itemBuilder: (context, platformService, index) {
                    return PlatformServiceListItem(
                      width: 300,
                      widgetFactory: appWidgetFactory,
                      platformService: platformService,
                      selectedLanguage: 'en',
                      currency: 'USD',
                      onSelected: () {
                        viewmodel.showPlatformServiceDetailModel(context, platformService);
                      },
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
