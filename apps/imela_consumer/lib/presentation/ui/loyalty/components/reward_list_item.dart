import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class RewardListItem extends StatelessWidget {
  final Reward reward;
  final String selectedLanguage;
  final double width;
  final double? height;
  RewardListItem({
    super.key,
    required this.reward,
    required this.selectedLanguage,
    this.width = double.infinity,
    this.height,
  });
  late WidgetFactory widgetFactory;

  List<LocalizedField> get selectedConditionByLanguage => reward.conditions?.where((element) => element.key == selectedLanguage).toList() ?? [];

  @override
  Widget build(BuildContext context) {
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return Stack(
      children: [
        widgetFactory.createCard(
          width: width,
          height: height,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(16),
          border: Border.all(color: Theme.of(context).primaryColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widgetFactory.createText(context, reward.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleMedium),
              widgetFactory.createText(context, reward.getDiscountInfo(selectedLanguage), style: Theme.of(context).textTheme.titleSmall),
              const Divider(),
              if (reward.description != null) widgetFactory.createText(context, reward.description?.localize(selectedLanguage) ?? '', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 16),
              if (selectedConditionByLanguage.isNotEmpty) _buildConditionList(context, reward, selectedLanguage),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: widgetFactory.createCard(
            padding: const EdgeInsets.all(6),
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), topRight: Radius.circular(16)),
            color: ColorManager.tertiary,
            child: widgetFactory.createText(context, reward.redeemPointString(), style: Theme.of(context).textTheme.bodyLarge, color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget _buildConditionList(BuildContext context, Reward reward, String selectedLanguage) {
    return ListView(
      shrinkWrap: true,
      children: selectedConditionByLanguage.map((e) {
        return Row(
          children: [
            widgetFactory.createIcon(materialIcon: Icons.radio_button_checked, size: 16, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Expanded(child: widgetFactory.createText(context, e.value!, style: Theme.of(context).textTheme.bodyMedium)),
          ],
        );
      }).toList(),
    );
  }
}
