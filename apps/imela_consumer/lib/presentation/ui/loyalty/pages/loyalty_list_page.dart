import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/loyalty/components/loyalty_list_item.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_list_viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';

class LoyaltyListPage extends StatefulWidget {
  static const routeName = '/loyalty-list';
  const LoyaltyListPage({super.key});

  @override
  State<LoyaltyListPage> createState() => _LoyaltyListPageState();

  static void navigate(BuildContext context) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName);
  }
}

class _LoyaltyListPageState extends State<LoyaltyListPage> {
  final viewmodel = LoyaltyListViewModel.getInstance();
  final selectedLanguage = AppController.getInstance.selectedLanguage.name;

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Loyalties")),
      body: Obx(
        () => PageContentLoader(
          showContent: viewmodel.customerLoyalties.isNotEmpty,
          isDataLoading: viewmodel.isLoading.value,
          exception: viewmodel.exception.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          content: AppListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            items: viewmodel.customerLoyalties,
            itemBuilder: (context, loyalty, item) {
              return LoyaltyListItem(
                customerLoyalty: loyalty,
                selectedLanguage: selectedLanguage,
                onTap: () {
                  viewmodel.navigateToLoyaltyDetails(context, loyalty);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
