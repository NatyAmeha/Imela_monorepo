import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:imela_core/business/model/business_order_status.dart';
import 'package:imela_core/business/model/payment_method.model.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/order/model/order.model.dart' as orderModel;
import 'package:imela_core/order/order.usecase.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/home/home_page.dart';
import 'package:imela_pos/ui/order/order_details_page.dart';
import 'package:imela_pos/ui/order/schedule/create_schedule/create_schedule_page.dart';
import 'package:imela_pos/ui/payment/component/payment_method_input_component.dart';
import 'package:imela_ui_kit/components/list/list_componenet.viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_ui_kit/helpers/pop_up_menu_data.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/number_utils.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';

// Enum for search types
enum OrderSearchType {
  customerName,
  customerPhone,
  orderCode;

  String get label {
    switch (this) {
      case OrderSearchType.customerName:
        return 'Customer Name';
      case OrderSearchType.customerPhone:
        return 'Phone Number';
      case OrderSearchType.orderCode:
        return 'Order Code';
    }
  }
}

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
  var isOrderDetailsLoading = false.obs;
  var isUpdatingOrderStatus = false.obs;
  var exception = Rxn<AppException>();

  var orders = <orderModel.Order>[].obs;
  var selectedOrder = Rxn<orderModel.Order>();

  var selectedOrderStatusId = Rxn<String>();

  var selectedOrderStatusIndex = Rxn<int>(0);

  // remaining amount payment variables
  var selectedPaymentMethod = Rxn<PaymentMethod>();
  var amountEntered = 0.obs;
  var initialPaymentController = TextEditingController();
  var paymentMethodAmountController = TextEditingController();
  var resetPaymentMethodAmountController = false.obs;
  double get totalPaidAmount {
    return paymentMethodControllers.value.values.sumBy((entry) => double.tryParse(entry.text) ?? 0.0).getPresision(2);
  }
  double get remainingAmountFromInitialPayment {
    if (selectedOrder.value?.remainingAmount == null || selectedOrder.value?.remainingAmount == 0) {
      return 0.0;
    }
    return (selectedOrder.value?.remainingAmount ?? 0.0 - totalPaidAmount).getPresision(2);
  }

  var paymentMethodControllers = <String, TextEditingController>{}.obs;

  // Add new state variables for tabs
  var selectedTabIndex = 0.obs;
  var selectedOrderStatus = <String>[].obs;

  // Add search-related state variables
  var searchQuery = ''.obs;
  var selectedSearchType = Rx<OrderSearchType>(OrderSearchType.customerName);

  

  // Getter for unique order statuses plus "All"
  List<String> get orderStatusTabs {
    final statusSet = orders.map((order) => order.getOrderStatus(selectedLanguage, appViewmodel.businessOrderStatuses)).toSet();
    return ['All', ...statusSet];
  }

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
    var context = data?['context'];
    Future.delayed(Duration.zero, () {
      getOrders(context);
    });
  }

  Future<void> getOrders(BuildContext context, {bool resetSelectedOrder = false}) async {
    try {
      if (resetSelectedOrder) {
        selectedOrder.value = null;
      }
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
        filterOrdersByStatus(context, ['All']); // Apply current filter
        if (resetSelectedOrder || selectedOrder.value == null) {
          setSelectedOrder(context, filteredOrders.first);
        }
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
    getOrderDetails(context, order.id!);
  }

  Future<void> getOrderDetails(BuildContext context, String orderId) async {
    try {
      isOrderDetailsLoading(true);
      exception.value = null;
      final orderResponse = await orderUsecase.getOrderDetails(orderId);
      if (orderResponse?.success == true) {
        selectedOrder.value = orderResponse?.order;
        if (selectedOrder.value?.businessId != null) {}
      }
    } catch (ex) {
      final widgetFactory = AppViewmodel.getWidgetFactory(context);
      widgetFactory.showFlashMessage(context, message: 'Unable to get order details', isPersistent: true, onActinClicked: () {
        getOrderDetails(context, orderId);
      });
    } finally {
      isOrderDetailsLoading(false);
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

  Future<void> showPaymentReceiptModal(BuildContext context) async {
    AppModalSheet.showModal(context, type: AppModalSheetType.SIDESHEET, pages: [
      ModalContent(
        title: const Text('Upload payment receipt'),
        content: Obx(
          () => PaymentMethodInputComponent(
            controller: paymentMethodAmountController,
            paymentMethods: PaymentMethod.getFakePaymentMethods(),
            selectedLanguage: appViewmodel.selectedLanguage,
            selectedPaymentMethod: selectedPaymentMethod.value,
            paymentMethodControllers: paymentMethodControllers.value,
            canEnablePlaceOrder: true,
            onSelected: (paymentMethod) {
              selectPaymentMethod(paymentMethod);
            },
            onDelete: (paymentMethod) {
              removeEntredAmount(paymentMethod);
            },
            onAmountChanged: (p0) {
              updateAmountEntered();
            },
            paidAmount: totalPaidAmount.toString(),
            remainingAmount: remainingAmountFromInitialPayment.toString(),
            callToActionText: 'Add Payment',
            onCallToAction: () {
              print('call to action');
            },
            onOptionChanged: (paymentMethodId, option) {
              // updatePaymentMethodOption(paymentMethodId, option);
            },
          ),
        ),
      )
    ]);
  }

  Future<void> showCreateOrUpdateScheduleDialog(BuildContext context, {Schedule? schedule}) async {
    final result = await AppModalSheet.showModal<Schedule>(context, type: AppModalSheetType.SIDESHEET, pages: [
      ModalContent(
        title: Text('Create Schedule'),
        content: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          child: CreateSchedulePage(orderId: selectedOrder.value!.id!, selectedSchedule: schedule, calendarId: schedule?.calendarId ?? ''),
        ),
      ),
    ]);
    if (result != null) {
      selectedOrder.value = selectedOrder.value!.updateSchedules(result);
      orders.value = [...orders.value.map((order) => order.id == selectedOrder.value!.id ? selectedOrder.value! : order)];
    }
  }

  void updateAmountEntered() {
    paymentMethodControllers.refresh();
  }

  bool isPaymentSelected(PaymentMethod paymentInfo) {
    return paymentInfo.id == selectedPaymentMethod.value?.id;
  }

  void selectPaymentMethod(PaymentMethod paymentInfo) {
    selectedPaymentMethod.value = paymentInfo;
    selectedPaymentMethod.refresh();
    paymentMethodControllers.refresh();
  }

  void removeEntredAmount(PaymentMethod paymentMethod) {
    paymentMethodControllers.value[paymentMethod.id!]?.clear();
    paymentMethodControllers.refresh();
  }

  // Method to group orders by date
  // void groupOrdersByDate() {
  //   final grouped = <DateTime, List<orderModel.Order>>{};
    
  //   for (var order in filteredOrders) {
  //     // Convert to date only (ignore time)
  //     final orderDate = DateTime(
  //       order.createdAt!.year,
  //       order.createdAt!.month,
  //       order.createdAt!.day,
  //     );
      
  //     if (!grouped.containsKey(orderDate)) {
  //       grouped[orderDate] = [];
  //     }
  //     grouped[orderDate]!.add(order);
  //   }
    
  //   // Sort dates in descending order (newest first)
  //   final sortedKeys = grouped.keys.toList()
  //     ..sort((a, b) => b.compareTo(a));
    
  //   // Create new map with sorted keys
  //   final sortedGrouped = {
  //     for (var date in sortedKeys) 
  //       date: grouped[date]!
  //   };
    
  //   groupedOrders.value = sortedGrouped;
  // }

  // Add getters instead
  List<orderModel.Order> get filteredOrders {
    var filtered = orders.value;
    
    // Apply status filter
    if (!(selectedOrderStatus.isEmpty || selectedOrderStatus.contains('All'))) {
      filtered = filtered.where((order) => 
        selectedOrderStatus.contains(order.getOrderStatus(selectedLanguage, appViewmodel.businessOrderStatuses))
      ).toList();
    }

    // Apply search if query exists
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((order) {
        switch (selectedSearchType.value) {
          case OrderSearchType.customerName:
            return order.customer?.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false;
          case OrderSearchType.customerPhone:
            return order.customer?.phoneNumber?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false;
          case OrderSearchType.orderCode:
            return order.code?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false;
        }
      }).toList();
    }

    return filtered;
  }

  Map<DateTime, List<orderModel.Order>> get groupedOrders {
    final grouped = <DateTime, List<orderModel.Order>>{};
    
    for (var order in filteredOrders) {
      // Convert to date only (ignore time)
      final orderDate = DateTime(
        order.createdAt!.year,
        order.createdAt!.month,
        order.createdAt!.day,
      );
      
      if (!grouped.containsKey(orderDate)) {
        grouped[orderDate] = [];
      }
      grouped[orderDate]!.add(order);
    }
    
    // Sort dates in descending order (newest first)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    // Create new map with sorted keys
    return {
      for (var date in sortedKeys) 
        date: grouped[date]!
    };
  }

  // Modify filterOrdersByStatus to not set filteredOrders
  void filterOrdersByStatus(BuildContext context, List<String> selectedStatus) {
    selectedOrderStatus.value = selectedStatus;

    // Update selected order if needed
    if (filteredOrders.isNotEmpty) {
      if (selectedOrder.value == null || 
          !filteredOrders.contains(selectedOrder.value)) {
        setSelectedOrder(context, filteredOrders.first);
      }
    } else {
      selectedOrder.value = null;
    }
  }

  // Method to handle search
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  // Method to change search type
  void updateSearchType(OrderSearchType type) {
    selectedSearchType.value = type;
    searchQuery.value = ''; // Clear search when changing type
  }

  void showCalendarSelector(BuildContext context) {
    selectedOrder.value?.getOrderCalendars();
  }
}
