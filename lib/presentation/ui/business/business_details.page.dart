import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/domain/business/model/business.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/injection.dart';
import 'package:melegna_customer/presentation/ui/business/business_details.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/business/small_screen_business_details.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';
import 'package:melegna_customer/services/routing_service.dart';

class BusinessDetailsPage extends StatefulWidget {
  static const baseRouteName = '/business';
  static const routeName = '$baseRouteName/:id';
  static const idQueryParameter = 'id';
   BusinessDetailsViewModel? businessViewmodel;
  final String businessId;
  final String? businessName;
   BusinessDetailsPage({super.key, required this.businessId, this.businessName, this.businessViewmodel}) {
    businessViewmodel ??= Get.put(getIt<BusinessDetailsViewModel>());
  }

  @override
  State<BusinessDetailsPage> createState() => _BusinessDetailsPageState();

  static void navigateToBusinessDetailPage(BuildContext context, IRoutingService router, Business business, {Widget? previousPage}) {
    router.navigateTo(context, '${BusinessDetailsPage.baseRouteName}/${business.id}', extra: {'name': '${business.name?.localize()}', GoRouterService.PREVIOUS_PAGE_KEY: previousPage});
  
  }
}

class _BusinessDetailsPageState extends State<BusinessDetailsPage> {
  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      widget.businessViewmodel!.initViewmodel(data : {'id' : widget.businessId});
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
          isLoading: widget.businessViewmodel!.isLoading.value,
          hasError: widget.businessViewmodel!.exception.value?.isMainError ?? false,
          showContent: widget.businessViewmodel!.businessDetails.value != null,
          content: ResponsiveWrapper(
            smallScreen: BusinessDetailsSmallScreen(
              businessDetailsViewmodel: widget.businessViewmodel!,
              businessName: widget.businessName,
            ),
          ),
        ),
      ),
    );
  }
}
