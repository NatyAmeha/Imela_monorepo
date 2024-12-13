import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'home_page.viewmodel.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  final bool reload;

  final HomepageViewmodel? homeviewmodel;
  const HomePage({super.key, this.homeviewmodel, this.reload = false});

  @override
  State<HomePage> createState() => _HomePageState();

  static Future<void> navigate(BuildContext context, {bool replace = false, bool reload = false}) async {
    await AppController.getInstance.router.navigateTo(context, routeName, replace: replace, extra: {'RELOAD_PAGE': reload});
  }
}

class _HomePageState extends State<HomePage> {
  HomepageViewmodel viewmodel = HomepageViewmodel.getInstance();
  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {'WIDGET': widget, 'CONTEXT': context});
    });
  }

  @override
  void initState() {
    super.initState();
    initializeViewmodel();
  }

  void loadDestinations() {
    Future.delayed(Duration.zero, () {
      if (viewmodel.appviewmodel.reloadHomePageDestination.value) {
        viewmodel.getDestinations(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    loadDestinations();
    return Scaffold(
      body: Obx(
        () => PageContentLoader(
          showContent: viewmodel.destinations.isNotEmpty,
          isLoading: viewmodel.destinations.isEmpty,
          content: PersistentTabView(
            controller: viewmodel.persistentTabController.value,
            tabs: viewmodel.destinations.value
                .map(
                  (destination) => PersistentTabConfig(
                    screen: destination.page,
                    item: ItemConfig(title: destination.title, icon: destination.icon),
                  ),
                )
                .toList(),
            navBarBuilder: (navbarConfig) => Style7BottomNavBar(navBarConfig: navbarConfig),
          ),
        ),
      ),
    );
  }
}
