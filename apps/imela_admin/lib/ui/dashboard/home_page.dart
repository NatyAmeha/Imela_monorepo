import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/dashboard/components/homepage_sidenav.dart';
import 'package:imela_admin/ui/dashboard/homepage.viewmodel.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/home';
  HomePage({super.key});

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }

  final viewmodel = HomePageViewmodel.getInstance();

  @override
  Widget build(BuildContext context) {
    var destinations = viewmodel.getDestinations();
    return Scaffold(
        body: Obx(
      () => PageContentLoader(
          showContent: true,
          content: Row(
            children: [
              Expanded(
                flex: 2,
                child: HOmepageSideNav(
                  destinations: destinations,
                  selectedDestinationIndex: viewmodel.selectedDestinationIndex.value,
                  onDestinationSelected: (index) {
                    viewmodel.moveToDestination(index);
                  },
                ),
              ),
              Expanded(
                flex: 7,
                child: IndexedStack(
                  index: viewmodel.selectedDestinationIndex.value,
                  children: destinations.map((e) => e.screen).toList(),
                ),
              )
            ],
          )),
    ));
  }
}
