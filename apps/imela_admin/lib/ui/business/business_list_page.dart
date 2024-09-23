import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/business/business_list.viewmodel.dart';
import 'package:imela_admin/ui/business/components/business_list_item.dart';
import 'package:imela_admin/utils/ui_utiils.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_utils/exception/exception_type.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class BusinessListPage extends StatefulWidget {
  static const routeName = '/businesses';
  const BusinessListPage({super.key});

  @override
  State<BusinessListPage> createState() => _BusinessListPageState();

  static void navigate(BuildContext context, {bool replaceRoute = false}) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName, replace: replaceRoute);
  }
}

class _BusinessListPageState extends State<BusinessListPage> {
  final viewmodel = BusinessListViewmodel.getInstance();

  void initViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {'context': context});
    });
  }

  @override
  void initState() {
    super.initState();
    initViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Scaffold(
        appBar: AppBar(
          actions: [
            Obx(
              () => CircleAvatar(
                child: widgetFactory.createText(context, viewmodel.userNameInitial).showIfTrue(viewmodel.userNameInitial.isNotEmpty),
              ).withPaddingSymetric(horizontal: 8),
            ),
            widgetFactory
                .createIcon(
                    materialIcon: Icons.logout,
                    onPressed: () {
                      viewmodel.logout(context);
                    })
                .withPaddingSymetric(horizontal: 8),
          ],
        ),
        body: Obx(
          () => PageContentLoader(
            isLoading: viewmodel.isLoading.value,
            showContent: viewmodel.businessList.isNotEmpty,
            exception: viewmodel.exception.value,
            hasError: viewmodel.exception.value?.isMainError ?? false,
            errorWidget: UiUtiils.getErrorUIType(exception: viewmodel.exception.value, actionsWithKey: {
              ExceptionTypeActionKey.CREATE_NEW_BUSINESS: () {
                viewmodel.navigateToBusinessRegistrationPage(context);
              },
            }),
            content: SingleChildScrollView(
              padding: Responsive.paddingSymetric(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widgetFactory.createText(context, 'Your businesses', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
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
                        callToActionString: viewmodel.getBusinessCallToActionString(business),
                        onSelected: () {
                          viewmodel.handleBusinessListItemCallToAction(context, business);
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
