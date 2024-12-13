import 'package:flutter/material.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/image/image_uploader.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/file_upload.model.dart';

class SelectedPaymentMethodListItem extends StatelessWidget {
  final SelectedPaymentMethod selectedPaymentMethod;
  final String selectedLanguage;
  final Function? onRemoveSelectedPayment;
  final Function(FileUpload?)? onPaymentReceiptImageUpload;
  final Function(int)? onPaymentReceiptImageRemoved;
  const SelectedPaymentMethodListItem({
    super.key,
    required this.selectedPaymentMethod,
    required this.selectedLanguage,
    this.onRemoveSelectedPayment,
    this.onPaymentReceiptImageUpload,
    this.onPaymentReceiptImageRemoved,
  });

  String get paymentMethodName => selectedPaymentMethod.name.localize(selectedLanguage);

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return widgetFactory.createCard(
      padding: const EdgeInsets.all(16),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: widgetFactory.createText(context, paymentMethodName, style: Theme.of(context).textTheme.titleSmall)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  widgetFactory.createText(context, selectedPaymentMethod.amount.amountWithCurrency, style: Theme.of(context).textTheme.titleMedium),
                  widgetFactory.createButton(
                    context: context,
                    content: const Text('Remove'),
                    style: AppButtonStyle.textButtonStyle(context),
                    onPressed: () {
                      onRemoveSelectedPayment?.call();
                    },
                  )
                ],
              ),
            ],
          ),
          if (selectedPaymentMethod.requireReceiptImage == true) ...[
            const SizedBox(height: 16),
            ImageUploader(
              widgetFactory: widgetFactory,
              showFeaturedOption: false,
              height: 150,
              onImageUpload: (image) {
                onPaymentReceiptImageUpload?.call(image);
              },
              onImageRemoved: (index) {
                onPaymentReceiptImageRemoved?.call(index);
              },
            ),
          ],
        ],
      ),  
    );
  }
}
