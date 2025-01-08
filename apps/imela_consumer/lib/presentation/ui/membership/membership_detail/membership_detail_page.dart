import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/membership/components/user_membership_card.dart';
import 'package:imela/presentation/ui/membership/membership_detail/membership_detail_viewmodel.dart';
import 'package:imela/presentation/ui/product/components/grid_product_list_item.component.dart';
import 'package:imela/presentation/ui/shared/list/gridview.component.dart';
import 'package:imela/presentation/utils/widget_extesions.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/number_utils.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class MembershipDetailsPage extends StatefulWidget {
  static const routeName = '/membership-details';
  static const MEMBERSHIP_ID_KEY = 'MEMBERSHIP_ID';
  static const CONTEXT_KEY = 'CONTEXT';
  final String membershipId;
  const MembershipDetailsPage({super.key, required this.membershipId});

  @override
  State<MembershipDetailsPage> createState() => _MembershipDetailsPageState();

  static void navigate(BuildContext context, String membershipId, {bool replace = false}) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName, extra: {MEMBERSHIP_ID_KEY: membershipId}, replace: replace);
  }
}

class _MembershipDetailsPageState extends State<MembershipDetailsPage> {
  final viewmodel = MembershipDetailsViewModel.getInstance();
  late WidgetFactory widgetFactory;
  @override
  void initState() {
    super.initState();
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
    viewmodel.initViewmodel(data: {MembershipDetailsPage.MEMBERSHIP_ID_KEY: widget.membershipId, MembershipDetailsPage.CONTEXT_KEY: context});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Obx(() => widgetFactory.createText(context, viewmodel.membershipName, style: Theme.of(context).textTheme.bodyLarge)),
          ],
        ),
      ),
      body: Obx(
        () {
          return PageContentLoader(
            isLoading: viewmodel.isLoading.value,
            showContent: viewmodel.membershipDetails.value != null,
            exception: viewmodel.exception.value,
            hasError: viewmodel.exception.value?.isMainError ?? false,
            onTryAgain: () => viewmodel.getMembershipDetails(context, fetchPolicy: ApiDataFetchPolicy.networkOnly),
            content: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (viewmodel.userGroupMemberInfo?.isUserMembershipStatusPending ?? false)
                          widgetFactory.createCard(
                            borderRadius: BorderRadius.zero,
                            padding: const EdgeInsets.all(16),
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                widgetFactory.createText(
                                  context,
                                  'Your request to join this membership is pending. it will be reviewed by the business owner and you will be notified of the result.',
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 5),
                                widgetFactory.createButton(
                                  context: context,
                                  style: AppButtonStyle.textButtonStyle(context, color: Theme.of(context).colorScheme.onTertiaryContainer),
                                  content: const Text('See request detail'),
                                  onPressed: () => viewmodel.showMembershipBenefitsModal(context),
                                )
                              ],
                            ),
                          ),
                        if ((viewmodel.userGroupMemberInfo?.isUserMembershipStatusActive ?? false) && viewmodel.subscription != null)
                          UserMembershipCard(
                            membership: viewmodel.membership!,
                            subscription: viewmodel.subscription!,
                            widgetFactory: widgetFactory,
                            selectedLanguage: viewmodel.appViewmodel.selectedLanguage.name,
                            onViewDetailsPressed: () {
                              viewmodel.showMembershipBenefitsModal(context);
                            },
                          ),
                        if (viewmodel.userGroupMemberInfo?.isUserMembershipStatusPending ?? true) ...[
                          _buildMembershipDetails(context),
                        ],
                        const SizedBox(height: 16),
                        AppGridView(
                          header: widgetFactory.createText(context, 'Member only products', style: Theme.of(context).textTheme.titleMedium).withPaddingSymetric(horizontal: 12),
                          items: viewmodel.membershipProducts.value,
                          padding: const EdgeInsets.all(10),
                          shrinkWrap: true,
                          primary: false,
                          isStaggered: true,
                          crossAxisCount: Responsive.getGridCount(context, itemWidth: 180),
                          itemBuilder: (context, product, index) {
                            return GridProductListItem(
                              product: product,
                              widgetFactory: widgetFactory,
                              imageHeight: 120,
                              discounts: viewmodel.membershipDiscounts,
                              onTap: () => viewmodel.navigateToProductDetails(context, product),
                            );
                          },
                        ),
                        if (viewmodel.membershipProducts.isEmpty)
                          Obx(
                            () => viewmodel.membershipProducts.isEmpty
                                ? widgetFactory.createText(
                                    context,
                                    'No product found',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  )
                                : const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!viewmodel.isUserJoined())
                        widgetFactory.createButton(
                          context: context,
                          content: const Text('Request to join'),
                          onPressed: () => viewmodel.navigateToMembershipPayment(context),
                        )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMembershipDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widgetFactory.createText(context, viewmodel.membershipName, style: Theme.of(context).textTheme.titleMedium),
        widgetFactory.createText(context, '${viewmodel.membership?.price.toSelectedPriceString(viewmodel.appViewmodel.selectedCurrency.name)} / ${viewmodel.membership?.duration?.toDurationString()}', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (viewmodel.membership?.trialPeriod?.isGreaterThan(0) ?? false) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widgetFactory.createText(context, 'Trial period', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(width: 8),
              widgetFactory.createText(context, '${viewmodel.membership?.trialPeriod?.toDurationString()}', style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 8),
        ],
        widgetFactory.createText(context, viewmodel.membership?.description.localize(viewmodel.appViewmodel.selectedLanguage.name) ?? '', style: Theme.of(context).textTheme.labelMedium),
      ],
    ).withPaddingAll(16);
  }
}
