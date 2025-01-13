import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/membership/components/membership_list_item.dart';
import 'package:imela/presentation/ui/membership/membership_plan_list/memership_plan_list_viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';

class MembershipPlanListPage extends StatefulWidget {
  static const routeName = "/membership-plan-list";
  static const BUSINESS_ID_KEY = "BUSINESS_ID";
  final String businessId;
  const MembershipPlanListPage({super.key, required this.businessId});

  @override
  State<MembershipPlanListPage> createState() => _MembershipPlanListPageState();

  static void navigate(BuildContext context, String businessId) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName, extra: {BUSINESS_ID_KEY: businessId});
  }
}

class _MembershipPlanListPageState extends State<MembershipPlanListPage> {
  final viewmodel = MembershipPLanListViewModel.getInstance();
  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel(data: {MembershipPlanListPage.BUSINESS_ID_KEY: widget.businessId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Membership Plans")),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          showContent: viewmodel.membershipPlans.value.isNotEmpty,
          content: Column(
            children: [
              AppListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                items: viewmodel.membershipPlans.value,
                itemBuilder: (context, item, index) {
                  return MembershipListItem(
                    membershipInfo: item,
                    selectedLanguage: viewmodel.selectedLanguage,
                    onTap: () => viewmodel.navigateToMembershipDetails(context, item),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
