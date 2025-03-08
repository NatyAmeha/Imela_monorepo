import 'package:flutter/material.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/payment/component/payment_method_list_item.dart';
import 'package:imela_pos/ui/payment/payment_page.viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';

class PaymentMethodInputComponent extends StatelessWidget {
  final TextEditingController controller;
  final List<PaymentMethod> paymentMethods;
  final String selectedLanguage;
  final String paidAmount;
  final String remainingAmount;
  final String callToActionText;
  final PaymentMethod? selectedPaymentMethod;
  final Function(PaymentMethod) onDelete;
  final Function(PaymentMethod) onSelected;
  final Function(String) onAmountChanged;
  final Function(String, PaymentMethodOption) onOptionChanged;
  final bool canEnablePlaceOrder;
  final Map<String, TextEditingController> paymentMethodControllers;
  final Function()? onCallToAction;
  PaymentMethodInputComponent({
    super.key,
    required this.controller,
    required this.paymentMethods,
    required this.selectedLanguage,
    required this.onDelete,
    required this.paidAmount,
    required this.remainingAmount,
    this.callToActionText = 'Place Order',
    this.selectedPaymentMethod,
    required this.onSelected,
    required this.canEnablePlaceOrder,
    required this.paymentMethodControllers,
    required this.onAmountChanged,
    required this.onOptionChanged,
    this.onCallToAction,
  });

  final paymentViewmodel = PaymentPageViewmodel.getInstance();

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
      // padding: Responsive.paddingSymetric(context, smallHorizontal: 0, smallVertical: 0, largeHorizontal: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widgetFactory.createText(context, 'Payment Method', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          widgetFactory.createText(context, 'Choose one or more payment methods. you can use multiple payment methods for a single order', style: Theme.of(context).textTheme.bodyMedium),
          AppListView(
            items: paymentMethods,
            primary: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            shrinkWrap: true,
            itemBuilder: (context, paymentMethod, index) {
              return PaymentMethodListItem(
                paymentMethod: paymentMethod,
                selectedLanguage: selectedLanguage,
                isSelected: isSelected(paymentMethod),
                controller: paymentMethodControllers[paymentMethod.id] ?? TextEditingController(),
                remainingAmountString: remainingAmount,
                showRemainingAmount: true,
                widgetFactory: widgetFactory,
                onSelected: () {
                  onSelected(paymentMethod);
                },
                onDelete: () {
                  onDelete(paymentMethod);
                },
                onAmountChanged: (value) {
                  onAmountChanged(value);
                },
                onOptionChanged: (paymentMethodId, option) {
                  onOptionChanged(paymentMethodId, option);
                },
              );
            },
          ),
          const Divider(height: 40),
          Row(
            children: [
              widgetFactory.createText(context, 'Total Amount', style: Theme.of(context).textTheme.titleLarge),
              widgetFactory.createText(context, '${paidAmount} SAR', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              widgetFactory.createText(context, 'Remaining Amount', style: Theme.of(context).textTheme.titleLarge),
              widgetFactory.createText(context, '${remainingAmount} SAR', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          widgetFactory.createButton(context: context, content: Text(callToActionText), onPressed: () {
            onCallToAction?.call();
          }),
        ],
      ),
    );
  }

  

  bool isSelected(PaymentMethod paymentMethod) {
    return paymentMethod.id == selectedPaymentMethod?.id;
  }
}
