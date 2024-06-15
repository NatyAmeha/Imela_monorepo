import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';

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
        childAspectRatio: 1.5,
      ),
      
      children: [
        appWidgetFactory.createCard(
          onTap: () {

          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              appWidgetFactory.createIcon(materialIcon: Icons.call, color: Theme.of(context).primaryColor, ),
              const SizedBox(height: 8),
              appWidgetFactory.createText(context, "Call", style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            appWidgetFactory.createIcon(materialIcon: Icons.pin, color: Theme.of(context).primaryColor),
            appWidgetFactory.createText(context, "Address", style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            appWidgetFactory.createIcon(materialIcon: Icons.abc, color: Theme.of(context).primaryColor),
            appWidgetFactory.createText(context, "Branches", style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}
