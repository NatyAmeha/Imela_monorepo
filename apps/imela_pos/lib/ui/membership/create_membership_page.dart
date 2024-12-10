import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/membership/components/renew_membership_summary.dart';
import 'package:imela_pos/ui/membership/create_membership.viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class CreateMembershipPage extends StatefulWidget {
  final String membershipId;
  static const routeName = '/create-membership';
  CreateMembershipPage({super.key, required this.membershipId});

  @override
  State<CreateMembershipPage> createState() => _CreateMembershipPageState();

  static void navigateTo(BuildContext context, String membershipId) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName, extra: {'membershipId': membershipId});
  }
}

class _CreateMembershipPageState extends State<CreateMembershipPage> {
  var viewmodel = CreateMembershipViewmodel.getInstance();
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewmodel.initViewmodel(data: {'membershipId': widget.membershipId});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Membership')),
      body: Obx(
        () => PageContentLoader(
          showContent: viewmodel.selectedMembership.value != null,
          content: widgetFactory.createCard(
            padding: Responsive.paddingSymetric(context, largeHorizontal: 75),
            child: Responsive.isLargeOrMediumScreen(context)
                ? Row(
                    children: [
                      Expanded(flex: 2, child: _buildMembershipIinfo()),
                      const SizedBox(width: 24),
                      Expanded(flex: 3, child: _buildMembershipSummary()),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildMembershipIinfo(),
                        const SizedBox(height: 24),
                        _buildMembershipSummary(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipIinfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widgetFactory.createText(context, 'Membership Information', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        widgetFactory.createCard(
          border: Border.all(color: Theme.of(context).colorScheme.surface),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widgetFactory.createText(context, '${viewmodel.selectedMembership.value?.name.localize(viewmodel.selectedLanguage)}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              widgetFactory.createText(context, '${viewmodel.selectedMembership.value?.description.localize(viewmodel.selectedLanguage)}', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 12),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildMembershipBenefits(),
      ],
    );
  }

  Widget _buildMembershipSummary() {
    return Obx(
      () => RenewMembershipSummary(
        width: Responsive.isLargeScreen(context) ? 300 : double.infinity,
        padding: Responsive.paddingSymetric(context, largeHorizontal: 75),
        customer: viewmodel.selectedCustomer.value,
        membership: viewmodel.selectedMembership.value!,
        onConfirm: () {
          viewmodel.createMembership(context);
        },
        widgetFactory: widgetFactory,
        selectedLanguage: viewmodel.selectedLanguage,
        currency: viewmodel.selectedCurrency,
        onCustomerSelect: () async {
          await viewmodel.showCustomerListDialog(context);
        },
        onCustomerCreate: () {
          viewmodel.showCustomerCreateDialog(context);
        },
        onImageUpload: (image) {
          viewmodel.addSelectedPaymentMethod(image);
        },
        onImageRemoved: (index) {
          viewmodel.removeSelectedPaymentMethod(index);
        },
      ),
    );
  }

  Widget _buildMembershipBenefits() {
    return widgetFactory.createCard(
      border: Border.all(color: Theme.of(context).colorScheme.surface),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widgetFactory.createText(context, 'Benefits', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          AppListView(
            shrinkWrap: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            items: viewmodel.selectedMembership.value?.benefits,
            itemBuilder: (context, item, index) {
              return Row(
                children: [
                  widgetFactory.createIcon(materialIcon: Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  widgetFactory.createText(context, item.name.localize(viewmodel.selectedLanguage)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
