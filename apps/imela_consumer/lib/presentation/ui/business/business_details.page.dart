import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'business_details.viewmodel.dart';
import 'small_screen_business_details.dart';

class BusinessDetailsPage extends StatefulWidget {
  static const baseRouteName = '/business';
  static const routeName = '$baseRouteName/:id';
  static const idQueryParameter = 'id';
  final String businessId;
  final String? businessName;
  BusinessDetailsPage({super.key, required this.businessId, this.businessName});
  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();

  static void navigateToBusinessDetailPage(BuildContext context, IRoutingService router, Business business, {Widget? previousPage}) {
    router.navigateTo(context, '${BusinessDetailsPage.baseRouteName}/${business.id}', extra: {'name': '${business.name?.localize('ENGLISH')}', GoRouterService.PREVIOUS_PAGE_KEY: previousPage});
  }
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  var businessViewmodel = BusinessDetailsViewModel.getInstance();
  bool get canShowContent => businessViewmodel.businessDetails.value != null && (businessViewmodel.exception.value == null || businessViewmodel.exception.value?.isMainError == false);
  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      businessViewmodel.initViewmodel(data: {'id': widget.businessId, 'context': context});
    });
  }

  @override
  void initState() {
    super.initState();
    print("viewmodel init state");
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => PageContentLoader(
          isDataLoading: businessViewmodel.isLoading.value,
          hasError: businessViewmodel.exception.value?.isMainError ?? false,
          showContent: canShowContent,
          exception: businessViewmodel.exception.value,
          onTryAgain: () {
            initializeViewmodel();
          },
          content: ResponsiveWrapper(
            smallScreen: BusinessDetailsSmallScreen(businessDetailsViewmodel: businessViewmodel, businessName: widget.businessName),
          ),
        ),
      ),
    );
  }
}
