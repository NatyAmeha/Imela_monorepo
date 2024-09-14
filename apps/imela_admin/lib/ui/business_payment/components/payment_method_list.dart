import 'package:flutter/material.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';

class PaymentMethodList extends StatelessWidget {
  final double? height;
  final double width;
  final List<PaymentMethod> paymentMethods;
  final String? selectedPaymentMethodId;
  final bool Function(PaymentMethod) isSelected;
  final Function(String? id)? onSelected;
  final Function? onContinue;

  const PaymentMethodList({
    super.key,
    required this.paymentMethods,
    required this.isSelected,
    this.selectedPaymentMethodId,
    this.width = double.infinity,
    this.height = 200.0,
    this.onSelected,
    this.onContinue,
  });

  String get selectedLanguage => AppViewmodel.getInstance().selectedLanguage;

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widgetFactory.createText(context, 'Payment methods', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          AppListView(
            shrinkWrap: true,
            items: paymentMethods,
            itemBuilder: (context, method, index) {
              final selectedColor = isSelected(method) ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primaryContainer;
              return widgetFactory.createCard(
                borderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                border: Border.all(color: selectedColor),
                child: widgetFactory.createRadioListTile(context, title: method.name.localize(selectedLanguage), value: method.id, groupValue: selectedPaymentMethodId, onChanged: (value) {
                  onSelected?.call(value);
                }),
              );
            },
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              widgetFactory.createIcon(materialIcon: Icons.lightbulb_sharp, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(child: widgetFactory.createText(context, 'You are eligable for free tier access of selected services', style: Theme.of(context).textTheme.titleSmall)),
            ],
          ),
          const SizedBox(height: 24),
          widgetFactory.createButton(
            context: context,
            content: const Text('Continue'),
            onPressed: () {
              onContinue?.call();
            },
          )
        ],
      ),
    );
  }
}
