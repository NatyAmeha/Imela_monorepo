import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/l10n/l10n.dart';
import 'package:imela/presentation/ui/cart/order_configure/order_configure.viewmodel.dart';
import 'package:imela/presentation/ui/payment/components/payment_option_item.dart';
import 'package:imela/presentation/ui/payment/components/selected_payment_method.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class SmallScreenOrderConfigure extends StatelessWidget {
  final OrderConfigureViewmodel viewmodel;
  final WidgetFactory widgetFactory;
  final Cart cart;
  const SmallScreenOrderConfigure({super.key, required this.viewmodel, required this.widgetFactory, required this.cart});

  String get selectedLanguage => viewmodel.appController.selectedLanguage.name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).payment),
      ),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isLoading.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          showContent: true,
          content: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      widgetFactory.createText(context, AppLocalizations.of(context).choosePaymentOption, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      AppListView<PaymentOption>( 
                        items: cart.paymentOptions ?? [],
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        shrinkWrap: true,
                        itemBuilder: (context, item, index) {
                          return Obx(
                            () => PaymentOptionListItem(
                              totalAmount: viewmodel.cartInfo.value?.getTotatAmountPOS() ?? 0,
                              paymentOption: item,
                              selectedPaymentOptionId: viewmodel.selectedPaymentOptionId,
                              widgetFactory: widgetFactory,
                              onSelected: () {
                                viewmodel.selectPaymentOption(item);
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Obx(() {
                        return AppListView(
                          header: viewmodel.selectedPaymentMethods.isNotEmpty
                              ? widgetFactory.createText(
                                  context,
                                  AppLocalizations.of(context).selectedPaymentMethod,
                                  style: Theme.of(context).textTheme.titleMedium,
                                )
                              : null,
                          shrinkWrap: true,
                          primary: false,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          items: viewmodel.selectedPaymentMethods.value,
                          itemBuilder: (context, paymentMethod, index) {
                            return SelectedPaymentMethodListItem(
                              selectedPaymentMethod: paymentMethod,
                              selectedLanguage: selectedLanguage,
                              onRemoveSelectedPayment: () {
                                viewmodel.removeSelectedPaymentMethod(paymentMethod);
                              },
                              onPaymentReceiptImageUpload: (fileUpload) {
                                viewmodel.addPaymenReceiptImage(paymentMethod.id!, fileUpload);
                              },
                              onPaymentReceiptImageRemoved: (index) {
                                viewmodel.removePaymentReceiptImage(paymentMethod.id!, index);
                              },
                            );
                          },
                        );
                      }),
                      const SizedBox(height: 124),
                    ],
                  ),
                ),
              ),
              Positioned(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: widgetFactory.createCard(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    border: Border.all(color: Theme.of(context).colorScheme.primaryContainer, width: 1),
                    child: Obx(
                      () => Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (viewmodel.paymentStatusMessage.isNotEmpty) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                widgetFactory.createIcon(materialIcon: Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Flexible(child: widgetFactory.createText(context, AppLocalizations.of(context).paymentInfo, style: Theme.of(context).textTheme.bodyMedium)),
                              ],
                            ),
                            const Divider(height: 8),
                          ],
                          Obx(
                            () => Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                widgetFactory.createText(context, AppLocalizations.of(context).total, style: Theme.of(context).textTheme.bodyLarge),
                                const SizedBox(width: 8),
                                widgetFactory.createText(context, 'ETB ${viewmodel.currentPayment}', style: Theme.of(context).textTheme.titleMedium),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => widgetFactory.createButton(
                              context: context,
                              content: Text(AppLocalizations.of(context).orderCallToAction),
                              onPressed: () => viewmodel.placeOrder(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
