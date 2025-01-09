import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/l10n/l10n.dart';
import 'package:imela/presentation/ui/cart/components/order_item_config.list_tile.dart';
import 'package:imela/presentation/ui/order/components/order_item_list_item.dart';
import 'package:imela/presentation/ui/order/components/order_payment_method_item.dart';
import 'package:imela/presentation/ui/order/order_details/order_details.viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/listview.component.dart';
import 'package:imela_core/order/model/order_config.model.dart';
import 'package:imela_ui_kit/components/badge/status_ladder.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/date_utils.dart';

class SmallScreenOrderDetail extends StatelessWidget {
  final OrderDetailviewmodel viewmodel;
  final WidgetFactory widgetFactory;
  const SmallScreenOrderDetail({super.key, required this.viewmodel, required this.widgetFactory});

  String get selectedCurrency => viewmodel.appViewmodel.selectedCurrency.name;
  String get selectedLanguage => viewmodel.appViewmodel.selectedLanguage.name;
  double? get earnedPoints => viewmodel.orderInfo.value?.getTotalEarnedPoints();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).orderDetails),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Obx(() => viewmodel.isBusinessLoading.value ? LinearProgressIndicator(color: Theme.of(context).colorScheme.primary) : const SizedBox()),
            widgetFactory.createCard(
              padding: const EdgeInsets.all(16),
              border: Border.all(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widgetFactory.createText(context, AppLocalizations.of(context).orderSummary, style: Theme.of(context).textTheme.titleMedium),
                  buildBusinessesSection(context),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widgetFactory.createText(context, AppLocalizations.of(context).orderStatus, style: Theme.of(context).textTheme.bodyLarge).withPaddingSymetric(vertical: 8),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.8,
                        child: Obx(
                          () => StatusLadder( 
                            items: viewmodel.orderStatusString.map((status) => widgetFactory.createText(context, status, style: Theme.of(context).textTheme.bodyMedium)).toList(),
                            currentIndex: viewmodel.orderStatusString.indexOf(viewmodel.orderInfo.value?.getOrderStatus(selectedLanguage, viewmodel.orderStatuses) ?? ''),
                            activeColor: Theme.of(context).colorScheme.primary,
                            widgetFactory: widgetFactory,
                            inactiveColor: Theme.of(context).colorScheme.surfaceContainerLow,
                          ),
                        ),
                      ),
                    ],
                  ).withPaddingSymetric(vertical: 6),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widgetFactory.createText(context, AppLocalizations.of(context).orderDate, style: Theme.of(context).textTheme.bodyMedium),
                      widgetFactory.createText(context, '${viewmodel.orderInfo.value?.createdAt?.toFormattedString()}', style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ).withPaddingSymetric(vertical: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widgetFactory.createText(context, AppLocalizations.of(context).totalItems, style: Theme.of(context).textTheme.bodyMedium),
                      widgetFactory.createText(context, AppLocalizations.of(context).itemsCount('${viewmodel.orderInfo.value?.items?.length}'), style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ).withPaddingSymetric(vertical: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widgetFactory.createText(context, AppLocalizations.of(context).totalAmount, style: Theme.of(context).textTheme.bodyMedium),
                      widgetFactory.createText(context, 'ETB ${viewmodel.orderInfo.value?.totalAmount}', style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ).withPaddingSymetric(vertical: 6),
                  if (earnedPoints?.isGreaterThan(0) == true) ...[
                    const Divider(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            widgetFactory.createText(context, AppLocalizations.of(context).earnedPoints, style: Theme.of(context).textTheme.bodyMedium),
                            widgetFactory.createText(context, '${viewmodel.orderInfo.value?.getTotalEarnedPointsString(selectedLanguage)}', style: Theme.of(context).textTheme.titleSmall),
                          ],
                        ),
                        widgetFactory.createButton(
                          context: context,
                          style: AppButtonStyle.textButtonStyle(context),
                          content: Text(AppLocalizations.of(context).viewRewards),
                          onPressed: () {
                            viewmodel.moveToRewards(context);
                          },
                        ),
                      ],
                    ).withPaddingSymetric(vertical: 6),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 16),
            widgetFactory.createCard(
              padding: const EdgeInsets.all(16),
              border: Border.all(color: Theme.of(context).colorScheme.primary),
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widgetFactory.createText(context, AppLocalizations.of(context).paymentSummary, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widgetFactory.createText(context, AppLocalizations.of(context).paidAmounts, style: Theme.of(context).textTheme.bodyMedium),
                      widgetFactory.createText(context, '${viewmodel.orderInfo.value?.paidAmountString(selectedCurrency, selectedLanguage)}', style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ).withPaddingSymetric(vertical: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widgetFactory.createText(context, AppLocalizations.of(context).remainingAmount, style: Theme.of(context).textTheme.bodyMedium),
                      widgetFactory.createText(context, '${viewmodel.orderInfo.value?.remainingAmountString(selectedCurrency, selectedLanguage)}', style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ).withPaddingSymetric(vertical: 6),
                  const Divider(),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      widgetFactory.createText(context, AppLocalizations.of(context).paymentMethods, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      AppListView(
                        shrinkWrap: true,
                        primary: false,
                        items: viewmodel.orderInfo.value?.paymentMethods ?? [],
                        itemBuilder: (context, item, index) {
                          return OrderPaymentMethodItem(orderPaymentMethod: item, widgetFactory: widgetFactory, selectedLanguage: selectedLanguage);
                        },
                      ),
                    ],
                  ).withPaddingSymetric(vertical: 6),
                ],
              ),
            ),
            const SizedBox(height: 16),
            widgetFactory.createCard(
              padding: const EdgeInsets.all(16),
              border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerLow),
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widgetFactory.createText(context, AppLocalizations.of(context).items, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  AppListView(
                    shrinkWrap: true,
                    primary: false,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    items: viewmodel.orderInfo.value?.items ?? [],
                    itemBuilder: (context, item, index) {
                      return OrderItemListItem(orderItem: item, selectedCurrency: selectedCurrency, selectedLanguage: selectedLanguage);
                    },
                  ),
                ],
              ),
            ),
            if (viewmodel.orderInfo.value?.config?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              buildOrderConfig(context, viewmodel.orderInfo.value?.config ?? [], widgetFactory),
            ]
          ],
        ),
      ),
    );
  }

  Widget buildBusinessesSection(BuildContext context) {
    return Obx(
      () => widgetFactory.createCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: viewmodel.orderBusinesses.isNotEmpty
            ? Column(
                children: viewmodel.orderBusinesses
                    .map((business) => Row(
                          children: [
                            widgetFactory.createText(context, viewmodel.getBusinessName(business.id!) ?? '', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ))
                    .toList(),
              )
            : const SizedBox(),
      ),
    );
  }

  Widget buildOrderConfig(BuildContext context, List<OrderConfig> configs, WidgetFactory widgetFactory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widgetFactory.createText(context, AppLocalizations.of(context).additionalConfigurations, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        AppListView(
          shrinkWrap: true,
          primary: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          items: configs,
          itemBuilder: (context, config, index) {
            return OrderItemConfigListITemTile(config: config, widgetFactory: widgetFactory, selectedCurrency: selectedCurrency, selectedLanguage: selectedLanguage);
          },
        ),
      ],
    );
  }
}
