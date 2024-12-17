import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/home/home.page.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_details_page.dart';
import 'package:imela/presentation/ui/shared/base_viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/business/business.usecase.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/business/model/business_order_status.dart';
import 'package:imela_core/business/model/business_response.dart';
import 'package:imela_core/order/model/order_item.model.dart';
import 'package:imela_core/order/order.usecase.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_core/order/model/order.model.dart' as OrderModel;
import 'package:injectable/injectable.dart';

@injectable
class OrderDetailviewmodel extends GetxController with BaseViewmodel {
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;
  OrderUsecase orderUsecase;
  BusinessUsecase businessUsecase;

  OrderDetailviewmodel({
    required this.orderUsecase,
    required this.businessUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  // page state variables
  var isLoading = false.obs;
  var isBusinessLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;

  var orderInfo = Rxn<OrderModel.Order>();
  var businessInfo = Rxn<BusinessResponse>();

  // controllers
  var orderItemsController = Get.put(CustomListController<OrderItem>(), tag: 'OrderItemsController');

  // getters
  var appViewmodel = AppController.getInstance;
  List<Business> get orderBusinesses => businessInfo.value?.businesses ?? [];
  List<BusinessOrderStatus> get orderStatuses {
    final statuses = orderBusinesses.map((business) => business.orderStatuses ?? []).flattened.toList();
    return statuses.isEmpty ? BusinessOrderStatus.defaultOrderStatuses : statuses;
  }
  List<String> get orderStatusString => orderStatuses.map((e) => e.status.localize(selectedLanguage)).toList();
  String get selectedLanguage => appViewmodel.selectedLanguageUpdated.value;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    var orderId = data?['orderId'] as String?;
    if (orderId != null) {
      getOrderDetails(orderId);
    }
  }

  Future<void> getOrderDetails(String orderId) async {
    try {
      isLoading.value = true;
      exception.value = null;
      orderInfo.value = null;
      final orderResponse = await orderUsecase.getOrderDetails(orderId);
      if (orderResponse?.success == true) {
        orderInfo.value = orderResponse?.order;
        if (orderInfo.value?.businessId != null) {
          getBusinessesFromOrder(orderInfo.value?.businessId ?? []);
        }
      }
    } catch (ex) {
      print("Exception: $ex");
      exception.value = exceptiionHandler.getException(ex as Exception);
    } finally {
      isLoading(false);
    }
  }

  Future<void> getBusinessesFromOrder(List<String> businessIds) async {
    try {
      isBusinessLoading.value = true;
      final result = await businessUsecase.getBusinessesFromOrder(businessIds);
      if (result?.success == true) {
        businessInfo.value = result;
      }
    } catch (ex) {
      exception.value = exceptiionHandler.getException(ex as Exception);
    } finally {
      isBusinessLoading.value = false;
    }
  }

  void navigateToHome(BuildContext context) {
    appViewmodel.reloadHomePageDestination(true);
    HomePage.navigate(context, replace: true);
  }

  String? getBusinessName(String businessId) {
    return orderBusinesses.firstWhereOrNull((business) => business.id == businessId)?.name.localize(appViewmodel.selectedLanguageUpdated.value);
  }

  void moveToRewards(BuildContext context) {
    final businessId = orderInfo.value?.businessId?.firstOrNull;
    if (businessId != null) {
      final business = orderBusinesses.firstWhereOrNull((business) => business.id == businessId);
      LoyaltyDetailsPage.navigate(context, programName: business!.name.localize(selectedLanguage), businessId: businessId);
    }
  }
}
