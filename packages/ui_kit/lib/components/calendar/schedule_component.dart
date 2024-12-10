import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_ui_kit/components/calendar/calendar.viewmodel.dart';
import 'package:imela_ui_kit/components/calendar/calendar_utils.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleComponent<T> extends StatefulWidget {
  static const dataSourceKey = 'dataSource';
  final CalendarDataSource<T> dataSource;
  final CalendarViewType viewType;
  final Function(List<dynamic>)? onEventTap;

  ScheduleComponent({
    super.key,
    required this.dataSource,
    required this.viewType,
    this.onEventTap,
  });

  @override
  State<ScheduleComponent<T>> createState() => _ScheduleComponentState<T>();
}

class _ScheduleComponentState<T> extends State<ScheduleComponent<T>> with SingleTickerProviderStateMixin {
  final CalendarViewModel viewModel = CalendarViewModel.getInstance();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    viewModel.initViewmodel(data: {ScheduleComponent.dataSourceKey: widget.dataSource});
    _tabController = TabController(length: 4, vsync: this); // Assuming 3 tabs for different views
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TabBar for switching calendar views
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Schedules'),
            Tab(text: 'Day View'),
            Tab(text: 'Week View'),
            Tab(text: 'Month View'),

          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCalendarView(CalendarView.schedule),
              _buildCalendarView(CalendarView.day),
              _buildCalendarView(CalendarView.week),
              _buildCalendarView(CalendarView.month),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarView(CalendarView view) {
    return Obx(() {
      return SfCalendar(
        view: view,
        dataSource: viewModel.appointmentDataSource.value,
        allowAppointmentResize: true,
        allowDragAndDrop: true,
        showDatePickerButton: true,
        showNavigationArrow: true,
        resourceViewSettings: const ResourceViewSettings(
            visibleResourceCount: 3, // Number of visible resources
            showAvatar: true),
        onTap: (CalendarTapDetails details) {
          if (details.appointments != null && details.appointments!.isNotEmpty) {
            widget.onEventTap?.call(details.appointments!);
          }
        },
      );
    });
  }
}
