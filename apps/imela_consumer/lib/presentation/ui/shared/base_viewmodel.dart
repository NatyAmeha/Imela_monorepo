import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/routing_service.dart';

mixin class BaseViewmodel {
  void initViewmodel({Map<String, dynamic>? data}) {}
  void dispose() {}

  static isViewmodelInitialized<T extends GetxController>(T controller){
    Get.isRegistered<T>() ? Get.find<T>() : Get.put(controller);
  }

  Future<void> handleBackPress(BuildContext context, IRoutingService router, {Map<String, dynamic>? returnValue = const {}}) async {
    await router.goBack(context, returnValue: returnValue);
  }

  Future<T?> navigateTo<T>(BuildContext context, String routeName, IRoutingService router, {Map<String, dynamic>? arguments = const {}}) async {
    return await router.navigateTo<T>(context, routeName, extra: arguments);
  }

 


}
