import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/resources/colors.dart';
import 'package:imela_pos/ui/customer/component/create_customer_modal.dart';
import 'package:imela_pos/ui/payment/component/payment_method_input_component.dart';
import 'package:imela_pos/ui/payment/payment_page.viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class PaymentOptionsComponent extends StatelessWidget {
  final String? selectedPaymentOptionId;
  final List<PaymentOption> paymentOptions;
  final Function(PaymentOption) onChanged;
  final bool Function(String paymentOptionType) checkSelectedPaymentOptiontype;
  final PaymentPageViewmodel viewmodel;
  final Function() onDueDateSelected;
  final String? selectedDueDateString;
  final Customer? customer;
  const PaymentOptionsComponent({
    super.key,
    required this.paymentOptions,
    this.selectedPaymentOptionId,
    required this.onChanged,
    required this.checkSelectedPaymentOptiontype,
    required this.viewmodel,
    required this.onDueDateSelected,
    this.selectedDueDateString,
    this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      child: SingleChildScrollView(
        padding: Responsive.paddingSymetric(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widgetFactory.createText(context, 'Payment Options', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            widgetFactory.createText(context, 'Select one of the following payment options', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            AppListView(
              shrinkWrap: true,
              items: paymentOptions,
              itemBuilder: (context, option, index) {
                return widgetFactory.createRadioListTile(context, title: option.getName('ENGLISH'), value: option.id!, groupValue: selectedPaymentOptionId, onChanged: (value) {
                  onChanged(option);
                });
              },
            ),
            const Divider(height: 32),
            _buildPaymentSummary(context, widgetFactory),
            const Divider(height: 24),
            SizedBox(height: Responsive.getHeight(context, small: 24, medium: 50, large: 100)),
            if (context.isPhone) ...[
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
                  paidAmount: viewmodel.totalPaidAmount.toString(),
                  remainingAmount: viewmodel.remainingAmountFromInitialPayment.toString(),
                  onPlaceOrderPressed: () {
                    viewmodel.placeOrder(context);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(BuildContext context, WidgetFactory widgetFactory) {
    var customerName = customer != null ? customer!.name : 'No customer selected';
    return widgetFactory.createCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widgetFactory.createText(context, 'Payment Summary', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            runAlignment: WrapAlignment.spaceBetween,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              widgetFactory.createText(context, 'Total products', style: Theme.of(context).textTheme.labelMedium),
              widgetFactory.createText(context, viewmodel.totalProductString, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            runAlignment: WrapAlignment.spaceBetween,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              widgetFactory.createText(context, 'Total Amount', style: Theme.of(context).textTheme.labelMedium),
              widgetFactory.createText(context, viewmodel.totalCartAmountString, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            runAlignment: WrapAlignment.spaceBetween,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              widgetFactory.createText(context, 'Current Payment', style: Theme.of(context).textTheme.labelMedium),
              widgetFactory.createText(context, viewmodel.finalTotalAmountString, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 8),
          if (viewmodel.isPayLaterOption) ...[
            widgetFactory.createCard(
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              padding: Responsive.paddingSymetric(context, smallHorizontal: 4, smallVertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widgetFactory.createText(context, 'Remaining Payment', style: Theme.of(context).textTheme.titleSmall),
                  widgetFactory.createText(context, viewmodel.paylaterAmount.toStringAsFixed(2), style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          ],
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widgetFactory.createText(context, 'Selected customer'),
                    const SizedBox(width: 8),
                    widgetFactory.createText(context, customerName, style: Theme.of(context).textTheme.titleMedium, enableResize: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDuaDateSelector(BuildContext context, WidgetFactory widgetFactory) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widgetFactory.createText(context, 'Payment Due Date'),
              if (selectedDueDateString != null) widgetFactory.createText(context, selectedDueDateString!),
            ],
          ),
        ),
        widgetFactory.createIcon(
          materialIcon: Icons.calendar_month,
          onPressed: () {
            onDueDateSelected();
          },
        )
      ],
    );
  }
}
