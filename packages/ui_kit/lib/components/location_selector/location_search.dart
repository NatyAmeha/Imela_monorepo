import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/settings/model/location.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/location/location_info.dart';

class LocationSearch extends StatefulWidget {
  final WidgetFactory widgetFactory;
  final bool isLoading;
  final Function(String)? onLocationInputChange;
  final void Function(Location location) onLocationSelected;
  final List<SearchResult> searchResults;
  final TextEditingController locationInputController;
  final void Function(BuildContext context, SearchResult locationInfo)? onLocationInfoSelected;

  const LocationSearch({
    super.key,
    required this.onLocationSelected,
    required this.widgetFactory,
    required this.locationInputController,
    this.isLoading = false,
    this.onLocationInputChange,
    this.searchResults = const [],
    this.onLocationInfoSelected,
  });

  @override
  State<LocationSearch> createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  // var viewmodel = LocationViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.widgetFactory.createCard(
      height: MediaQuery.sizeOf(context).height * 0.8,
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        children: [
          TextField(
            controller: widget.locationInputController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search for location...',
              border: const OutlineInputBorder(),
              suffix: InkWell(
                onTap: () {
                  widget.locationInputController.clear();
                },
                child: const Icon(Icons.close),
              ),
            ),
            onChanged: (query) {
              widget.onLocationInputChange?.call(query);
            },
          ).withPaddingAll(16),
          widget.isLoading ? const LinearProgressIndicator() : const SizedBox(),
          if (widget.searchResults.isEmpty)
            Container()
          else
            AppListView(
              items: widget.searchResults,
              itemBuilder: (context, result, index) {
                return ListTile(
                  title: Text(result.name),
                  onTap: () async {
                    widget.onLocationInfoSelected?.call(context, result);
                  },
                );
              },
            ), 
        ],
      ),
    );
  }
}
