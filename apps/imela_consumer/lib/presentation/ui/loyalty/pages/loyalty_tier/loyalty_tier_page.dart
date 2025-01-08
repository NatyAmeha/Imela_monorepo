import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/loyalty/components/loyalty_tier_list_item.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_tier/viewmodel.loyalty_tier.dart';
import 'package:imela_core/loyalty/model/loyalty_tier.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class LoyaltyTierListPage extends StatefulWidget {
  static const routeName = '/loyalty-tier-list';
  static const BUSINESS_ID_KEY = 'businessId';

  final String businessId;

  static const CONTEXT_KEY = 'context';
  const LoyaltyTierListPage({super.key, required this.businessId});

  @override
  State<LoyaltyTierListPage> createState() => _LoyaltyTierListPageState();

  static void navigate(BuildContext context, {required String businessId}) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, LoyaltyTierListPage.routeName, extra: {LoyaltyTierListPage.BUSINESS_ID_KEY: businessId});
  }
}

class _LoyaltyTierListPageState extends State<LoyaltyTierListPage> {
  final LoyaltyTierViewmodel viewmodel = LoyaltyTierViewmodel.getInstance();
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
    viewmodel.initViewmodel(data: {
      LoyaltyTierListPage.CONTEXT_KEY: context,
      LoyaltyTierListPage.BUSINESS_ID_KEY: widget.businessId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reward Program')),
      body: Obx(() {
        return PageContentLoader(
          exception: viewmodel.exception.value,
          isLoading: viewmodel.isLoading.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          onTryAgain: () {
            viewmodel.getBusinessLoyaltyTiers(context);
          },
          showContent: viewmodel.businessLoyalityTiers.value.isNotEmpty,
          content: Column(
            children: [
              const SizedBox(height: 16),
              AppListView(
                height: MediaQuery.sizeOf(context).height * 0.8,
                items: viewmodel.businessLoyalityTiers,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, loyaltyTier, item) {
                  return LoyaltyTierListItem(
                    loyaltyTier: loyaltyTier,
                    widgetFactory: widgetFactory,
                    selectedLanguage: viewmodel.selectedLanguage,
                    onTap: () {
                      viewmodel.navigateToLoyaltyTierDetails(context, loyaltyTier);
                    },
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
