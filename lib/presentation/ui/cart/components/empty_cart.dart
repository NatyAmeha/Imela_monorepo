import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';

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
          widgetFactory.createText(context, 'Your cart is empty', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          widgetFactory.createText(context, 'Add items to your cart to get started', style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
