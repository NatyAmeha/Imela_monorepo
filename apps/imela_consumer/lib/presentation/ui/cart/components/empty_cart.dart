import 'package:flutter/material.dart';
import 'package:imela/l10n/l10n.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class EmptyCartCard extends StatelessWidget {
  final WidgetFactory widgetFactory;
  const EmptyCartCard({super.key, required this.widgetFactory});

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widgetFactory.createIcon(materialIcon: Icons.hourglass_empty_outlined, size: 100),
          const SizedBox(height: 16),
          widgetFactory.createText(context, AppLocalizations.of(context).yourCartIsEmpty, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          widgetFactory.createText(context, AppLocalizations.of(context).addItemsToCart, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
