import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/l10n/l10n.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/loyalty/components/loyalty_list_item.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_list_viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';

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
    viewmodel.initViewmodel(data: {
      'context': context,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).yourLoyalties)),
      body: Obx(
        () => PageContentLoader(
          showContent: viewmodel.customerLoyalties.isNotEmpty,
          isLoading: viewmodel.isLoading.value,
          exception: viewmodel.exception.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          onTryAgain: () {
            viewmodel.getCustomerLoyalties(context);
          },
          content: AppListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            items: viewmodel.customerLoyalties,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, loyalty, item) {
              return LoyaltyListItem(
                color: viewmodel.colorLoyaltyCardColors[item % viewmodel.colorLoyaltyCardColors.length],
                customerLoyalty: loyalty,
                selectedLanguage: selectedLanguage,
                onTap: () {
                  viewmodel.navigateToLoyaltyDetail(context, loyalty);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
