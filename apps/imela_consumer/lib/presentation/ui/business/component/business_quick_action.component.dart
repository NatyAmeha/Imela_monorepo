import 'package:flutter/material.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BusinessAddressQuickActionComponenet extends StatelessWidget {
  const BusinessAddressQuickActionComponenet({super.key});

  @override
  Widget build(BuildContext context) {
    var appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return GridView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
      ),
      children: [
        appWidgetFactory.createCard(
          onTap: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              appWidgetFactory.createIcon(
                materialIcon: Icons.call,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                padding: const EdgeInsets.all(8),
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 6),
              appWidgetFactory.createText(context, 'Call', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        appWidgetFactory.createCard(
          onTap: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              appWidgetFactory.createIcon(
                materialIcon: Icons.pin,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                padding: const EdgeInsets.all(8),
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 6),
              appWidgetFactory.createText(context, "Address", style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        appWidgetFactory.createCard(
          onTap: () {},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              appWidgetFactory.createIcon(
                materialIcon: Icons.business,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                padding: const EdgeInsets.all(8),
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 6),
              appWidgetFactory.createText(context, 'Branches', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
