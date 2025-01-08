import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela_core/settings/model/location.model.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class LocationListModal extends StatelessWidget {
  final String title;
  final Location? selectedLocation;
  final List<Location> locations;
  final WidgetFactory widgetFactory;
  final void Function(BuildContext context, Location location) onLocationSelected;
  final void Function(BuildContext context) onAddLocation;
  LocationListModal({
    super.key,
    required this.title,
    required this.locations,
    this.selectedLocation,
    required this.onLocationSelected,
    required this.onAddLocation,
    required this.widgetFactory,
  });

  @override
  Widget build(BuildContext context) {
    var widgetContext = context;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        widgetFactory.createText(context, title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (locations.isEmpty)
          widgetFactory.createCard(
            child: Column(
              children: [
                widgetFactory.createText(context, 'No locations found', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
              ],
            ),
          )
        else
          AppListView(
            items: locations,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            itemBuilder: (context, location, index) {
              var isSelected = selectedLocation?.id == location.id;
              return widgetFactory.createCard(
                onTap: () => onLocationSelected(widgetContext, location),
                padding: const EdgeInsets.all(16),
                borderRadius: BorderRadius.circular(10),
                elevation: isSelected ? 1 : 0,
                border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer),
                    const SizedBox(width: 8),
                    widgetFactory.createText(context, location.name, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              );
            },
          ),
        const Divider(height: 16),
        widgetFactory.createButton(
          context: context,
          content: const Text('Add new location'),
          style: AppButtonStyle.textButtonStyle(context),
          onPressed: () {
            onAddLocation.call(context);
          },
        )
      ],
    );
  }
}
