import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/business/business_details.page.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class BusinessListViewmodel extends GetxController with BaseViewmodel {
  static BusinessListViewmodel getInstance() => BaseViewmodel.isViewmodelRegistered(getIt<BusinessListViewmodel>());

  // state variables
  var isLoading = false.obs;
  var businesses = Rxn<List<Business>>();
  var exception = Rxn<AppException>();
  var title = ''.obs;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel();
    if (data != null) {
      businesses.value = data['businesses'] as List<Business>?;
      title.value = data['title'] as String? ?? '';
    }
  }

  void navigateToBusinessDetail(BuildContext context, Business business) {
    BusinessDetailsPage.navigateToBusinessDetailPage(context, AppController.getInstance.router, business);
  }
} 