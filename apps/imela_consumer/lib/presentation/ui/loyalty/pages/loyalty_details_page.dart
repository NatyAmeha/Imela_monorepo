import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/loyalty/components/loyalty_list_item.dart';
import 'package:imela/presentation/ui/loyalty/components/reward_list_item.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_details_viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';

class LoyaltyDetailsPage extends StatefulWidget {
  static const routeName = '/loyalty-details';
  static const LOYALTY_INFO_KEY = 'LOAYTY_INFO_KEY';
  static const PROGRAM_NAME_KEY = 'PROGRAM_NAME_KEY';
  static const BUSINESS_ID_KEY = 'BUSINESS_ID_KEY';
  final String programName;
  final String? businessId;
  final LoyaltyResponse? loyaltyInfo;
  const LoyaltyDetailsPage({super.key, required this.programName, this.loyaltyInfo, this.businessId});

  static void navigate(BuildContext context, {required String programName, LoyaltyResponse? loyaltyInfo, String? businessId}) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName, extra: {LOYALTY_INFO_KEY: loyaltyInfo, PROGRAM_NAME_KEY: programName, BUSINESS_ID_KEY: businessId});
  }

  @override
  State<LoyaltyDetailsPage> createState() => _LoyaltyDetailsPageState();
}

class _LoyaltyDetailsPageState extends State<LoyaltyDetailsPage> {
  final viewmodel = LoyaltyDetailsViewmodel.getInstance();
  final selectedLanguage = AppController.getInstance.selectedLanguage.name;

  void initializeViewmodel() {
    viewmodel.initViewmodel(data: {LoyaltyDetailsPage.LOYALTY_INFO_KEY: widget.loyaltyInfo, LoyaltyDetailsPage.BUSINESS_ID_KEY: widget.businessId});
  }

  @override
  void initState() {
    super.initState();
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.programName)),
      body: Obx(
        () => PageContentLoader(
          showContent: viewmodel.loyaltyDetail.value != null,
          isDataLoading: viewmodel.isLoading.value,
          exception: viewmodel.exception.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          onTryAgain: () {
            viewmodel.getCustomerBusinessLoyalty(widget.loyaltyInfo, widget.businessId);
          },
          content: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (viewmodel.customerLoyaltyInfo != null) ...[
                  LoyaltyListItem(customerLoyalty: viewmodel.customerLoyaltyInfo!, selectedLanguage: selectedLanguage).withPaddingSymetric(vertical: 8),
                ],
                if (viewmodel.loyaltyRewards.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  widgetFactory.createText(context, "Rewards", style: Theme.of(context).textTheme.titleMedium),
                  widgetFactory.createText(context, '${widget.programName} loyalty program rewards', style: Theme.of(context).textTheme.labelMedium),
                  AppListView(
                    shrinkWrap: true,
                    primary: false,
                    items: viewmodel.loyaltyRewards,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, reward, index) {
                      return RewardListItem(reward: reward, selectedLanguage: selectedLanguage);
                    },
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
