import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/ui/dashboard/dashboard.viewmodel.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class DashboardPage extends StatefulWidget {
  static const String routeName = '/dashboard';
  final DashboardViewmodel? dashboardViewmodel;
  const DashboardPage({super.key, this.dashboardViewmodel});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardViewmodel get viewmodel => widget.dashboardViewmodel ?? Get.put(getIt<DashboardViewmodel>());

  var data = 'dat';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () async {
      data = await viewmodel.getbusinessDetails('662505ca50948fabb12180ba');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          appWidgetFactory.createText(context, data),
        ],
      ),
    );
  }
}
