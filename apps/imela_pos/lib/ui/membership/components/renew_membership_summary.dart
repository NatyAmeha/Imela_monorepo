import 'package:flutter/material.dart';
import 'package:imela_core/customer/model/customer.model.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/image/image_uploader.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/storage/file_upload.model.dart';

class RenewMembershipSummary extends StatelessWidget {
  final Customer? customer;
  final Membership membership;
  final WidgetFactory widgetFactory;
  final Function onConfirm;
  final String selectedLanguage;
  final String currency;
  final double height;
  final double width;
  final bool isRenewingMembership;
  final bool enableCustomerSelection;
  final EdgeInsetsGeometry? padding;
  final Function(int)? onImageRemoved;
  final Function(FileUpload?)? onImageUpload;
  final Function()? onCustomerSelect;
  final Function()? onCustomerCreate;
  const RenewMembershipSummary({
    super.key,
    this.customer,
    required this.membership,
    required this.onConfirm,
    required this.widgetFactory,
    required this.selectedLanguage,
    required this.currency,
    this.height = 800,
    this.width = 300,
    this.isRenewingMembership = false,
    this.enableCustomerSelection = true,
    this.onImageRemoved,
    this.onImageUpload,
    this.onCustomerSelect,
    this.onCustomerCreate,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      // padding: const EdgeInsets.all(16),
      width: width, 
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widgetFactory.createText(context, 'Summary', style: Theme.of(context).textTheme.titleLarge),
            const Divider(),
            _buildCustomerWidget(context),
            const SizedBox(height: 16),
            widgetFactory.createText(context, 'Membership', style: Theme.of(context).textTheme.titleSmall),
            widgetFactory.createText(context, membership.name.localize('ENGLISH'), style: Theme.of(context).textTheme.bodyLarge),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widgetFactory.createText(context, 'Duration', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: 16),
                widgetFactory.createText(context, membership.getDurationString(selectedLanguage), style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widgetFactory.createText(context, 'Ends on', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: 16),
                widgetFactory.createText(context, membership.getEndsInString(selectedLanguage), style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widgetFactory.createText(context, 'Price', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: 16),
                widgetFactory.createText(context, membership.price.toSelectedPriceString(currency), style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            widgetFactory.createText(context, 'Payment Proof', style: Theme.of(context).textTheme.titleSmall).withPaddingSymetric(vertical: 16),
            ImageUploader(
                widgetFactory: widgetFactory,
                height: 150,
                onImageRemoved: (index) {
                  onImageRemoved?.call(index);
                },
                onImageUpload: (image) {
                  onImageUpload?.call(image);
                }),
            widgetFactory.createButton(context: context, content: const Text('Confirm'), onPressed: onConfirm, isLoading: isRenewingMembership).withPaddingSymetric(vertical: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        widgetFactory.createText(context, 'Customer', style: Theme.of(context).textTheme.titleSmall),
        if (customer != null)
          widgetFactory.createText(context, customer!.name, style: Theme.of(context).textTheme.titleMedium)
        else
          widgetFactory.createText(
            context,
            'NO customer selected',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        if (enableCustomerSelection)
          Row(
            children: [
              widgetFactory.createButton(
                context: context,
                content: const Text('Select Customer'),
                style: AppButtonStyle.textButtonStyle(context),
                onPressed: () {
                  onCustomerSelect?.call();
                },
              ),
            ],
          ),
      ],
    );
  }
}
