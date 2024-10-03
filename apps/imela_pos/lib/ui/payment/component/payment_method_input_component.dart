import 'package:flutter/material.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/payment/component/payment_method_list_item.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class PaymentMethodInputComponent extends StatelessWidget {
  final TextEditingController controller;
  final Map<String, double> paymentMethodsIdsWithAmount;
  final List<PaymentMethod> paymentMethods;
  final String selectedLanguage;
  final String paidAmount;
  final String remainingAmount;
  final String? selectedPaymentMethodId;
  final Function(PaymentMethod) onDelete;
  final Function(PaymentMethod) onSelected;
  final Function() onPlaceOrderPressed;
  const PaymentMethodInputComponent({

    super.key,
    required this.controller,
    required this.paymentMethodsIdsWithAmount,
    required this.paymentMethods,
    required this.selectedLanguage,
    required this.onDelete,
    required this.paidAmount,
    required this.remainingAmount,
    required this.onPlaceOrderPressed,
    this.selectedPaymentMethodId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
      padding: Responsive.paddingSymetric(context, largeHorizontal: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widgetFactory.createTextField(controller: controller, hintText: 'Enter amount'),
          const SizedBox(height: 40),
          AppListView(
            items: paymentMethods,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            itemBuilder: (context, paymentMethod, index) {
              return PaymentMethodListItem(
                paymentMethod: paymentMethod,
                amountEntered: paymentMethod.enteredAmount(paymentMethodsIdsWithAmount),
                selectedLanguage: selectedLanguage,
                isSelected: isSelected(paymentMethod),
                onSelected: () {
                  onSelected(paymentMethod);
                  },
                  onDelete: () {
                    onDelete(paymentMethod);
                  });
            },
          ),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Paid Amount', style: Theme.of(context).textTheme.titleSmall),
              widgetFactory.createText(context, paidAmount, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Remaining Amount', style: Theme.of(context).textTheme.titleSmall),
              widgetFactory.createText(context, remainingAmount, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 32),
          widgetFactory
              .createButton(
                  context: context,
                  content: const Text('Place Order'),
                  onPressed: () {
                    onPlaceOrderPressed();
                  })
              .withPaddingSymetric(horizontal: 24)
        ],
      ),
    );
  }

  bool isSelected(PaymentMethod paymentMethod) {
    return paymentMethod.id == selectedPaymentMethodId;
  }
}
