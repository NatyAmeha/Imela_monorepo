import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/injection.dart';
import 'package:melegna_customer/presentation/ui/bundle/bundle_detail/bundle_detail.page.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/home/home_page.viewmodel.dart';
import 'package:melegna_customer/services/routing_service.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  final HomepageViewmodel? homeviewmodel;
  const HomePage({super.key, this.homeviewmodel});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomepageViewmodel get viewmodel => widget.homeviewmodel ?? Get.put(getIt<HomepageViewmodel>());
  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel();
    });
  }

  @override
  void initState() {
    super.initState();
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        controller: viewmodel.persistentTabController,
        tabs: viewmodel.getDistinations(context).map((destination) => PersistentTabConfig(
          screen: destination.page,
          item: ItemConfig(title: destination.title, icon: destination.icon),
        )).toList(),
        navBarBuilder: (navbarConfig) => Style7BottomNavBar(navBarConfig: navbarConfig),
      ),
    );
  }
}
