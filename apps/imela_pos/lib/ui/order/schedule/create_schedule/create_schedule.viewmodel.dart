import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/calendar/usecase/calendar.usecase.dart';
import 'package:imela_core/order/order.usecase.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/date_utils.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_core/schedule/schedule.usecase.dart';

@injectable
class CreateScheduleViewModel extends GetxController with BaseViewmodel {
  final CalendarUsecase _calendarUsecase;
  final ScheduleUsecase _scheduleUsecase;
  final IExceptiionHandler exceptiionHandler;

  CreateScheduleViewModel(
    this._scheduleUsecase,
    this._calendarUsecase,
    @Named(AppExceptionHandler.injectName) this.exceptiionHandler,
  );

  static CreateScheduleViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<CreateScheduleViewModel>());
  }

  // State variables
  var isLoading = false.obs;
  var isUpdatingOrderStatus = false.obs;
  var exception = Rxn<AppException>();
  var isAssignStaff = false.obs;
  var selectedStaff = <Staff>[].obs;
  var staffList = <Staff>[].obs;
  var note = ''.obs;
  var calendar = Rxn<Calendar>();
  var schedules = <Schedule>[].obs;
  var selectedDates = <DateTime>[].obs;
  var selectedDateRange = <DateTimeRange>[].obs;
  var product = Rxn<Product>();

  // late OrderItem item;
  Schedule? selectedSchedule;
  late String calendarId;
  late String orderId;

  var noteController = TextEditingController().obs;

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();

  List<DateTime> get disabledDates => calendar.value?.getDisabledDates(schedules) ?? [];
  List<DateTime> get bookedDates => schedules.map((e) => e.bookedTimes ?? []).flatten().toList();

  // Mock data for testing

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    // item = data?['item'] as OrderItem;
    selectedSchedule = data?['selectedSchedule'] as Schedule?;
    calendarId = data?['calendarId'] as String;
    orderId = data?['orderId'] as String;
    var context = data?['context'] as BuildContext;

    Future.delayed(Duration.zero, () {
      getCalendarAndSchedule(context, calendarId);
    });
  }

  // Initialize with existing booking if available

  Future<void> getCalendarAndSchedule(BuildContext context, String calendarId) async {
    var widgetFactory = AppViewmodel.getWidgetFactory(context);
    try {
      exception.value = null;
      isLoading.value = true;
      final calendarRes = await _calendarUsecase.getCalendar(calendarId);
      if (calendarRes?.success ?? false) {
        if (calendarRes?.calendar == null) {
          widgetFactory.showFlashMessage(context, message: "Calendar Info not found", backgroundColor: Colors.red);
          return;
        }
        calendar.value = calendarRes!.calendar!;
        final response = await _scheduleUsecase.getSchedulesByCalendarId(calendarId);
        schedules.value = response?.schedules ?? [];
      }
    } catch (e) {
      print('error ${e.toString()}');
      exception.value = exceptiionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  // Validate input before saving
  bool validateInput() {
    if (calendar.value?.dateSelectionType == DateSelectionType.DATE_RANGE.name || calendar.value?.dateSelectionType == DateSelectionType.MULTIPLE_DATE_RANGE.name) {
      if (selectedDateRange.isEmpty) {
        exception.value = AppException(message: 'Please select date(s)');
        return false;
      }
    }
    if (calendar.value?.dateSelectionType == DateSelectionType.MULTIPLE_DATE.name || calendar.value?.dateSelectionType == DateSelectionType.SINGLE_DATE.name) {
      if (selectedDates.isEmpty) {
        exception.value = AppException(message: 'Please select date(s)');
        return false;
      }
    }
    return true;
  }

  Future<void> saveSchedule(BuildContext context) async {
    var widgetFactory = AppViewmodel.getWidgetFactory(context);
    try {
      if (!validateInput()) return;
      isLoading.value = true;
      late Schedule updatedSchedule;
      final dates = <DateTime>[];
      if (calendar.value?.dateSelectionType == DateSelectionType.DATE_RANGE.name) {
        dates.addAll(selectedDateRange.first.getDatesInRange());
      } else {
        dates.addAll(selectedDates);
      }
      if (selectedSchedule?.id != null) {
        updatedSchedule = selectedSchedule!.updateBookedTimes(dates);
        await _scheduleUsecase.updateSchedule(updatedSchedule);
      } else {
        updatedSchedule = selectedSchedule!.updateBookedTimes(dates);
        await _scheduleUsecase.createSchedule(orderId, [updatedSchedule]);
      }

      AppModalSheet.closeModal(result: updatedSchedule);

      // Get.back(result: booking);
    } catch (e) {
      print('error ${e.toString()}');
      widgetFactory.showFlashMessage(context, message: 'Failed to save schedule', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  addDateRange(DateTimeRange? dates) {
    if (dates != null) {
      // selectedDates.value = [dates.start, dates.end];
    }
  }

  void addDate(List<DateTime>? dates) {
    if (dates != null) {
      selectedDates.value = dates;
    }
  }
}

// Mock Staff model for testing
class Staff {
  final String id;
  final String name;

  Staff({required this.id, required this.name});
}
