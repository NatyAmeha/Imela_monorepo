import 'package:flutter/material.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/payment/payment_page.viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
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
  const PaymentOptionsComponent({
    super.key,
    required this.paymentOptions,
    this.selectedPaymentOptionId,
    required this.onChanged,
    required this.checkSelectedPaymentOptiontype,
    required this.viewmodel,
    required this.onDueDateSelected,
    this.selectedDueDateString,
  });

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      padding: Responsive.paddingSymetric(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widgetFactory.createText(context, 'Payment Options', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          AppListView(
            shrinkWrap: true,
            items: paymentOptions,
            itemBuilder: (context, option, index) {
              return widgetFactory.createRadioListTile(context, title: option.name.localize("ENGLISH"), value: option.id!, groupValue: selectedPaymentOptionId, onChanged: (value) {
                onChanged(option);
              });
            },
          ),
          const Divider(height: 32),
          if (checkSelectedPaymentOptiontype(PaymentOptionType.PAY_LATER.toString())) ...[
            widgetFactory.createText(context, 'Initial Payment'),
            widgetFactory.createTextField(controller: viewmodel.initialPaymentController, hintText: 'Initial Payment'),
            const Divider(height: 40),
          ],
          if (checkSelectedPaymentOptiontype(PaymentOptionType.PAY_LATER.toString()) && viewmodel.remainingAmountForDueDate > 0) ...[
            _buildPaymentDuaDateSelector(context, widgetFactory),
          ],
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Total products', style: Theme.of(context).textTheme.titleSmall),
              widgetFactory.createText(context, viewmodel.totalProductString, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Total Payment', style: Theme.of(context).textTheme.titleSmall),
              widgetFactory.createText(context, viewmodel.totalCartAmountString, style: Theme.of(context).textTheme.titleMedium),
            ],
          )
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
