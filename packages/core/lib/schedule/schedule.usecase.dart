import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/order/model/order.response.dart';
import 'package:imela_core/schedule/schedule.repository.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class ScheduleUsecase {
  final IScheduleRepository _scheduleRepo;

  const ScheduleUsecase(@Named(ScheduleRepository.injectName) this._scheduleRepo);

  Future<OrderResponse?> createSchedule(String orderId, List<Schedule> schedules) async {
    final result = await _scheduleRepo.createSchedule(orderId, schedules);
    return result;
  }

  Future<OrderResponse?> updateSchedule(Schedule schedule) async {
    final result = await _scheduleRepo.updateSchedule(schedule);
    return result;
  }

  Future<OrderResponse?> getSchedulesByCalendarId(String calendarId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final result = await _scheduleRepo.getSchedulesByCalendarId(calendarId, fetchPolicy: fetchPolicy);
    return result;
  }
} 