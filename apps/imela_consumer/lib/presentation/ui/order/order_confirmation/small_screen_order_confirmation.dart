import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/order/components/order_item_list_item.dart';
import 'package:imela/presentation/ui/order/order_confirmation/order_confirmation.viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class SmallScreenOrderConfirmation extends StatefulWidget {
  const SmallScreenOrderConfirmation({super.key});

  @override
  State<SmallScreenOrderConfirmation> createState() => _SmallScreenOrderConfirmationState();
}

class _SmallScreenOrderConfirmationState extends State<SmallScreenOrderConfirmation> {
  final OrderConfirmationViewmodel viewmodel = OrderConfirmationViewmodel.getInstance();
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (isPop) {
        viewmodel.navigateToHome(context);
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Order Confirmation'),
            automaticallyImplyLeading: false,
            leading: widgetFactory.createIcon(
                materialIcon: Icons.arrow_back_ios,
                onPressed: () {
                  viewmodel.navigateToHome(context);
                }),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                widgetFactory.createCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 32),
                      widgetFactory.createIcon(materialIcon: Icons.check_circle, size: 75, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 16),
                      widgetFactory.createText(context, 'Order submitted successfully', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      widgetFactory.createCard(
                        padding: const EdgeInsets.all(10),
                        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerLow),
                        borderRadius: BorderRadius.circular(8),
                        child: widgetFactory.createText(context, 'Thank you for your order. We will contact you shortly to confirm the order.', style: Theme.of(context).textTheme.bodySmall),
                      ),
                      const SizedBox(height: 16),
                      _buildOrderSummary(context),
                      const SizedBox(height: 16),
                      widgetFactory.createButton(
                        context: context,
                        content: const Text('Back to Home'),
                        onPressed: () {
                          viewmodel.navigateToHome(context);
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widgetFactory.createText(context, 'Order Summary', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        AppListView(
          shrinkWrap: true,
          primary: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          items: viewmodel.order?.items ?? [],
          itemBuilder: (context, item, index) {
            return OrderItemListItem(
              orderItem: item,
              selectedCurrency: viewmodel.selectedCurrency,
              selectedLanguage: viewmodel.selectedLanguage,
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widgetFactory.createText(context, 'Subtotal', style: Theme.of(context).textTheme.titleMedium),
            widgetFactory.createText(context, viewmodel.order?.subtotalAmountString(viewmodel.selectedCurrency, viewmodel.selectedLanguage) ?? '', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widgetFactory.createText(context, 'Discount', style: Theme.of(context).textTheme.titleMedium),
            widgetFactory.createText(context, viewmodel.order?.totalDiscountString(viewmodel.selectedCurrency, viewmodel.selectedLanguage) ?? '', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widgetFactory.createText(context, 'Total', style: Theme.of(context).textTheme.titleMedium),
            widgetFactory.createText(context, viewmodel.order?.totalAmountString(viewmodel.selectedCurrency, viewmodel.selectedLanguage) ?? '', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}
