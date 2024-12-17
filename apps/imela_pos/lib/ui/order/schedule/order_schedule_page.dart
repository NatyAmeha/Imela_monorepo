import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/order/schedule/viewmodel.schedule.dart';
import 'package:imela_ui_kit/components/calendar/calendar_utils.dart';
import 'package:imela_ui_kit/components/calendar/calendar_data_source.generator.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/helpers/pop_up_menu_data.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_ui_kit/components/calendar/schedule_component.dart';

class OrderSchedulePage extends StatefulWidget {
  static const routeName = '/order-schedule';
  const OrderSchedulePage({super.key});

  @override
  State<OrderSchedulePage> createState() => _OrderSchedulePageState();

  static void navigateTo(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _OrderSchedulePageState extends State<OrderSchedulePage> {
  final OrderScheduleViewModel viewModel = OrderScheduleViewModel.getInstance();
  late final WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewModel.initViewmodel(data: {'context': context});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Schedule')),
      body: Obx(
        () => PageContentLoader(
          isLoading: viewModel.isLoading.value,
          showContent: !(viewModel.exception.value?.isMainError ?? false),
          exception: viewModel.exception.value,
          hasError: viewModel.exception.value?.isMainError ?? false,
          content: ScheduleComponent<CalendarBooking>(
            dataSource: OrderBookingScheduleDataSource(viewModel.filteredBookings),
            viewType: viewModel.calendarViewType.value,
            onEventTap: (bookings) {
              viewModel.showOrderScheduleDetails(context, bookings);
            },
          ),
          onTryAgain: () {},
        ),
      ),
    );
  }
}
