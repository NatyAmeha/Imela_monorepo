import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/cart/reward_apply/viewmodel.apply_reward.dart';
import 'package:imela/presentation/ui/loyalty/components/reward_list_item.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class ApplyRewardPage extends StatefulWidget {
  static const routeName = '/apply-reward';
  static const REWARDS_KEY = 'rewards';
  static const REMAINING_POINT_KEY = 'remainingPoint';
  static const SELECTED_REWARD_KEY = 'selectedReward';

  final List<Reward> rewards;
  final double remainingPoint;
  final List<SelectedRewardInfo> selectedReward;
  const ApplyRewardPage({super.key, required this.rewards, this.remainingPoint = 0, this.selectedReward = const []});

  @override
  State<ApplyRewardPage> createState() => _ApplyRewardPageState();

  static void navigateTo(BuildContext context, List<Reward> rewards, {double remainingPoint = 0, List<SelectedRewardInfo> selectedReward = const []}) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName, extra: {ApplyRewardPage.REWARDS_KEY: rewards, ApplyRewardPage.REMAINING_POINT_KEY: remainingPoint, ApplyRewardPage.SELECTED_REWARD_KEY: selectedReward});
  }
} 

class _ApplyRewardPageState extends State<ApplyRewardPage> {
  late WidgetFactory widgetFactory;
  ApplyRewardViewModel viewModel = ApplyRewardViewModel.getInstance();

  @override
  void initState() {
    super.initState();
    widgetFactory = viewModel.appController.getWidgetFactory(context);
    viewModel.initViewmodel(data: {
      ApplyRewardPage.REWARDS_KEY: widget.rewards,
      ApplyRewardPage.REMAINING_POINT_KEY: widget.remainingPoint,
      ApplyRewardPage.SELECTED_REWARD_KEY: widget.selectedReward,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Rewards'),
        leading: widgetFactory.createIcon(
            materialIcon: Icons.close,
            onPressed: () {
              viewModel.navigateBack(context);
            }),
      ),
      body: Obx(
        () => PageContentLoader(
          showContent: true,
          isLoading: false,
          hasError: false,
          onTryAgain: () {},
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Text('${viewModel.appController.usedRewardPoints.toString()} ${viewModel.appController.remainingPoints.toString()} ${viewModel.appController.selectedBusinessLoyaltyInfo.value?.tier?.min}'),
              if (viewModel.rewards.value.isEmpty)
                _buildNoRewardsFound() 
              else 
                AppListView(
                  items: viewModel.rewards.value,
                  // shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, reward, index) {
                    return Obx(
                      () => RewardListItem(
                        reward: reward,
                        width: Responsive.getWidth(context, small: MediaQuery.sizeOf(context).width, medium: MediaQuery.sizeOf(context).width, large: MediaQuery.sizeOf(context).width),
                        remainingPoint: viewModel.remainingPoint.value,
                        selectedLanguage: viewModel.selectedLanguage,
                        selectedProducts: viewModel.getSelectedProducts(reward.id),
                        isRedeemed: viewModel.isRewardSelected(reward),
                        enableRedeemFlow: true,
                        isLocked: viewModel.selectedBusinessLoyaltyTier?.canUseRewardsFromTier(viewModel.remainingPoints) ?? true,
                        selectedRewardsInfo: viewModel.selectedRewardsInfo.firstWhereOrNull((info) => info.reward.id == reward.id),
                        onProductTap: (product) {
                          viewModel.handleProductOptionAndConfig(context, reward, product);
                        },
                        onRedeemTap: () {
                          viewModel.handleRedeemTap(context, reward);
                        },
                        onRemoveTap: () {
                          viewModel.removeSelectedReward(context, reward);
                        },
                      ),
                    );
                  },
                ),
              if (viewModel.rewards.value.isNotEmpty) ...[
                // const Spacer(),
                widgetFactory.createButton(
                  context: context,
                  content: const Text('Apply Rewards'),
                  onPressed: () => viewModel.applyRewards(context),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoRewardsFound() {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widgetFactory.createIcon(materialIcon: Icons.hourglass_empty, color: Colors.grey, size: 48),
        const SizedBox(height: 8),
        widgetFactory.createText(context, 'No reward found', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
        widgetFactory.createText(context, 'You have no rewards to apply on your order. You should accumulate more points to apply rewards', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        widgetFactory.createButton(
          context: context,
          content: const Text('See all rewards'),
          style: AppButtonStyle.outlinedButtonStyle(context),
          onPressed: () {
            viewModel.navigateToLoyaltyTierPage(context);
          },
        )
      ],
    ).paddingAll(16);
  }
}
