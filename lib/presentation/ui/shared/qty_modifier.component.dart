import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';

class QuantityModifierComponent extends StatelessWidget {
  final double? width;
  final double? height;
  final double currentQty;
  final bool addQtyDisabled;
  final bool deductQtyDisabled;
  final Function onQtyChange;
  final WidgetFactory widgetFactory;
  const QuantityModifierComponent({
    super.key,
    this.width,
    this.height,
    required this.currentQty,
    this.addQtyDisabled = false,
    this.deductQtyDisabled = false,
    required this.onQtyChange,
    required this.widgetFactory,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      width: width,
      borderRadius: BorderRadius.circular(32),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            widgetFactory.createIcon(
              materialIcon: Icons.remove_circle_outline,
              cupertinoIcon: CupertinoIcons.minus_circle,
              showIconOnly: false,
              onPressed: deductQtyDisabled
                  ? null
                  : () {
                      onQtyChange(currentQty - 1);
                    },
            ),
            const Spacer(),
            widgetFactory.createText(context, currentQty.toString(), style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            widgetFactory.createIcon(
                materialIcon: Icons.add,
                cupertinoIcon: CupertinoIcons.add,
                backgroundColor: Colors.transparent,
                showIconOnly: false,
                onPressed: addQtyDisabled
                    ? null
                    : () {
                        onQtyChange(currentQty + 1);
                      }),
          ],
        ),
      ),
    );
  }
}
