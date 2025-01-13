import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/loyalty/model/reward_info.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class RewardListItem extends StatelessWidget {
  final Reward reward;
  final double remainingPoint;
  final String selectedLanguage;
  final SelectedRewardInfo? selectedRewardsInfo;
  final List<Product> selectedProducts;
  final bool enableRedeemFlow;
  final bool isLocked;
  final bool isRedeemed;
  final double width;
  final double? height;

  final Function()? onRedeemTap;
  final Function()? onRemoveTap;
  final Function(RewardProductInfo)? onProductTap;
  RewardListItem({
    super.key,
    required this.reward,
    required this.selectedLanguage,
    this.remainingPoint = 0,
    this.selectedRewardsInfo,
    this.width = double.infinity,
    this.height,
    this.selectedProducts = const [],
    this.enableRedeemFlow = true,
    this.isLocked = true,
    this.isRedeemed = true,
    this.onProductTap,
    this.onRedeemTap,
    this.onRemoveTap,
  });
  late WidgetFactory widgetFactory;

  List<LocalizedField> get selectedConditionByLanguage => reward.conditions?.where((element) => element.key == selectedLanguage).toList() ?? [];
  bool get canRedeemReward => isRedeemed ? true : remainingPoint >= reward.minPointsToRedeem.toDouble();

  @override
  Widget build(BuildContext context) {
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return Stack(
      children: [
        IgnorePointer(
          ignoring: !canRedeemReward || isLocked,
          child: widgetFactory.createCard(
            width: width,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.all(16),
            border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widgetFactory.createText(context, reward.name.localize(selectedLanguage), style: Theme.of(context).textTheme.bodyLarge),
                          if (reward.description?.isNotEmpty ?? false) ...[
                            const SizedBox(height: 4),
                            widgetFactory.createText(context, reward.description.localize(selectedLanguage), style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ],
                      ),
                    ),
                    if (enableRedeemFlow && isLocked) widgetFactory.createIcon(materialIcon: Icons.lock, color: Theme.of(context).primaryColor),
                  ],
                ),
                const Divider(height: 24),
                if (reward.isProductReward()) _buildProductListSection(),
                if (reward.isDeliveryReward()) _buildDeliverySection(context),
                if (reward.isDiscountReward()) _buildDiscountSection(context),
                if (enableRedeemFlow) _buildRedeemSection(context),
              ],
            ),
          ),
        ),
        if (enableRedeemFlow)
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                !canRedeemReward ? widgetFactory.createIcon(materialIcon: Icons.lock, color: Theme.of(context).primaryColor) : const SizedBox.shrink(),
                const SizedBox(width: 8),
                // isRedeemed ? Icon(Icons.radio_button_checked, color: Theme.of(context).primaryColor) : const SizedBox.shrink(),
              ],
            ),
          )
      ],
    );
  }

  Widget _buildProductListSection() {
    if (reward.rewardInfo?.firstOrNull?.products == null) return const SizedBox.shrink();
    return AppListView(
      height: 200,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      contentPadding: const EdgeInsets.only(right: 8),
      items: reward.rewardInfo?.firstOrNull?.products ?? <RewardProductInfo>[],
      itemBuilder: (context, item, index) {
        return GridProductListItem(
          onTap: () {
            onProductTap?.call(item);
          },
          isSelected: selectedProducts.any((p) => p.id == item.product?.id),
          width: 150,
          imageHeight: 100,
          // height: 100,
          discounts: item.discount != null ? [item.discount!] : [],
          product: item.product!,
          widgetFactory: widgetFactory,
        );
      },
    );
  }

  Widget _buildDiscountSection(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            widgetFactory.createIcon(materialIcon: Icons.discount, color: Colors.grey),
            const SizedBox(width: 8),
            widgetFactory.createText(context, reward.getDiscountInfo(selectedLanguage), style: Theme.of(context).textTheme.titleSmall),
          ],
        ).withPaddingSymetric(vertical: 4),
      ],
    );
  }

  Widget _buildRedeemSection(BuildContext context) {
    print('product discount ${remainingPoint}');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widgetFactory.createText(context, getSummaryString(), style: Theme.of(context).textTheme.bodyMedium),
            widgetFactory.createText(context, '${reward.minPointsToRedeem} point used', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(width: 8),
        if (isRedeemed)
          widgetFactory.createButton(
              context: context,
              content: widgetFactory.createText(context, 'Redeemed', style: Theme.of(context).textTheme.bodyMedium),
              onPressed: () {
                onRemoveTap?.call();
              })
        else
          widgetFactory.createButton(
            context: context,
            content: widgetFactory.createText(context, 'Redeem', style: Theme.of(context).textTheme.bodyMedium),
            style: AppButtonStyle.outlinedButtonStyle(context, padding: EdgeInsets.zero),
            onPressed: () {
              onRedeemTap?.call();
            },
          ),
      ],
    );
  }

  String getSummaryString() {
    if (selectedRewardsInfo?.products?.isNotEmpty == true) {
      return '${selectedRewardsInfo?.products?.length} products selected';
    }
    if (selectedRewardsInfo?.discount != null) {
      return '${selectedRewardsInfo?.discount?.value} ${selectedRewardsInfo?.discount?.getDiscountConditionDescription(selectedLanguage)} discount';
    }
    if (selectedRewardsInfo?.deliveryFeeDiscount != null) {
      return '${selectedRewardsInfo?.deliveryFeeDiscount} delivery fee discount';
    }
    return '';
  }

  Widget _buildDeliverySection(BuildContext context) {
    return const SizedBox.shrink();
  }
}
