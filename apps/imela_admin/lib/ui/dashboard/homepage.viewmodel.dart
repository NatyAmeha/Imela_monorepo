import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/ui/business_registration/business_signup_page.dart';
import 'package:imela_admin/ui/dashboard/dashboard_destination.dart';
import 'package:imela_admin/ui/dashboard/dashboard_page.dart';
import 'package:imela_admin/ui/product/product_list/product_list_page.dart';
import 'package:imela_core/business/business.usecase.dart';
import 'package:imela_core/user/auth.usecase.dart';
import 'package:imela_ui_kit/services/app_image_picker.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomePageViewmodel extends GetxController with BaseViewmodel{
  final AuthUsecase authUsecase;
  final BusinessUsecase businessUsecase;

  HomePageViewmodel({required this.authUsecase, required this.businessUsecase});

  AppViewmodel get appcontroller => AppViewmodel.getInstance();

  static HomePageViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<HomePageViewmodel>());
  }

  var selectedDestinationIndex = 0.obs;


  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
  } 


  List<DashboardDestination> getDestinations(){
    return [
      DashboardDestination(name: 'Dashboard', icon: Icons.inventory_2, screen: DashboardPage()),
      DashboardDestination(name: 'Products', icon: Icons.inventory_2, screen: ProductListPage()),
    ];
  }


  Future<String> getbusinessDetails(String businessID ) async {
     try {
       var businessResponse = await businessUsecase.getBusinessDetails(businessID);
      var businessName = businessResponse?.business?.name?.map((e) => e.value).join(',');
      return businessName ?? '';
     } catch (e) {
       print('Error: $e');
        return 'Error: $e';
     }
  }

  void moveToDestination(int index){
    selectedDestinationIndex.value = index;
  }

  Future<void> navigatetoSignupPage(BuildContext context) async {
    BusinessSignupPage.navigate(context);
  }

  

}