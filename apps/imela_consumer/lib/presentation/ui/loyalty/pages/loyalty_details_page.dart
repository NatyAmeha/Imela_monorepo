import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/loyalty/components/loyalty_list_item.dart';
import 'package:imela/presentation/ui/loyalty/components/reward_list_item.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_details_viewmodel.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class LoyaltyDetailsPage extends StatefulWidget {
  static const routeName = '/loyalty-details';
  static const LOYALTY_INFO_KEY = 'LOAYTY_INFO_KEY';
  static const PROGRAM_NAME_KEY = 'PROGRAM_NAME_KEY';
  static const BUSINESS_ID_KEY = 'BUSINESS_ID_KEY';
  static const COLOR_KEY = 'COLOR_KEY';
  static const CONTEXT_KEY = 'CONTEXT_KEY';
  static const TIER_ID_KEY = 'TIER_ID_KEY';

  final String programName;
  final String businessId;
  final String? tierId;
  final Color? color;

  const LoyaltyDetailsPage({
    super.key,
    required this.programName,
    required this.businessId,
    this.tierId,
    this.color,
  });

  static void navigate(BuildContext context, {required String programName, required String businessId, String? tierId, Color? color}) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName, extra: {PROGRAM_NAME_KEY: programName, BUSINESS_ID_KEY: businessId, TIER_ID_KEY: tierId, COLOR_KEY: color});
  }

  @override
  State<LoyaltyDetailsPage> createState() => _LoyaltyDetailsPageState();
}

class _LoyaltyDetailsPageState extends State<LoyaltyDetailsPage> {
  final viewmodel = LoyaltyDetailsViewmodel.getInstance();
  final selectedLanguage = AppController.getInstance.selectedLanguage.name;
  late WidgetFactory widgetFactory;

  void initializeViewmodel() {
    viewmodel.initViewmodel(data: {
      LoyaltyDetailsPage.CONTEXT_KEY: context,
      LoyaltyDetailsPage.BUSINESS_ID_KEY: widget.businessId,
      LoyaltyDetailsPage.TIER_ID_KEY: widget.tierId,
    });
  }

  @override
  void initState() {
    super.initState();
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reward Details')),
      body: Obx(() {
        return PageContentLoader(
          showContent: viewmodel.loyaltyDetail.value != null,
          isLoading: viewmodel.isLoading.value,
          exception: viewmodel.exception.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          onTryAgain: () {
            viewmodel.getBusinessLoyaltyDetailsWithCustomerInfo(context, widget.businessId, widget.tierId);
          },
          content: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (viewmodel.customerLoyaltyInfo != null) ...[
                  LoyaltyListItem(customerLoyalty: viewmodel.customerLoyaltyInfo!, loyaltyTier: viewmodel.customerTier.value, selectedLanguage: selectedLanguage, color: widget.color, showSeeRewardBtn: false).withPaddingSymetric(vertical: 8),
                ],
                if (viewmodel.loyaltyDetail.value?.tier != null) ...[
                  _buildTierInfoSection(),
                  const SizedBox(height: 16),
                  _buildProductListSection(),
                  const SizedBox(height: 16),
                  _buildRewardList(context),
                  const SizedBox(height: 160),
                ] else ...[
                  buildErrorSection()
                ]
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTierInfoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        widgetFactory.createText(context, viewmodel.loyaltyDetail.value?.tier?.name?.localize(selectedLanguage) ?? '', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        widgetFactory.createText(context, viewmodel.loyaltyDetail.value?.tier?.description?.localize(selectedLanguage) ?? '', style: Theme.of(context).textTheme.labelLarge),
        const Divider(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: widgetFactory.createText(context, 'Point required to reach this tier: ', style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.start)),
            Expanded(child: widgetFactory.createText(context, '${viewmodel.loyaltyDetail.value?.tier?.minPoints ?? 0} points', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.end)),
          ],
        ).paddingSymmetric(vertical: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: widgetFactory.createText(context, 'Available rewards: ', style: Theme.of(context).textTheme.titleSmall)),
            Expanded(child: widgetFactory.createText(context, '${viewmodel.loyaltyDetail.value?.tier?.rewards?.length ?? 0} rewards', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.end)),
          ],
        ),
        const Divider(height: 24),
        _buildBusinessListSection(),
      ],
    );
  }

  Widget _buildBusinessListSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (viewmodel.loyaltyBusinesses.isEmpty) ...[
          const SizedBox.shrink()
        ] else ...[
          const SizedBox(height: 8),
          widgetFactory.createText(context, 'Businesses', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...viewmodel.loyaltyBusinesses.map(
            (e) {
              return Row(
                children: [
                  AppImage(
                    imageUrl: e.gallery?.getImage(),
                    borderRadius: BorderRadius.circular(100),
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 8),
                  widgetFactory.createText(context, e.name.localize(selectedLanguage), style: Theme.of(context).textTheme.bodyMedium),
                ],
              );
            },
          )
        ]
      ],
    );
  }

  Widget _buildProductListSection() {
    return Column(
      children: [
        if (viewmodel.customerTier.value?.productIds?.isEmpty ?? false) ...[
          widgetFactory.createCard(
            child: Row(
              children: [
                widgetFactory.createIcon(materialIcon: Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                widgetFactory.createText(context, "Rewards in this tier will be available on all products.", style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          )
        ],
      ],
    );
  }

  Widget _buildRewardList(BuildContext context) {
    return AppListView(
      primary: false,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widgetFactory.createText(context, "Rewards", style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
      shrinkWrap: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      items: viewmodel.loyaltyRewards,
      itemBuilder: (context, reward, index) {
        return RewardListItem(
          reward: reward,
          selectedLanguage: selectedLanguage,
          enableRedeemFlow: false,
          height: viewmodel.getRewardHeight(reward),
        );
      },
    );
  }

  Widget buildErrorSection() {
    return Column(
      children: [
        const SizedBox(height: 16),
        widgetFactory.createIcon(materialIcon: Icons.credit_card_off_outlined, color: Theme.of(context).colorScheme.secondary, size: 60),
        const SizedBox(height: 8),
        widgetFactory.createText(context, 'Insufficient points to redeem rewards', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        widgetFactory.createText(
          context,
          'Your current points isn\'t enough to join a reward program and redeem rewards. Please check your points and try again.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        widgetFactory.createButton(
          context: context,
          content: const Text('See business reward programs'),
          style: AppButtonStyle.outlinedButtonStyle(context),
          onPressed: () {
            viewmodel.goToBusinessRewardPrograms(context);
          },
        ),
      ],
    );
  }
}
