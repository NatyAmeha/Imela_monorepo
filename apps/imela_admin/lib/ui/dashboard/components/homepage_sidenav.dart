import 'package:flutter/material.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/dashboard/dashboard_destination.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';

class HOmepageSideNav extends StatelessWidget {
  final List<DashboardDestination> destinations;
  final selectedDestinationIndex;
  final Function(int) onDestinationSelected;
  const HOmepageSideNav({super.key, required this.destinations, required this.selectedDestinationIndex, required this.onDestinationSelected});

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
      child: Column(
        children: [
          Expanded(
            child: AppListView(
              shrinkWrap: true,
              items: destinations,
              itemBuilder: (context, item, index) => widgetFactory.createListTile(
                leading: widgetFactory.createIcon(materialIcon: item.icon),
                title: Text(item.name),

                onTap: () {
                  onDestinationSelected(index);
                }
              ),
            ),
          ),
        ],
      ),
    );
  }
}
