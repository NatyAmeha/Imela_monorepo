import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/home/component/cart_bottom_nav.dart';
import 'package:imela_pos/ui/search/search.model.dart';
import 'package:imela_pos/ui/search/search.viewmodel.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_ui_kit/components/app_choicechip_group.component.dart';

class SearchListPage extends StatefulWidget {
  const SearchListPage({Key? key}) : super(key: key);

  static const routename = '/search';
  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routename);
  }

  @override
  State<SearchListPage> createState() => _SearchListPageState();
}

class _SearchListPageState extends State<SearchListPage> {
  final viewModel = SearchViewmodel.getInstance();
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewModel.initViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_new),
        ),
        title: _buildSearchBar(),
        leadingWidth: 25,
        toolbarHeight: 60,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchResults(context),
        ],
      ),
      bottomSheet: Obx(
        () => CartBottomNav( 
          totalAmountString: viewModel.homePageViewmodel.cartTotalAmount,
          totalItemsString: viewModel.homePageViewmodel.cartTotalItems,
          onTap: () {
            viewModel.navigateToHompage(context);
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 50,
      child: SearchBar(
        controller: viewModel.searchController,
        onChanged: viewModel.setSearchQuery,
        autoFocus: true,
        elevation: WidgetStateProperty.all(0),
        leading: const Icon(Icons.search),
        hintText: 'Search ...',
        onTap: null,
        side: WidgetStateProperty.all(const BorderSide(color: Colors.grey)),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        trailing: [
          InkWell(
            child: const Icon(Icons.close),
            onTap: () {
              viewModel.setSearchQuery('');
            },
          ),
        ],
        onTapOutside: null,
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Obx(
      () => widgetFactory.createDropDown<String>(
        context: context,
        value: viewModel.sortOption.value,
        options: viewModel.getSortOptionsMap(context),
        onChanged: (value) => viewModel.setSortOption(value!),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return Obx(() {
      if (viewModel.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (viewModel.exception.value != null) {
        return Center(child: Text('Error: ${viewModel.exception.value!.message}'));
      }

      if (viewModel.searchResults.isEmpty) {
        return const Center(child: Text('No results found'));
      }

      return viewModel.buildUI(context);
    });
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: viewModel.filterOptions.value.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key.capitalize!, style: const TextStyle(fontWeight: FontWeight.bold)),
                Obx(
                  () => AppChoiceChipGroup(
                      height: 50,
                      padding: const EdgeInsets.all(8),
                      selectedColor: Theme.of(context).colorScheme.primary,
                      unselectedColor: Theme.of(context).colorScheme.primaryContainer,
                      choices: viewModel.getFilterOptions(entry.key),
                      selectedChoices: viewModel.selectedOptionValues,
                      selectionMode: ChoiceChipSelectionMode.multiple,
                      onSelectionChanged: (values, _) {
                        if (!viewModel.isSelectedFilterOption(entry.key, values)) {
                          viewModel.setFilterOptions({entry.key: values});
                        } else {
                          viewModel.removeFilterOption(entry.key, values);
                        }
                      }),
                ),
              ],
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
