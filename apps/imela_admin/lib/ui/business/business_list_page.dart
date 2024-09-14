import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/business/business_list.viewmodel.dart';
import 'package:imela_admin/ui/business/components/business_list_item.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class BusinessListPage extends StatefulWidget {
  static const routeName = '/businesses';
  const BusinessListPage({super.key});

  @override
  State<BusinessListPage> createState() => _BusinessListPageState();

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _BusinessListPageState extends State<BusinessListPage> {
  final viewmodel = BusinessListViewmodel.getInstance();

  void initViewmodel() {
    Future.delayed(Duration.zero, () {
      print('init viewmodel');
      viewmodel.initViewmodel();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Scaffold(
        appBar: AppBar(),
        body: Obx(
          () => PageContentLoader(
            isLoading: viewmodel.isLoading.value,
            showContent: viewmodel.businessList.isNotEmpty,
            exception: viewmodel.exception.value,
            hasError: viewmodel.exception.value?.isMainError ?? false,
            content: SingleChildScrollView(
              padding: Responsive.paddingSymetric(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widgetFactory.createText(context, 'Your businesses', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  widgetFactory.createText(context, 'List of businesses you have registered', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 32),
                  AppGridView(
                    shrinkWrap: true,
                    primary: false,
                    crossAxisCount: Responsive.getGridCount(context, itemWidth: 300),
                    items: viewmodel.businessList,
                    crossAxisSpacing: 24,
                    itemExtent: 260,
                    itemBuilder: (context, business, index) {
                      return BusinessListItem(
                        business: business,
                        imageHeight: 125,
                        onSelected: () {
                          viewmodel.navigatetoBusinessDashboard(context, business);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
