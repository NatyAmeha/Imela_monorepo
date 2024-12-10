import 'package:flutter/material.dart';
import 'package:imela_core/shared/utils/navigation_destination.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';

class HomePageSidenav extends StatelessWidget {
  final List<AppNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const HomePageSidenav({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);

    return Drawer(
      child: Column(
        children: [
          widgetFactory.createCard(
            child: Center(
              child: widgetFactory.createText(context, 'Imela POS', style: Theme.of(context).textTheme.titleLarge),
            ),
          ),
          AppListView(
            items: destinations,
            itemBuilder: (context, item, index) {
              final destination = item;
              return widgetFactory.createListTile(
                leading: Icon(destination.icon),
                title: widgetFactory.createText(context, destination.name),
                onTap: () {
                  onDestinationSelected(index);
                  Navigator.pop(context); // Close the drawer
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
