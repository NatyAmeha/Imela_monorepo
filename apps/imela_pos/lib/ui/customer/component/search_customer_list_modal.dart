import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/customer/customer.viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_pos/ui/customer/component/customer_list_item.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class SearchCustomerListModal extends StatefulWidget {
  final List<Customer> customers;
  final Customer? selectedCustomer;
  final String title;
  final String? description;
  final double width;
  double? height;
  final bool showCustomerCreate;
  final Function(BuildContext context, Customer) onCustomerSelected;

  SearchCustomerListModal({Key? key, required this.onCustomerSelected, required this.customers, this.title = 'Select Customer', this.description, this.width = 1000, this.height, this.showCustomerCreate = true, this.selectedCustomer}) : super(key: key);

  @override
  State<SearchCustomerListModal> createState() => _SearchCustomerListModalState();
}

class _SearchCustomerListModalState extends State<SearchCustomerListModal> {
  late WidgetFactory widgetFactory;

  var viewModel = CustomerViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewModel.initViewmodel(data: {'context': context, 'customers': widget.customers});
  }

  @override
  Widget build(BuildContext context) {
    widget.height = widget.height ?? MediaQuery.of(context).size.height * 0.8;
    return widgetFactory.createCard(
      padding: Responsive.paddingSymetric(context),
      width: widget.width,
      height: widget.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, widget.title, style: Theme.of(context).textTheme.titleMedium),
              if (widget.showCustomerCreate)
                widgetFactory.createButton(
                  context: context,
                  content: const Text('Create Customer'),
                  style: AppButtonStyle.textButtonStyle(context),
                  onPressed: () => viewModel.showCustomerCreateDialog(context, closeDialog: true),
                ),
            ],
          ),
          if (widget.description != null) ...[
            const SizedBox(height: 12),
            widgetFactory.createText(context, widget.description ?? '', style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 8),
          _buildSearchBar(context),
          const SizedBox(height: 16),
          _buildCustomerList(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: widgetFactory.createTextField(
            controller: viewModel.searchController,
            hintText: 'Search customers...',
            onChanged: viewModel.onSearchTextChanged,
            prefixIcon: widgetFactory.createIcon(materialIcon: Icons.search),
          ),
        ),
        const SizedBox(width: 8),
        Obx(
          () => widgetFactory.createDropDown<String>(
            context: context,
            value: viewModel.searchType.value,
            onChanged: viewModel.setSearchType,
            options: {
              'phone': widgetFactory.createText(context, 'Phone'),
              'name': widgetFactory.createText(context, 'Name'),
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerList(BuildContext context) {
    return Obx(
      () {
        return AppListView<Customer>(
          items: viewModel.filteredCustomers.value,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, customer, index) {
            return CustomerListItem(
              customer: customer,
              isSelected: customer.phoneNumber == widget.selectedCustomer?.phoneNumber,
              memberships: viewModel.appViewmodel.allMemberships,
              onSelected: () {
                widget.onCustomerSelected(context, customer);
              },
              widgetFactory: widgetFactory,
              onActionClick: (value) {},
            );
          },
        );
      },
    );
  }
}
