import 'package:flutter/material.dart';
import 'package:imela_pos/app/app_viewmodel.dart';

class CartBottomNav extends StatelessWidget {
  final String totalAmountString;
  final String totalItemsString;
  final Function onTap;
  const CartBottomNav({super.key, required this.totalAmountString, required this.totalItemsString, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
      onTap: () => onTap(),
      borderRadius: BorderRadius.zero,
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widgetFactory.createText(context, totalItemsString, style: Theme.of(context).textTheme.titleSmall),
                  widgetFactory.createText(context, totalAmountString, style: Theme.of(context).textTheme.titleMedium, color: Colors.white),
                ],
              ),
              widgetFactory.createIcon(materialIcon: Icons.keyboard_arrow_right, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }
}
