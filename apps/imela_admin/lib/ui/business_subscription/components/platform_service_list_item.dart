import 'package:flutter/material.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_core/subscription/model/platform_service.model.dart';

class PlatformServiceListItem extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final PlatformService platformService;
  final String selectedLanguage;
  final String currency;
  final Function? onSelected;
  final double width;
  final double? height;
  const PlatformServiceListItem({
    super.key,
    required this.widgetFactory,
    required this.platformService,
    required this.selectedLanguage,
    required this.currency,
    this.width = double.infinity,
    this.height,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      width: width,
      height: height,
      border: Border.all(color: Theme.of(context).colorScheme.primary),
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widgetFactory.createText(context, platformService.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          widgetFactory.createText(context, platformService.getBasePriceString(currency), style: Theme.of(context).textTheme.titleMedium, color: Theme.of(context).colorScheme.tertiary),
          const SizedBox(height: 10),
          widgetFactory.createText(context, platformService.description.localize(selectedLanguage), style: Theme.of(context).textTheme.labelLarge),
         const SizedBox(height: 24),
          Row(
            children: [
              widgetFactory.createIcon(materialIcon: Icons.check_circle, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(child: widgetFactory.createText(context, 'Options: ${platformService.renewalOptionsString()}', style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              widgetFactory.createIcon(materialIcon: Icons.check_circle, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(child: widgetFactory.createText(context, 'Price: ${platformService.getBasePriceString(currency)}', style: Theme.of(context).textTheme.bodyMedium)),
            ],
          ),
          const Spacer(),
          widgetFactory.createButton(
            context: context,
            content: const Text('View details'),
            onPressed: () {
              onSelected?.call();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
