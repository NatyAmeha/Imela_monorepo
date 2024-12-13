import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/home/home.page.dart';
import 'package:imela/presentation/ui/order/order_confirmation/order_confirmation_page.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_core/order/model/order.model.dart' as OrderModel;

@injectable
class OrderConfirmationViewmodel extends GetxController with BaseViewmodel {
  static OrderConfirmationViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<OrderConfirmationViewmodel>());
  }

  OrderModel.Order? order;

  AppController get appController => AppController.getInstance;
  String get selectedCurrency => appController.selectedCurrency.name;
  String get selectedLanguage => appController.selectedLanguage.name;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    order = data?[OrderConfirmationPage.ORDER_INFO_KEY];
  }

  void navigateToHome(BuildContext context) {
    appController.reloadHomePageDestination(true);
    HomePage.navigate(context, replace: true);
  }
}
