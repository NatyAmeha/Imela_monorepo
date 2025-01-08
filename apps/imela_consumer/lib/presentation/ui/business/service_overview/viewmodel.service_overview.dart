import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/business/service_overview/service_overview_list_page.dart';
import 'package:imela_core/business/model/service_overview.model.dart';
import 'package:imela_ui_kit/components/image/photo_viewer/photo_viewer.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class ServiceOverviewViewModel extends GetxController with BaseViewmodel {
  var serviceOverviews = <ServiceOverview>[].obs;

  // getters
  AppController get appViewmodel => AppController.getInstance;
  var colorLists = [ColorManager.primary, ColorManager.secondary, ColorManager.tertiary, ColorManager.accent1, ColorManager.accent2, ColorManager.accent3, ColorManager.accent4, ColorManager.accent2Dark, ColorManager.alternate];
  List<ServiceOverview> get featuredServiceOverviews => serviceOverviews.value.where((element) => element.featured).toList();
  List<ServiceOverview> get nonFeaturedServiceOverview => serviceOverviews.value.where((element) => !element.featured).toList();

  static ServiceOverviewViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<ServiceOverviewViewModel>());
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () {
      serviceOverviews.value = data?[ServiceOverviewListPage.SERVICE_OVERVIEWS_KEY] ?? [];
    });
  }

  Color getColor(int index) {
    return colorLists[index % colorLists.length];
  }

  void goBack(BuildContext context) {
    appViewmodel.router.goBack(context);
  }

  void displayGallery(BuildContext context, ServiceOverview overview, int index) {
    final productImages = overview.gallery?.getImages() ?? [];
    PhotoViewerScreen.navigate(context, productImages, index);
  }
 
  void handleCallToAction(BuildContext context, ServiceOverview overview) {
    if (overview.callToActionUrl != null) {
      appViewmodel.router.navigateTo(context, overview.callToActionUrl!);
    }
  }
}
 