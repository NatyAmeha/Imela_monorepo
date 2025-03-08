import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/order/schedule/create_schedule/create_schedule.viewmodel.dart';
import 'package:imela_ui_kit/components/calendar/date_range_picker.dart';
import 'package:imela_ui_kit/components/calendar/date_time_picker.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class CreateSchedulePage extends StatefulWidget {
  static const String routeName = '/create-schedule';
  final Schedule? selectedSchedule;
  final String calendarId;
  final String orderId;

  const CreateSchedulePage({
    super.key,
    this.selectedSchedule,
    required this.calendarId,
    required this.orderId,
  });

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();

  static void navigateTo(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  late CreateScheduleViewModel viewModel;
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    viewModel = CreateScheduleViewModel.getInstance();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewModel.initViewmodel(data: {
      'context': context,
      'selectedSchedule': widget.selectedSchedule,
      'calendarId': widget.calendarId,
      'orderId': widget.orderId,
    });

    // Load mock data for now
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.selectedSchedule != null ? 'Edit Schedule' : 'Create Schedule')),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewModel.isLoading.value,
          showContent: !(viewModel.exception.value?.isMainError ?? false),
          exception: viewModel.exception.value,
          hasError: viewModel.exception.value?.isMainError ?? false,
          onTryAgain: () {
            viewModel.getCalendarAndSchedule(context, widget.calendarId);
          },
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Staff Assignment Switch
              // widgetFactory.createSwitch(
              //   viewModel.isAssignStaff.value,
              //   (value) => viewModel.isAssignStaff.value = value,
              // ),

              // // Staff Dropdown
              // if (viewModel.isAssignStaff.value) ...[
              //   const SizedBox(height: 16),
              //   widgetFactory.createDropDownBeta<Staff>(
              //     context,
              //     selectedValues: viewModel.selectedStaff.value,
              //     isMultiSelection: true,
              //     itemBuilder: (context, Staff, isSelected, onSelected) => Text(Staff.name),
              //     options: viewModel.staffList,
              //     onChanged: (value) => viewModel.selectedStaff.value = value,
              //     hintText: 'Select Staff',
              //   ),
              // ],

              // Date Selection
              const SizedBox(height: 24),
              Expanded(
                child: viewModel.calendar.value?.dateSelectionType == DateSelectionType.DATE_RANGE.name
                    ? Obx(
                        () => DateRangePicker(
                          initialDateRange: DateTimeRange(start: viewModel.bookedDates.first, end: viewModel.bookedDates.last),
                          firstDate: viewModel.calendar.value?.fromDate ?? DateTime.now(),
                          lastDate: viewModel.calendar.value?.toDate ?? DateTime.now().add(const Duration(days: 30)),
                          onConfirm: (dates) => viewModel.addDateRange(dates),
                          disabledDates: viewModel.disabledDates,
                          showHeader: false,
                          showTodayButton: false,
                        ),
                      )
                    : Obx(
                        () => DateTimePicker(
                          initialDates: viewModel.bookedDates,
                          enableMultiSelect: viewModel.calendar.value?.dateSelectionType == DateSelectionType.MULTIPLE_DATE.name,
                          firstDate: viewModel.calendar.value?.fromDate ?? DateTime.now(),
                          lastDate: viewModel.calendar.value?.toDate ?? DateTime.now().add(const Duration(days: 30)),
                          onConfirm: (dates) => viewModel.addDate(dates),
                          disabledDates: viewModel.disabledDates,
                          showHeader: true,
                          showTodayButton: false,
                        ),
                      ),
              ),

              // Note Section
              const SizedBox(height: 24),

              widgetFactory.createButton(
                context: context,
                content: Text(widget.selectedSchedule != null ? 'Update Schedule' : 'Add Schedule'),
                isLoading: viewModel.isUpdatingOrderStatus.value,
                onPressed: () => viewModel.saveSchedule(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
