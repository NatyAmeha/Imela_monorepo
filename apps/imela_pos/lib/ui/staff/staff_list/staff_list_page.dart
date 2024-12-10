import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/staff/model/staff_model.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/staff/components/staff_list_tile.dart';
import 'package:imela_pos/ui/staff/staff_list/staff.viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';

class StaffListPage extends StatefulWidget {
  static const routeName = '/staff-list';
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _StaffListPageState extends State<StaffListPage> {
  StaffViewmodel get viewmodel => StaffViewmodel.getInstance();
  late final widgetFactory = AppViewmodel.getWidgetFactory(context);

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel(data: {'context': context});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff List'),
        actions: _buildActions(),
      ),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          showContent: viewmodel.filteredStaffs.isNotEmpty,
          exception: viewmodel.exception.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          content: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: _buildStaffList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions() {
    return [
      widgetFactory.createIcon(
        materialIcon: Icons.refresh,
        onPressed: () => viewmodel.loadStaffs(context, fetchPolicy: ApiDataFetchPolicy.networkOnly),
      ),
      widgetFactory.createButton(
        context: context,
        content: widgetFactory.createText(context, 'Add Staff'),
        onPressed: () => viewmodel.showStaffCreateDialog(context),
      ),
    ];
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: widgetFactory.createTextField(
              controller: viewmodel.searchController,
              hintText: 'Search staff...',
              onChanged: viewmodel.onSearchTextChanged,
              prefixIcon: widgetFactory.createIcon(materialIcon: Icons.search),
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => widgetFactory.createDropDown<String>(
              context: context,
              value: viewmodel.searchType.value,
              onChanged: viewmodel.setSearchType,
              options: {
                'id': widgetFactory.createText(context, 'ID'),
                'name': widgetFactory.createText(context, 'Name'),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffList() {
    return Obx(() {
      return AppListView<Staff>(
        items: viewmodel.filteredStaffs.value,
        itemBuilder: (context, staff, index) {
          return StaffListTile(
            staff: staff,
            onSelected: () {
              viewmodel.selectStaff(context, staff);
            },
            widgetFactory: widgetFactory,
            onActionClick: (value) {},
          );
        },
      );
    });
  }
}
