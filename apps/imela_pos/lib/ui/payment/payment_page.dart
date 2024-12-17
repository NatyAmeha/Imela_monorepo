import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/payment/component/payment_callto_action.dart';
import 'package:imela_pos/ui/payment/component/payment_method_input_component.dart';
import 'package:imela_pos/ui/payment/component/payment_options_component.dart';
import 'package:imela_pos/ui/payment/payment_page.viewmodel.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

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
        title: const Text('Payment'),
      ),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          showContent: true,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          exception: viewmodel.exception.value,
          content: Padding(
            padding: Responsive.paddingSymetric(context, smallHorizontal: 0, smallVertical: 0),
            child: Row(
              children: [
                Expanded(
                  flex: Responsive.isLargeOrMediumScreen(context) ? 2 : 3,
                  child: Obx(
                    () => PaymentOptionsComponent(
                      customer: viewmodel.appViewmodel.selectedCustomer.value,
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
                if (!Responsive.isSmallScreen(context))
                  Expanded(
                    flex: Responsive.isMediumScreen(context) ? 3 : 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(
                          () => PaymentMethodInputComponent(
                            controller: viewmodel.paymentMethodAmountController,
                            paymentMethods: viewmodel.paymentMethods,
                            selectedLanguage: viewmodel.appViewmodel.selectedLanguage,
                            selectedPaymentMethod: viewmodel.selectedPaymentMethod.value,
                            paymentMethodControllers: viewmodel.paymentMethodControllers.value,
                            canEnablePlaceOrder: viewmodel.canEnablePlaceOrder,
                            onSelected: (paymentMethod) {
                              viewmodel.selectPaymentMethod(paymentMethod);
                            },
                            onDelete: (paymentMethod) {
                              viewmodel.removeEntredAmount(paymentMethod);
                            },
                            onAmountChanged: (p0) {
                              viewmodel.updateAmountEntered();
                            },
                            paidAmount: viewmodel.totalPaidAmount.toString(),
                            remainingAmount: viewmodel.remainingAmountFromInitialPayment.toString(),
                            onPlaceOrderPressed: () {
                              viewmodel.placeOrder(context);
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Obx(
                          () => PaymentCallToAction(
                            widgetFactory: widgetFactory,
                            totalPaidAmount: viewmodel.totalPaidAmount.toString(),
                            remainingAmount: viewmodel.remainingAmountFromInitialPayment.toString(),
                            canEnablePlaceOrder: viewmodel.canEnablePlaceOrder,
                            onPlaceOrderPressed: () {
                              viewmodel.placeOrder(context);
                            },
                          ).withPaddingSymetric(horizontal: 50, vertical: 8),
                        )
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Responsive.isSmallScreen(context)
          ? Obx(
              () => BottomAppBar(
                height: 150,
                child: PaymentCallToAction(
                  widgetFactory: widgetFactory,
                  totalPaidAmount: viewmodel.totalPaidAmount.toString(),
                  remainingAmount: viewmodel.remainingAmountFromInitialPayment.toString(),
                  canEnablePlaceOrder: viewmodel.canEnablePlaceOrder,
                  onPlaceOrderPressed: () {
                    viewmodel.placeOrder(context);
                  },
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
