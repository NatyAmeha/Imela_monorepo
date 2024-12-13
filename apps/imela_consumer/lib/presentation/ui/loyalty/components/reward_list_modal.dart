import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/loyalty/components/eligable_reward_list_item.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';

class RewardListModal extends StatefulWidget {
  final CustomerLoyalty? customerLoyalty;
  final List<Reward> eligibleRewards;
  final List<Reward> allRewards;
  final bool isLoading;
  final Function(Reward) onRewardSelected;
  RewardListModal({
    super.key,
    this.customerLoyalty,
    required this.eligibleRewards,
    required this.allRewards,
    required this.onRewardSelected,
    this.isLoading = true,
  });

  @override
  State<RewardListModal> createState() => _RewardListModalState();
}

class _RewardListModalState extends State<RewardListModal> {
  final selectedLanguage = AppController.getInstance.selectedLanguage.name;
  bool get enableSelectReward => widget.eligibleRewards.isNotEmpty;
  bool get isRewardSelected => selectedReward != null;
  Reward? selectedReward;

  bool get isLoading => widget.isLoading && (widget.allRewards.isEmpty || widget.eligibleRewards.isEmpty);

  @override
  Widget build(BuildContext context) {
    final widgetfactory = AppController.getInstance.getWidgetFactory(context);
    return widgetfactory.createCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            if (!enableSelectReward) ...[
              widgetfactory.createCard(
                padding: const EdgeInsets.all(8),
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: widgetfactory.createText(
                  context,
                  'No eligable rewards available. You have insufficient points to redeem any rewards.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              widgetfactory.createText(context, 'Available Rewards', style: Theme.of(context).textTheme.titleLarge),
              AppListView(
                shrinkWrap: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                items: widget.allRewards,
                itemBuilder: (context, reward, index) {
                  return EligableRewardListItem(
                    reward: reward,
                    selectedLanguage: selectedLanguage,
                    isSelected: isSelected(reward),
                    isLocked: !enableSelectReward,
                    widgetFactory: widgetfactory,
                    onTap: enableSelectReward
                        ? (reward) {
                            setState(() {
                              selectedReward = reward;
                            });
                          }
                        : null,
                  );
                },
              ),
            ],
            AppListView(
              shrinkWrap: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              items: widget.eligibleRewards,
              itemBuilder: (context, reward, index) {
                return EligableRewardListItem(
                  reward: reward,
                  selectedLanguage: selectedLanguage,
                  isSelected: isSelected(reward),
                  widgetFactory: widgetfactory,
                  onTap: enableSelectReward
                      ? (reward) {
                          setState(() {
                            selectedReward = reward;
                          });
                        }
                      : null,
                );
              },
            ),
            const SizedBox(height: 24),
            if (enableSelectReward)
              widgetfactory.createButton(
                context: context,
                content: const Text('Select Reward'),
                onPressed: isRewardSelected
                    ? () {
                        if (selectedReward != null) {
                          widget.onRewardSelected(selectedReward!);
                        }
                      }
                    : null,
              ),
            if (isLoading) ...[
              // const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
              ).withPaddingSymetric(vertical: 16)
            ],
          ],
        ),
      ),
    );
  }

  bool isSelected(Reward reward) {
    var a = selectedReward?.id == reward.id;
    return a;
  }
}
