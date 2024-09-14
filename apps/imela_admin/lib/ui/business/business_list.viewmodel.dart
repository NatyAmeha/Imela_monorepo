import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/ui/dashboard/dashboard_page.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class BusinessListViewmodel extends GetxController with BaseViewmodel {
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();

  static BusinessListViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<BusinessListViewmodel>());
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    getBusinessList();
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var businessList = <Business>[].obs;


  void setupStateVariables() {
    businessList.clear();
    exception.value = null;
    isLoading.value = true;
  }

  Future<void> getBusinessList() async {
    try {
      setupStateVariables();
      await Future.delayed(const Duration(seconds: 2));

      businessList.value = List.from(Business.getFakeList);
      
    } catch (exception) {
      // this.exception.value = except
    } finally {
      isLoading.value = false;
    }
  }


  void navigatetoBusinessDashboard(BuildContext context, Business business) {
    DashboardPage.navigate(context, business.id!);
  }

  
}
