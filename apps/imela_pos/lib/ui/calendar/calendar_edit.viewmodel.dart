import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/calendar/usecase/calendar.usecase.dart';
import 'package:imela_core/schedule/schedule.usecase.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class CalendarEditViewModel extends GetxController with BaseViewmodel {
  final CalendarUsecase _calendarUsecase;
  final ScheduleUsecase _scheduleUsecase;
  final IExceptiionHandler _exceptionHandler;

  CalendarEditViewModel({
    required CalendarUsecase calendarUsecase,
    required ScheduleUsecase scheduleUsecase,
    @Named(AppExceptionHandler.injectName) required IExceptiionHandler exceptionHandler,
  })  : _calendarUsecase = calendarUsecase,
        _scheduleUsecase = scheduleUsecase,
        _exceptionHandler = exceptionHandler;

  static CalendarEditViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<CalendarEditViewModel>());
  }

  // State variables
  var isLoading = false.obs;
  var isSaving = false.obs;
  var exception = Rxn<AppException>();
  var calendar = Rxn<Calendar>();
  var schedules = <Schedule>[].obs;
  var originalCalendar = Rxn<Calendar>(); // Store the original calendar for discarding changes
  
  // Date modification states
  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();
  var disabledDates = <DateTime>[].obs;
  
  // OrderInfo management
  var orderInfoList = <CalendarOrderInfo>[].obs;
  var editingOrderInfo = Rxn<CalendarOrderInfo>();
  var selectedDayOfWeek = 1.obs;
  var maxOrderPerDay = 0.obs;
  var maxOrderPerHour = 0.obs;
  
  // Getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  String get selectedLanguage => appViewmodel.selectedLanguage;
  
  // Check if order info exists for a specific day
  bool hasOrderInfoForDay(int dayOfWeek) {
    return orderInfoList.any((info) => info.dayOfWeek == dayOfWeek);
  }
  
  // Get available days without order info
  List<int> get availableDaysForOrderInfo {
    final usedDays = orderInfoList.map((info) => info.dayOfWeek).toSet();
    return List<int>.generate(7, (i) => i + 1).where((day) => !usedDays.contains(day)).toList();
  }
  
  // Get day name from day number
  String getDayName(int dayOfWeek) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    if (dayOfWeek >= 1 && dayOfWeek <= 7) {
      return days[dayOfWeek - 1];
    }
    return '$dayOfWeek';
  }
  
  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    
    final calendarData = data?['calendar'] as Calendar?;
    if (calendarData != null) {
      // Store original calendar for later comparison or restore
      originalCalendar.value = calendarData;
      calendar.value = calendarData;
      
      // Initialize working copies
      fromDate.value = calendarData.fromDate;
      toDate.value = calendarData.toDate;
      disabledDates.value = List<DateTime>.from(calendarData.disabledDays ?? []);
      orderInfoList.value = List<CalendarOrderInfo>.from(calendarData.orderInfo ?? []);
      
      final context = data?['context'] as BuildContext?;
      if (context != null && calendarData.id != null) {
        loadCalendarSchedules(context, calendarData.id!);
      }
    }
  }
  
  // Load schedules for this calendar
  Future<void> loadCalendarSchedules(BuildContext context, String calendarId) async {
    try {
      isLoading.value = true;
      exception.value = null;
      
      final response = await _scheduleUsecase.getSchedulesByCalendarId(calendarId);
      
      if (response?.success == true) {
        schedules.value = response?.schedules ?? [];
      }
    } catch (e) {
      exception.value = _exceptionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }
  
  // Open date picker to update calendar start/end dates
  void updateDateRange(BuildContext context) async {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    
    final initialRange = fromDate.value != null && toDate.value != null 
        ? DateTimeRange(start: fromDate.value!, end: toDate.value!)
        : null;
    
    final result = await widgetFactory.showDateRangePickerUI(
      context,
      initialDateRange: initialRange,
      headerText: 'Select Calendar Date Range',
    );
    
    if (result != null) {
      fromDate.value = result.start;
      toDate.value = result.end;
    }
  }
  
  // Add disabled dates to the calendar
  void addDisabledDates(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    final isLargeScreen = Responsive.isLargeScreen(context);
    final dateSelectionType = calendar.value?.dateSelectionType;
    
    // Modal sheet or sidebar based on screen size
    if (isLargeScreen) {
      // Show date picker embedded in a side panel
      // This would be a custom implementation depending on your UI structure
      _showDatePickerByType(context, dateSelectionType ?? 'SINGLE_DATE');
    } else {
      // Show modal with date picker
      AppModalSheet.showModal(
        context,
        type: AppModalSheetType.BOTTOMSHEET,
        pages: [
          ModalContent(
            title: const Text('Add Disabled Dates'),
            content: _buildDatePickerByType(context, dateSelectionType ?? 'SINGLE_DATE'),
          ),
        ],
      );
    }
  }
  
  // Show date picker based on calendar selection type
  void _showDatePickerByType(BuildContext context, String selectionType) {
    switch (selectionType) {
      case 'DATE_RANGE':
      case 'MULTIPLE_DATE_RANGE':
        _showDateRangePicker(context);
        break;
      case 'MULTIPLE_DATE':
        _showMultiDatePicker(context);
        break;
      case 'SINGLE_DATE':
      default:
        _showSingleDatePicker(context);
        break;
    }
  }
  
  // Build date picker widget based on selection type
  Widget _buildDatePickerByType(BuildContext context, String selectionType) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    
    switch (selectionType) {
      case 'DATE_RANGE':
      case 'MULTIPLE_DATE_RANGE':
        return widgetFactory.createDateRangePicker(
          context: context,
          firstDate: fromDate.value,
          lastDate: toDate.value,
          onRangeSelected: (range) {
            if (range != null) {
              addDateRangeToDisabledDates(range);
              AppModalSheet.closeModal();
            }
          },
        );
      case 'MULTIPLE_DATE':
        return widgetFactory.createDateTimePicker(
          context: context,
          firstDate: fromDate.value,
          lastDate: toDate.value,
          enableMultiSelect: true,
          onDateSelected: (dates) {
            if (dates != null && dates.isNotEmpty) {
              addToDisabledDates(dates);
              AppModalSheet.closeModal();
            }
          },
        );
      case 'SINGLE_DATE':
      default:
        return widgetFactory.createDateTimePicker(
          context: context,
          firstDate: fromDate.value,
          lastDate: toDate.value,
          enableMultiSelect: false,
          onDateSelected: (dates) {
            if (dates != null && dates.isNotEmpty) {
              addToDisabledDates(dates);
              AppModalSheet.closeModal();
            }
          },
        );
    }
  }
  
  // Show date range picker
  void _showDateRangePicker(BuildContext context) async {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    
    final result = await widgetFactory.showDateRangePickerUI(
      context,
      firstDate: fromDate.value,
      lastDate: toDate.value,
      headerText: 'Select Dates to Disable',
    );
    
    if (result != null) {
      addDateRangeToDisabledDates(result);
    }
  }
  
  // Show multiple date picker
  void _showMultiDatePicker(BuildContext context) async {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    
    final result = await widgetFactory.showDateTimePicker(
      context,
      firstDate: fromDate.value,
      lastDate: toDate.value,
      disabledDates: disabledDates,
      confirmText: 'Add',
      cancelText: 'Cancel',
    );
    
    if (result != null) {
      addToDisabledDates([result]);
    }
  }
  
  // Show single date picker
  void _showSingleDatePicker(BuildContext context) async {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    
    final result = await widgetFactory.showDateTimePicker(
      context,
      firstDate: fromDate.value,
      lastDate: toDate.value,
      disabledDates: disabledDates,
      confirmText: 'Add',
      cancelText: 'Cancel',
    );
    
    if (result != null) {
      addToDisabledDates([result]);
    }
  }
  
  // Helper method to add dates to disabled dates list
  void addToDisabledDates(List<DateTime> dates) {
    // Normalize dates (remove time component)
    final currentDates = Set<DateTime>.from(
      disabledDates.map((date) => DateTime(date.year, date.month, date.day))
    );
    
    for (final date in dates) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (!currentDates.contains(normalizedDate)) {
        disabledDates.add(normalizedDate);
        currentDates.add(normalizedDate);
      }
    }
  }
  
  // Add date range to disabled dates
  void addDateRangeToDisabledDates(DateTimeRange range) {
    final dates = <DateTime>[];
    var current = range.start;
    
    // Generate all dates in the range
    while (current.isBefore(range.end) || current.isAtSameMomentAs(range.end)) {
      dates.add(DateTime(current.year, current.month, current.day));
      current = current.add(const Duration(days: 1));
    }
    
    addToDisabledDates(dates);
  }
  
  // Remove a date from disabled dates
  void removeDisabledDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    disabledDates.removeWhere(
      (d) => DateTime(d.year, d.month, d.day).isAtSameMomentAs(normalizedDate)
    );
  }
  
  // Add a new order info
  void addOrderInfo(BuildContext context) {
    if (availableDaysForOrderInfo.isEmpty) {
      // All days already have order info
      final widgetFactory = AppViewmodel.getWidgetFactory(context);
      widgetFactory.showFlashMessage(
        context, 
        message: 'All days of the week already have rules',
        backgroundColor: Colors.orange,
      );
      return;
    }
    
    // Reset values
    selectedDayOfWeek.value = availableDaysForOrderInfo.first;
    maxOrderPerDay.value = 10; // Default value
    maxOrderPerHour.value = 2; // Default value
    
    // Show dialog to add order info
    _showOrderInfoDialog(context, isEditing: false);
  }
  
  // Edit existing order info
  void editOrderInfo(BuildContext context, CalendarOrderInfo info) {
    editingOrderInfo.value = info;
    selectedDayOfWeek.value = info.dayOfWeek ?? 1;
    maxOrderPerDay.value = info.maxOrderPerDay ?? 0;
    maxOrderPerHour.value = info.maxOrderPerHour ?? 0;
    
    _showOrderInfoDialog(context, isEditing: true);
  }
  
  // Remove order info for a day
  void removeOrderInfo(CalendarOrderInfo info) {
    orderInfoList.removeWhere((item) => item.dayOfWeek == info.dayOfWeek);
  }
  
  // Show dialog to add/edit order info
  void _showOrderInfoDialog(BuildContext context, {required bool isEditing}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Day Rule' : 'Add Day Rule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Day of week dropdown (only enabled for new entries)
            Obx(() => DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Day of Week'),
              value: selectedDayOfWeek.value,
              items: (isEditing ? [selectedDayOfWeek.value] : availableDaysForOrderInfo)
                  .map((day) => DropdownMenuItem(
                    value: day,
                    child: Text(getDayName(day)),
                  ))
                  .toList(),
              onChanged: isEditing ? null : (value) {
                if (value != null) selectedDayOfWeek.value = value;
              },
            )),
            
            // Max orders per day
            TextField(
              decoration: const InputDecoration(labelText: 'Max Orders Per Day'),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: maxOrderPerDay.value.toString()),
              onChanged: (value) {
                maxOrderPerDay.value = int.tryParse(value) ?? 0;
              },
            ),
            
            // Max orders per hour
            TextField(
              decoration: const InputDecoration(labelText: 'Max Orders Per Hour'),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: maxOrderPerHour.value.toString()),
              onChanged: (value) {
                maxOrderPerHour.value = int.tryParse(value) ?? 0;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (isEditing) {
                _updateOrderInfo();
              } else {
                _saveNewOrderInfo();
              }
              Navigator.pop(context);
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }
  
  // Save new order info
  void _saveNewOrderInfo() {
    final newInfo = CalendarOrderInfo(
      dayOfWeek: selectedDayOfWeek.value,
      maxOrderPerDay: maxOrderPerDay.value,
      maxOrderPerHour: maxOrderPerHour.value,
    );
    
    orderInfoList.add(newInfo);
  }
  
  // Update existing order info
  void _updateOrderInfo() {
    if (editingOrderInfo.value == null) return;
    
    final updatedInfo = editingOrderInfo.value!.copyWith(
      maxOrderPerDay: maxOrderPerDay.value,
      maxOrderPerHour: maxOrderPerHour.value,
    );
    
    final index = orderInfoList.indexWhere(
      (info) => info.dayOfWeek == updatedInfo.dayOfWeek
    );
    
    if (index >= 0) {
      orderInfoList[index] = updatedInfo;
    }
    
    editingOrderInfo.value = null;
  }
  
  // Discard changes and exit edit mode
  void discardChanges(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('Are you sure you want to discard your changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
  
  // Save changes to the calendar
  Future<void> saveCalendar(BuildContext context) async {
    if (calendar.value == null) return;
    
    try {
      isSaving.value = true;
      exception.value = null;
      
      // Create updated calendar
      final updatedCalendar = calendar.value!.copyWith(
        fromDate: fromDate.value,
        toDate: toDate.value,
        disabledDays: disabledDates,
        orderInfo: orderInfoList,
      );
      
      final response = await _calendarUsecase.updateCalendar(updatedCalendar);
      
      if (response?.success == true) {
        // Success - return updated calendar to caller
        final widgetFactory = AppViewmodel.getWidgetFactory(context);
        widgetFactory.showFlashMessage(
          context, 
          message: 'Calendar updated successfully'
        );
        
        // Return the updated calendar
        if (response?.calendar != null) {
          Navigator.of(context).pop(response!.calendar);
        } else {
          Navigator.of(context).pop(updatedCalendar);
        }
      } else {
        exception.value = AppException(
          message: response?.message ?? 'Failed to update calendar',
          isMainError: true,
        );
      }
    } catch (e) {
      exception.value = _exceptionHandler.getException(e as Exception);
    } finally {
      isSaving.value = false;
    }
  }
} 