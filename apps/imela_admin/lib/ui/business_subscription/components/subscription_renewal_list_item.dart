import 'package:flutter/material.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/subscription/model/subscription_renewal.model.dart';

class SubscriptionRenewalListItem extends StatelessWidget {
  final SubscriptionRenewal subscriptionRenewal;
  final double basePrice;
  final String? selectedPricingOptionId;
  final double width;
  final double? height;
  final Function? onSelected;
  const SubscriptionRenewalListItem({
    super.key, 
    required this.subscriptionRenewal,
    required this.basePrice,
    this.selectedPricingOptionId,
    this.onSelected,
    this.width = double.infinity,
    this.height,
  });

  String get selectedLanguage => AppViewmodel.getInstance().selectedLanguage;
  IconData get selectedIcon => isSelected() ? Icons.check_circle : Icons.radio_button_off_outlined;

  @override
  Widget build(BuildContext context) {
    final Color selectedBorderColor = isSelected() ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer;
    final widgetFactory = AppViewmodel.getWidgetFactory(context);

    return Stack(
      children: [
        widgetFactory.createCard(
          onTap: () {
            onSelected?.call();
          },
          padding: const EdgeInsets.all(16),
          border: Border.all(color: selectedBorderColor),
          color: Theme.of(context).colorScheme.secondaryContainer,
          width: width,
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widgetFactory.createText(context, subscriptionRenewal.name.localize(selectedLanguage), style: Theme.of(context).textTheme.bodyLarge),
              widgetFactory.createText(context, subscriptionRenewal.getTotalPriceString(basePrice), style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              if (subscriptionRenewal.getTotalPrice(basePrice) == 0) ...[
                Row(
                  children: [
                    widgetFactory.createIcon(materialIcon: Icons.free_breakfast, size: 20, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: widgetFactory.createText(context, 'Use for free', style: Theme.of(context).textTheme.bodyMedium)),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  widgetFactory.createIcon(materialIcon: Icons.discount, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: widgetFactory.createText(context, ' ${subscriptionRenewal.discountAmount ?? '10%'}% discount', style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  widgetFactory.createIcon(materialIcon: Icons.do_disturb_alt_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(child: widgetFactory.createText(context, ' ${subscriptionRenewal.duration} days', style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: widgetFactory.createIcon(materialIcon: selectedIcon, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  bool isSelected() {
    return selectedPricingOptionId == subscriptionRenewal.id;
  }
}
