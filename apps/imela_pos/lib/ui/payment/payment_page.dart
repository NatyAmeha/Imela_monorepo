import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/payment/component/payment_method_input_component.dart';
import 'package:imela_pos/ui/payment/component/payment_options_component.dart';
import 'package:imela_pos/ui/payment/payment_page.viewmodel.dart';

class PaymentPage extends StatefulWidget {
  static const routeName = '/payment';
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _PaymentPageState extends State<PaymentPage> {
  final viewmodel = PaymentPageViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Payment'),
        ),
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Obx(
                () => PaymentOptionsComponent(
                  paymentOptions: viewmodel.paymentOptions,
                  selectedPaymentOptionId: viewmodel.selectedPaymentOption.value?.id,
                  viewmodel: viewmodel,
                  checkSelectedPaymentOptiontype: (paymentOptionType) => viewmodel.checkSelectedPaymentOptiontype(paymentOptionType),
                  onChanged: (value) {
                    viewmodel.updateSelectedPaymentOption(value);
                  },
                  onDueDateSelected: () {
                    viewmodel.showDuedateSelector(context, widgetFactory);
                  },
                  selectedDueDateString: viewmodel.selectedDueDate.value?.toLocal().toString(),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Obx(
                () => PaymentMethodInputComponent(
                  controller: viewmodel.paymentMethodAmountController,
                  paymentMethods: viewmodel.paymentMethods,
                  paymentMethodsIdsWithAmount: viewmodel.enteredPayments,
                  selectedLanguage: viewmodel.appViewmodel.selectedLanguage,
                  selectedPaymentMethodId: viewmodel.selectedPaymentMethodId.value,
                  onSelected: (paymentMethod) {
                    viewmodel.selectPaymentMethod(paymentMethod);
                  },
                  onDelete: (paymentMethod) {
                    viewmodel.removeEntredAmount(paymentMethod);
                  },
                  paidAmount: viewmodel.totalPaidAmount.toString(),
                  remainingAmount: viewmodel.remainingAmountFromInitialPayment.toString(),
                  onPlaceOrderPressed: () {},
                ),
              ),
            )
          ],
        ));
  }
}
