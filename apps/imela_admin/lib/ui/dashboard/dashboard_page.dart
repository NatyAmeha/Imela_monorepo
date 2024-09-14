import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/ui/dashboard/dashboard.viewmodel.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_ui_kit/components/image/image_uploader.dart';

class DashboardPage extends StatefulWidget {
  static const String routeName = '/dashboard';
  static const String baseRoute = '/business';
  static const String routeNameBeta = '$baseRoute/:id/dashboard';
  final DashboardViewmodel? dashboardViewmodel;
  const DashboardPage({super.key, this.dashboardViewmodel});

  @override
  State<DashboardPage> createState() => _DashboardPageState();

  static void navigate(BuildContext context, String businessId) {
    var router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, '$baseRoute/$businessId/dashboard');
  }
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardViewmodel get viewmodel => widget.dashboardViewmodel ?? Get.put(getIt<DashboardViewmodel>());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
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
