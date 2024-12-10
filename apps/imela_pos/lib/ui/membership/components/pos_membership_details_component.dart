import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/customer/component/customer_list_item.dart';
import 'package:imela_pos/ui/home/component/home_product_list_item.dart';
import 'package:imela_pos/ui/membership/pos_membership_list.viewmodel.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class PosMembershipDetailsComponent extends StatelessWidget {
  static const routeName = '/pos/membership/details';
  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }

  PosMembershipDetailsComponent({super.key});
  final POSMembershipListViewmodel viewmodel = POSMembershipListViewmodel.getInstance();
  late WidgetFactory widgetFactory;
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    final isSmallScreen = Responsive.isSmallScreen(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: (isSmallScreen)
            ? AppBar(
                title: const Text('Membership Details'),
                automaticallyImplyLeading: true,
                actions: [
                  isSmallScreen
                      ? widgetFactory.createIcon(
                          materialIcon: Icons.refresh,
                          onPressed: () {
                            viewmodel.getMembershipDetails(viewmodel.selectedMembership.value!.id!);
                          })
                      : const SizedBox.shrink(),
                ],
                bottom: buildTabBar())
            : buildTabBar(),
        body: TabBarView(
          children: [
            // Overview Tab
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  widgetFactory.createButton(
                      context: context,
                      content: const Text("Create New membership"),
                      onPressed: () {
                        viewmodel.navigateToCreateMember(context);
                      }),
                  widgetFactory.createText(context, 'Benefits', style: Theme.of(context).textTheme.titleMedium),
                  buildMembershipBenefits(),
                ],
              ),
            ),
            // Products Tab
            buildMembershipMembersProducts(context),
            // Members Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Members',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      viewmodel.filterCustomersByName(value);
                    },
                  ),
                ),
                Expanded(child: buildMembershipCustomers(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (viewmodel.isMembershipDetailsLoading.value) const LinearProgressIndicator(),
            const TabBar(
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Products'),
                Tab(text: 'Members'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMembershipBenefits() {
    return widgetFactory.createCard(
      child: AppGridView(
        shrinkWrap: true,
        crossAxisCount: 2,
        itemExtent: 50,
        items: viewmodel.selectedMembershipBenefits,
        itemBuilder: (context, benefit, index) {
          return Row(
            children: [
              widgetFactory.createIcon(materialIcon: Icons.check_circle, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              widgetFactory.createText(context, benefit.name.localize(viewmodel.selectedLanguage)),
            ],
          );
        },
      ),
    );
  }

  Widget buildMembershipMembersProducts(BuildContext context) {
    return AppGridView(
      shrinkWrap: true,
      itemExtent: 230,
      crossAxisCount: Responsive.getGridCount(context, itemWidth: 300),
      items: viewmodel.selectedMembershipProducts,
      itemBuilder: (context, item, index) {
        return HomeProductListItem(
          product: item,
          widgetFactory: widgetFactory,
          selectedCurrency: viewmodel.appViewmodel.selectedCurrency,
          badgeInfos: item.getBadgeInfos(forPOS: true),
        );
      },
    );
  }

  Widget buildMembershipCustomers(BuildContext context) {
    return Obx(() {
      return AppListView(
        shrinkWrap: true,
        items: viewmodel.filteredMembershipCustomers.value,
        itemBuilder: (context, item, index) {
          return CustomerListItem(
            customer: item,
            memberships: viewmodel.selectedMembership.value != null ? [viewmodel.selectedMembership.value!] : const [],
            widgetFactory: widgetFactory,
            onSelected: () {},
            actions: viewmodel.getMembersAction(item),
            onActionClick: (value) {
              viewmodel.getMembersAction(item).firstWhereOrNull((action) => action.value == value)?.onPressed?.call(context);
            },
          );
        },
      );
    });
  }
}
