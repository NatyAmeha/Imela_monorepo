import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/payment/components/payment_method_list_item.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_core/business/model/payment_method.model.dart';

class PaymentMethodListModal extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;
  final PaymentMethod? initialPaymentMethod;
  final Function(PaymentMethod)? onContinuePressed;
  const PaymentMethodListModal({super.key, required this.paymentMethods, this.initialPaymentMethod, this.onContinuePressed});

  @override
  State<PaymentMethodListModal> createState() => _PaymentMethodListModalState();
}

class _PaymentMethodListModalState extends State<PaymentMethodListModal> {
  PaymentMethod? selectedPaymentMethod;
  String? get selectedPaymentMethodId => selectedPaymentMethod?.id;
  bool get isSelected => selectedPaymentMethod != null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedPaymentMethod = widget.initialPaymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widgetFactory.createText(context, 'Choose payment method', style: Theme.of(context).textTheme.titleLarge),
          AppListView(
            shrinkWrap: true,
            primary: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            items: widget.paymentMethods,
            itemBuilder: (context, paymentMethod, index) {
              return PaymentMethodListItem(
                paymentMethod: paymentMethod,
                selectedPaymentId: selectedPaymentMethodId,
                widgetFactory: widgetFactory,
                onSelected: (selectedPayment) {
                  setState(() {
                    selectedPaymentMethod = selectedPayment;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 32),
          widgetFactory.createButton(context: context, content: Text("continue"), onPressed: isSelected ? () => widget.onContinuePressed?.call(selectedPaymentMethod!) : null),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
