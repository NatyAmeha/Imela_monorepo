import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/order/model/order.response.dart';
import 'package:imela_core/order/order.usecase.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/order/components/order_detail_modal.dart';
import 'package:imela_ui_kit/components/calendar/calendar_utils.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class OrderScheduleViewModel extends GetxController with BaseViewmodel {
  final OrderUsecase _orderUsecase;
  final IExceptiionHandler exceptiionHandler;

  OrderScheduleViewModel(this._orderUsecase, @Named(AppExceptionHandler.injectName) this.exceptiionHandler);

  static OrderScheduleViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<OrderScheduleViewModel>());
  }

  // state variables
  var isLoading = false.obs;
  var isUpdatingOrderStatus = false.obs;
  var exception = Rxn<AppException>();

  var branchOrderSchedules = Rxn<OrderResponse>();
  var orderDetail = Rxn<OrderResponse>();
  var calendarViewType = CalendarViewType.week.obs;

  var filteredBookings = <CalendarBooking>[].obs;

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  List<CalendarBooking> get orderSchedules => branchOrderSchedules.value?.schedules ?? [];

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    getBranchOrderSchedules();
  }

  Future<void> getBranchOrderSchedules() async {
    try {
      isLoading(true);
      final branchId = appViewmodel.selectedBranchId;
      final result = await _orderUsecase.getBranchOrderSchedules(branchId);
      if (!(result?.success ?? false)) {
        exception.value = AppException(message: 'Error occured, please try again');
        return;
      }
      branchOrderSchedules.value = result;
      filteredBookings.value = orderSchedules;
    } catch (e) {
      print(e);
      exception.value = exceptiionHandler.getException(e as Exception);
    } finally {
      isLoading(false);
    }
  }

  Future<void> showOrderScheduleDetails(BuildContext context, List<dynamic> appointments) async {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    try {
      isLoading(true);
      final orderId = appointments.firstOrNull?.notes;

      if (orderId == null) {
        widgetFactory.showFlashMessage(context, message: 'Unable to load order details');
        return;
      }

      final result = await _orderUsecase.getOrderDetails(orderId);
      if (!(result?.success ?? false)) {
        exception.value = AppException(message: 'Error occured, please try again');
        return;
      }
      orderDetail.value = result;
      AppModalSheet.showModal(context, type: AppModalSheetType.DIALOG, pages: [
        ModalContent(
            title: const Text('Order Schedule'),
            content: OrderDetailModal(
              orderInfo: orderDetail.value!.order!,
              widgetFactory: widgetFactory,
              selectedLanguage: appViewmodel.selectedLanguage,
              selectedCurrency: appViewmodel.selectedCurrency,
              businessOrderStatuses: appViewmodel.businessOrderStatuses,
            )),
      ]);
    } catch (e) {
      print(e);
      widgetFactory.showFlashMessage(context, message: 'Unable to load order details');
    } finally {
      isLoading(false);
    }
  }

  void changeCalendarView(CalendarViewType value) {
    calendarViewType.value = value;
  }
}
