import 'package:get/get.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_ui_kit/components/calendar/schedule_component.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarViewModel extends GetxController with BaseViewmodel {
  // List of all bookings
  var appointmentDataSource = Rxn<CalendarDataSource<Object?>>();

  // Filters
  var selectedUserId = ''.obs;
  var selectedOrderId = ''.obs;
  var selectedProductId = ''.obs;

  // Tab index
  var selectedTabIndex = 0.obs;

  // Initialize with fake data
  @override
  void onInit() {
    super.onInit();
    // Initialize selected tab index if needed
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel();
    final dataSource = data?[ScheduleComponent.dataSourceKey] as CalendarDataSource<Object?>;
    appointmentDataSource.value = dataSource;
    // Set initial tab index if provided
    selectedTabIndex.value = data?['initialTabIndex'] ?? 0;
  }

  void updateTabIndex(int index) {
    selectedTabIndex.value = index;
  }

  static CalendarViewModel getInstance() => BaseViewmodel.isViewmodelRegistered(CalendarViewModel());

  // Apply filters
}
