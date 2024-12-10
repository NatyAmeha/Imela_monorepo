import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:imela_core/business/model/business_order_status.dart';
import 'package:imela_core/order/model/order.model.dart' as orderModel;
import 'package:imela_core/order/order.usecase.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/home/home_page.dart';
import 'package:imela_pos/ui/order/order_details_page.dart';
import 'package:imela_ui_kit/components/list/list_componenet.viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/helpers/pop_up_menu_data.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class OrderViewmodel extends GetxController with BaseViewmodel {
  final OrderUsecase orderUsecase;
  final IExceptiionHandler exceptiionHandler;

  OrderViewmodel({
    required this.orderUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static OrderViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<OrderViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var isUpdatingOrderStatus = false.obs;
  var exception = Rxn<AppException>();

  var orders = <orderModel.Order>[].obs;
  var selectedOrder = Rxn<orderModel.Order>();

  var selectedOrderStatusId = Rxn<String>();

  var selectedOrderStatusIndex = Rxn<int>(0);

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  String get selectedLanguage => appViewmodel.selectedLanguage;

  var ordersController = BaseViewmodel.isViewmodelRegistered(CustomListController<orderModel.Order>(), tag: 'orders');

  bool isOrderSelected(orderModel.Order order) {
    return selectedOrder.value?.id == order.id;
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () {
      getOrders();
    });
  }

  Future<void> getOrders() async {
    try {
      selectedOrder.value = null;
      isLoading.value = true;
      exception.value = null;
      final result = await orderUsecase.getPOSOrders(appViewmodel.selectedBranchId);
      if (result?.success ?? false) {
        if ((result?.orders ?? []).isEmpty) {
          exception.value = AppException(message: 'No orders found');
          return;
        }
        orders.value = result!.orders!;
        ordersController.setItems(orders.value);
      }
    } catch (exception) {
      final ex = exceptiionHandler.getException(exception as Exception);
      this.exception.value = ex;
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedOrder(BuildContext context, orderModel.Order order) {
    selectedOrder.value = order;
    if (Responsive.isSmallScreen(context)) {
      OrderDetailsPage.navigateTo(context);
    }
  }

  List<PopupMenuItemData<String>> getOrderActions() {
    return [
      PopupMenuItemData(label: 'Update order status ', value: 'Update order', onPressed: (context) => showUpdateOrderStatusDialog(context)),
    ];
  }

  void goToHome(BuildContext context) {
    HomePage.navigate(context, replace: true);
  }

  void handleOrderAction(BuildContext context, String value) {
    final selectedPopupItem = getOrderActions().firstWhereOrNull((element) => element.value == value);
    selectedOrderStatusId.value = selectedOrder.value!.status;
    if (selectedPopupItem != null) {
      selectedPopupItem.onPressed?.call(context);
    }
  }

  void showUpdateOrderStatusDialog(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    AppModalSheet.showModal(
      context,
      type: AppModalSheetType.DIALOG,
      pages: [
        ModalContent(
          title: const Text('Update order status'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              widgetFactory.createText(context, 'Select new order status', style: Theme.of(context).textTheme.titleMedium).withPaddingSymetric(horizontal: 16),
              AppListView(
                shrinkWrap: true,
                items: appViewmodel.businessOrderStatuses,
                itemBuilder: (context, orderStatus, index) {
                  return Obx(
                    () => widgetFactory.createRadioListTile(
                      context,
                      title: orderStatus.status.localize(selectedLanguage),
                      subtitle: orderStatus.description.localize(selectedLanguage),
                      value: orderStatus.id,
                      groupValue: selectedOrderStatusId.value,
                      onChanged: (value) {
                        selectedOrderStatusId.value = value;
                      },
                    ),
                  );
                },
              ),
              Obx(
                () => widgetFactory
                    .createButton(
                      context: context,
                      content: const Text('Update'),
                      isLoading: isUpdatingOrderStatus.value,
                      onPressed: () => updateOrderStatus(),
                    )
                    .withPaddingSymetric(vertical: 24, horizontal: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void updateOrderStatus() async {
    try {
      isUpdatingOrderStatus.value = true;
      final result = await orderUsecase.updateOrderStatus(appViewmodel.selectedBusinessId, selectedOrder.value!.id!, selectedOrderStatusId.value!);
      if (result.success ?? false) {
        final updatedOrder = selectedOrder.value!.updateOrderStatus(selectedOrderStatusId.value!);
        selectedOrder.value = updatedOrder;
        AppModalSheet.closeModal();

        orders.value = orders.value.map((e) => e.id == selectedOrder.value!.id ? updatedOrder : e).toList();
      }
    } catch (e) {
      print("exception ex ${e}");
      this.exception.value = AppException(message: 'Unable to update order status', isMainError: false);
    } finally {
      isUpdatingOrderStatus.value = false;
    }
  }
}
