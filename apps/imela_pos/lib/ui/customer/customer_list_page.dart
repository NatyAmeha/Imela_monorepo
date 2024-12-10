import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/customer/customer.viewmodel.dart';
import 'package:imela_pos/ui/customer/component/customer_list_item.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class CustomerListPage extends StatefulWidget {
  static const routeName = '/customer-list';
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _CustomerListPageState extends State<CustomerListPage> {
  CustomerViewmodel get viewmodel => CustomerViewmodel.getInstance();
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
        title: const Text('Customer List'),
        actions: [
          widgetFactory.createIcon(
            materialIcon: Icons.sync,
            onPressed: () => viewmodel.loadCustomers(context, fetchPolicy: ApiDataFetchPolicy.networkOnly),
          ),
          if (Responsive.isSmallScreen(context))
            widgetFactory.createIcon(
              materialIcon: Icons.add_circle_outline,
              onPressed: () => viewmodel.showCustomerCreateDialog(context),
            )
          else
            widgetFactory.createButton(
              context: context,
              content: const Text('Add Customer'),
              onPressed: () => viewmodel.showCustomerCreateDialog(context),
            ),
        ],
      ),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          showContent: viewmodel.customers.value.isNotEmpty,
          exception: viewmodel.exception.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          content: Column(
            children: [
              _buildSearchBar(),
              _buildCustomerList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: widgetFactory.createTextField(
              controller: viewmodel.searchController,
              hintText: 'Search customers...',
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
                'phone': widgetFactory.createText(context, 'Phone'),
                'name': widgetFactory.createText(context, 'Name'),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList() {
    return Obx(() {
      return AppListView<Customer>(
        items: viewmodel.filteredCustomers.value,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, customer, index) {
          return Obx(() {
            return CustomerListItem(
              customer: customer,
              isSelected: viewmodel.appViewmodel.selectedCustomer.value?.phoneNumber == customer.phoneNumber,
              onSelected: () {
                viewmodel.selectCustomer(context, customer);
              },
              widgetFactory: widgetFactory,
              onActionClick: (value) {},
            );
          });
        },
      );
    });
  }
}
