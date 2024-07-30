import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';

class QuantityModifierComponent extends StatelessWidget {
  final double? width;
  final double? height;
  final double currentQty;
  final Function onQtyChange; 
  final WidgetFactory widgetFactory;
  const QuantityModifierComponent({
    super.key, 
    this.width,
    this.height,
    required this.currentQty,
    required this.onQtyChange,
    required this.widgetFactory,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          widgetFactory.createIcon(
            materialIcon: Icons.remove,
            onPressed: () {
              onQtyChange(currentQty - 1);
            },
          ),
          widgetFactory.createText(context, currentQty.toString(), style: Theme.of(context).textTheme.titleMedium),
          widgetFactory.createIcon(
            materialIcon: Icons.add,
            onPressed: () {
              onQtyChange(currentQty + 1);
            },
          ),
        ],
      ),
    );
  }
}
