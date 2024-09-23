import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/business_payment/business_payment_viewmodel.dart';
import 'package:imela_admin/ui/business_payment/components/payment_method_list.dart';
import 'package:imela_admin/ui/business_subscription/components/selected_platform_service_list_item.dart';
import 'package:imela_core/subscription/model/platform_service.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class BusinessPaymentPage extends StatefulWidget {
  static const routeName = '/business-payment';
  static const selectedServiceArgKey = 'selectedServices';
  final List<PlatformService> selectedServices;
  const BusinessPaymentPage({super.key, required this.selectedServices});

  @override
  State<BusinessPaymentPage> createState() => _BusinessPaymentPageState();

  static void navigateTo(BuildContext context, {required List<PlatformService> services}) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName, extra: {selectedServiceArgKey: services});
  }
}

class _BusinessPaymentPageState extends State<BusinessPaymentPage> {
  BusinessPaymentViewmodel get viewmodel => BusinessPaymentViewmodel.getInstance();

  void initViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {BusinessPaymentPage.selectedServiceArgKey: widget.selectedServices});
    });
  }

  @override
  void initState() {
    super.initState();
    initViewmodel();
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
          showContent: true,

          isLoading: viewmodel.isLoading.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          content: Row(
            children: [
              Expanded(
                flex: 4,
                child: widgetFactory.createCard(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              widgetFactory.createText(context, 'Summary', style: Theme.of(context).textTheme.titleLarge),
                              widgetFactory.createText(context, 'Payment for service usage', style: Theme.of(context).textTheme.labelMedium),
                              const SizedBox(height: 24),
                              AppListView(
                                shrinkWrap: true,
                                primary: false,
                                items: widget.selectedServices,
                                separator: const SizedBox(height: 16),
                                itemBuilder: (context, platformService, index) {
                                  return SelectedPlatformServiceListItem(platformService: platformService, showActionButton: false);
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                widgetFactory.createText(context, 'Total', style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(width: 16),
                                Obx(() => widgetFactory.createText(context, viewmodel.getTotalPrice, style: Theme.of(context).textTheme.headlineMedium)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (Responsive.isSmallScreen(context))
                              widgetFactory.createButton(
                                context: context,
                                content: const Text('Continue'),
                                onPressed: () {
                                  viewmodel.showPaymentMethodsModalForSmallScreen(context);
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (Responsive.isLargeOrMediumScreen(context)) ...[
                const SizedBox(width: 24),
                Expanded(
                  flex: 5,
                  child: Center(
                      child: Obx(
                    () => PaymentMethodList(
                      paymentMethods: viewmodel.paymentmethods,
                      isSelected: viewmodel.isPaymentMethodSelected,
                      selectedPaymentMethodId: viewmodel.selectedPaymentMethod.value?.id,
                      onSelected: (paymetnMethodId) {
                        viewmodel.updatePaymentMethod(paymetnMethodId);
                      },
                      onContinue: () {
                        viewmodel.processPayment(context);
                      },
                    ).withPaddingSymetric(horizontal: 32),
                  )),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
