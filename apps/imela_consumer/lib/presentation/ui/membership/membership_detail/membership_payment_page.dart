import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/membership/membership_detail/membership_detail_viewmodel.dart';
import 'package:imela/presentation/ui/payment/components/selected_payment_method.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class MembershipPaymentPage extends StatefulWidget {
  static const routeName = '/membership-payment';
  const MembershipPaymentPage({super.key});
  static void navigate(BuildContext context, {required String membershipId}) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName);
  }

  @override
  State<MembershipPaymentPage> createState() => _MembershipPaymentPageState();
}

class _MembershipPaymentPageState extends State<MembershipPaymentPage> {
  final viewmodel = MembershipDetailsViewModel.getInstance();
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membership Payment')),
      body: Obx(
        () => PageContentLoader(
          isDataLoading: viewmodel.isLoading.value,
          showContent: true,
          content: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: Responsive.paddingSymetric(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      widgetFactory.createText(context, viewmodel.membershipName, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      widgetFactory.createText(context, viewmodel.membership?.description.localize(viewmodel.appViewmodel.selectedLanguage.name) ?? '', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 20),
                      buildMembershipSummary(),
                      const Divider(height: 32),
                      widgetFactory.createText(context, 'Selected payment', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (viewmodel.selectedPaymentMethod.value != null)
                        SelectedPaymentMethodListItem(
                          selectedPaymentMethod: viewmodel.selectedPaymentMethod.value!,
                          selectedLanguage: viewmodel.appViewmodel.selectedLanguage.name,
                          onRemoveSelectedPayment: () {
                            viewmodel.removeSelectedPaymentMethod();
                          },
                          onPaymentReceiptImageUpload: (fileUpload) {
                            viewmodel.addPaymenReceiptImage(fileUpload);
                          },
                          onPaymentReceiptImageRemoved: (index) {
                            viewmodel.removePaymentReceiptImage();
                          },
                        )
                      else
                        widgetFactory.createButton(
                          context: context,
                          content: const Text('Select Payment Method'),
                          style: AppButtonStyle.outlinedButtonStyle(context),
                          onPressed: () {
                            viewmodel.showPaymentMethodListModal(context);
                          },
                        ),
                        const SizedBox(height: 200),
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
                    widgetFactory.createCard(
                      padding: const EdgeInsets.all(8),
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widgetFactory.createIcon(materialIcon: Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Flexible(
                            child: widgetFactory.createText(
                              context,
                              'Choose payment method, upload your payment receipt and  We will verify your payment receipt and approve your membership request as soon as possible.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              // color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    widgetFactory.createButton(
                      context: context,
                      content: const Text('Send Request'),
                      isLoading: viewmodel.isLoading.value,
                      onPressed: viewmodel.canEnableRequestButton
                          ? () {
                              viewmodel.requestToJoinMembership(context);
                            }
                          : null,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMembershipSummary() {
    final durationString = viewmodel.membership?.membershipDurationString(viewmodel.appViewmodel.selectedLanguageUpdated.value) ?? '';
    final trialPeriodString = viewmodel.membership?.membershipTrialPeriodString(viewmodel.appViewmodel.selectedLanguageUpdated.value) ?? '';
    return widgetFactory.createCard(
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: Responsive.paddingSymetric(context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Price', style: Theme.of(context).textTheme.bodyMedium),
              widgetFactory.createText(context, viewmodel.membershipPrice, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Duration', style: Theme.of(context).textTheme.bodyMedium),
              widgetFactory.createText(context, durationString, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Trial period', style: Theme.of(context).textTheme.bodyMedium),
              widgetFactory.createText(context, trialPeriodString, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ],
      ),
    );
  }
}
