import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/location_selector/location_selector.viewmodel.dart';
import 'package:imela_core/settings/model/location.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class LocationSelectorPage extends StatefulWidget {
  static const routeName = '/location-selecctor';
  final void Function(BuildContext context, Location location) onLocationSelected;

  const LocationSelectorPage({super.key, required this.onLocationSelected});

  @override
  State<LocationSelectorPage> createState() => _LocationSelectorPageState();

  static Future<Location?> navigate(BuildContext context) async {
    final router = AppController.getInstance.router;
    final result = await router.navigateTo<Location>(context, LocationSelectorPage.routeName);
    return result;
  }
}

class _LocationSelectorPageState extends State<LocationSelectorPage> {
  var viewmodel = LocationViewmodel.getInstance();
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
    viewmodel.initViewmodel(data: {'context': context});
  }

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      height: MediaQuery.sizeOf(context).height * 0.8,
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        children: [
          TextField(
            controller: viewmodel.searchInputController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search for location...',
              border: const OutlineInputBorder(),
              suffix: InkWell(
                onTap: () {
                  viewmodel.clearInput();
                },
                child: const Icon(Icons.close),
              ),
            ),
            onChanged: (query) {
              viewmodel.searchPlaces(query);
            },
          ).withPaddingAll(16),
          Obx(() => viewmodel.isLoading.value ? const LinearProgressIndicator() : const SizedBox()),
          Obx(
            () {
              if (viewmodel.searchResults.isEmpty) return Container();
              return AppListView(
                items: viewmodel.searchResults.value,
                itemBuilder: (context, result, index) {
                  return ListTile(
                    title: Text(result.name),
                    onTap: () async {
                      viewmodel.selectLocation(context, result);
                      var locationInfo = await viewmodel.confirmLocation(context);
                      widget.onLocationSelected(context, locationInfo);
                      // viewmodel.searchResults.clear(); // Clear search results after selection
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
