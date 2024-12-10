import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/membership/components/membership_list_item.dart';
import 'package:imela_pos/ui/membership/components/pos_membership_details_component.dart';
import 'package:imela_pos/ui/membership/pos_membership_list.viewmodel.dart';

import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class POSMembershipListPage extends StatefulWidget {
  static const routeName = '/membership_list';
  const POSMembershipListPage({super.key});

  @override
  State<POSMembershipListPage> createState() => _POSMembershipListPageState();

  static void navigateTo(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _POSMembershipListPageState extends State<POSMembershipListPage> {
  var viewmodel = POSMembershipListViewmodel.getInstance();
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewmodel.initViewmodel(data: {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership List', style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            onPressed: () {
              viewmodel.getMemberships(fetchPolicy: ApiDataFetchPolicy.networkOnly);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          exception: viewmodel.exception.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          showContent: viewmodel.membershipList.isNotEmpty && !viewmodel.isLoading.value,
          onTryAgain: () {
            viewmodel.getMemberships();
          },
          content: Row(
            children: [
              Expanded(
                flex: 3,
                child: AppListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  items: viewmodel.membershipList,
                  itemBuilder: (context, membership, index) {
                    return MembershipListItem(
                      membership: membership,
                      widgetFactory: widgetFactory,
                      isSelected: viewmodel.selectedMembership.value == membership,
                      onTap: () {
                        viewmodel.selectMembership(context, membership);
                      },
                    );
                  },
                ),
              ),
              if (!Responsive.isSmallScreen(context))
                Expanded(
                  flex: 2,
                  child: PosMembershipDetailsComponent(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
