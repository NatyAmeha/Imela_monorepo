import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';

import 'package:imela/services/routing_service.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/components/page_loading_utils/responsive_wrapper.dart';
import 'business_details.viewmodel.dart';
import 'small_screen_business_details.dart';

class BusinessDetailsPage extends StatefulWidget {
  static const baseRouteName = '/business';
  static const routeName = '$baseRouteName/:id';
  static const idQueryParameter = 'id';
  final String businessId;
  final List<Branch> branches;
  final String? businessName;
  BusinessDetailsPage({super.key, required this.businessId, this.businessName, this.branches = const []});
  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();

  static void navigateToBusinessDetailPage(BuildContext context, IRoutingService router, Business business) {
    final branchesString = business.branches?.map((e) => e.toJson()).toList().toString();
    router.navigateTo(
      context, 
      '${BusinessDetailsPage.baseRouteName}/${business.id}',
      queryParam: {
        'name': '${business.name?.localize('ENGLISH')}',
        if (branchesString != null) 'branches': Uri.encodeComponent(branchesString),
      },
      extra: {
        'name': '${business.name?.localize('ENGLISH')}',
        if (branchesString != null) 'branches': Uri.encodeComponent(branchesString),
      },
    );
  }
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  var businessViewmodel = BusinessDetailsViewModel.getInstance();
  bool get canShowContent => businessViewmodel.businessDetails.value != null && (businessViewmodel.exception.value == null || businessViewmodel.exception.value?.isMainError == false);
  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      businessViewmodel.initViewmodel(data: {'id': widget.businessId, 'context': context, 'branches': widget.branches});
    });
  }

  @override
  void initState() {
    super.initState();
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => PageContentLoader(
          isLoading: businessViewmodel.isLoading.value,
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
