import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/ui/dashboard/homepage.viewmodel.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_ui_kit/components/image/image_uploader.dart';

class DashboardPage extends StatefulWidget {
  static const String baseRoute = '/business';
  static const String routeName = '$baseRoute/:id/dashboard';
  static const String routeNameBeta = '$baseRoute/:id/dashboard';
  final HomePageViewmodel? dashboardViewmodel;
  const DashboardPage({super.key, this.dashboardViewmodel});

  @override
  State<DashboardPage> createState() => _DashboardPageState();

  static void navigate(BuildContext context, String businessId) {
    var router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, '$baseRoute/$businessId/dashboard');
  }
}

class _DashboardPageState extends State<DashboardPage> {
  HomePageViewmodel get viewmodel => widget.dashboardViewmodel ?? Get.put(getIt<HomePageViewmodel>());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          ImageUploader(
            images: [],
            widgetFactory: appWidgetFactory,
            width: 400,
          ),
          appWidgetFactory.createButton(
              context: context,
              content: Text('Sign in'),
              onPressed: () {
                viewmodel.navigatetoSignupPage(context);
              }),
        ],
      ),
    );
  }
}
