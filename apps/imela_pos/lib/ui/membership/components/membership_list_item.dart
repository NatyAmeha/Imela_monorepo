import 'package:flutter/material.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class MembershipListItem extends StatelessWidget {
  final Membership membership;
  final WidgetFactory widgetFactory;
  final bool isSelected;
  final Function() onTap;
  const MembershipListItem({
    super.key,
    required this.membership,
    required this.widgetFactory,
    this.isSelected = false,
    required this.onTap,
  });

  String get currency => AppViewmodel.getInstance().selectedCurrency;
  String get selectedLanguage => AppViewmodel.getInstance().selectedLanguage;
  @override
  Widget build(BuildContext context) {
    final selectedColor = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerLow;
    return widgetFactory.createCard(
      onTap: () => onTap(),
      padding: const EdgeInsets.all(16),
      color: selectedColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widgetFactory.createText(context, membership.name.localize(selectedLanguage), style: Theme.of(context).textTheme.titleMedium),
          widgetFactory.createText(context, membership.price.toSelectedPriceString(currency), style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
