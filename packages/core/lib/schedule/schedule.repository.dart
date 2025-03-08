import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/order/model/order.response.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';
import 'package:imela_data/network/graphql/schedule/__generated__/create_order_schedule.data.gql.dart';
import 'package:imela_data/network/graphql/schedule/__generated__/create_order_schedule.req.gql.dart';
import 'package:imela_data/network/graphql/schedule/__generated__/get_schedule_by_calendar.data.gql.dart';
import 'package:imela_data/network/graphql/schedule/__generated__/get_schedule_by_calendar.req.gql.dart';
import 'package:imela_data/network/graphql/schedule/__generated__/update_schedule.data.gql.dart';
import 'package:imela_data/network/graphql/schedule/__generated__/update_schedule.req.gql.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';

abstract class IScheduleRepository {
  Future<OrderResponse?> createSchedule(String orderId, List<Schedule> schedules);
  Future<OrderResponse?> updateSchedule(Schedule schedule);
  Future<OrderResponse?> getSchedulesByCalendarId(String calendarId, {required ApiDataFetchPolicy fetchPolicy});
}

@Injectable(as: IScheduleRepository)
@Named(ScheduleRepository.injectName)
class ScheduleRepository implements IScheduleRepository {
  static const injectName = 'ScheduleRepository';
  final IGraphQLDataSource _graphQLDataSource;

  ScheduleRepository(@Named(GraphqlDatasource.injectName) this._graphQLDataSource);

  @override
  Future<OrderResponse?> createSchedule(String orderId, List<Schedule> schedules) async {
    final request = GCreateOrderScheduleReq(
      (b) => b
        ..vars.orderId = orderId
        ..vars.schedule.addAll(schedules.toScheduleInput()),
    );
    final result = await _graphQLDataSource.request<GCreateOrderScheduleData>(request, type: 'CREATE_ORDER_SCHEDULE');
    if (result?.addOrderSchedules == null) {
      return null;
    }
    return OrderResponse.fromJson(result?.toJson() ?? {});
  }

  @override
  Future<OrderResponse?> updateSchedule(Schedule schedule) async {
    final request = GUpdateScheduleReq(
      (b) => b
        ..vars.scheduleId = schedule.id
        ..vars.schedule.update(
              (input) => input
                ..calendarId = schedule.calendarId
                ..note.addAll(schedule.note?.toLocalizedFieldInput() ?? [])
                ..productId = schedule.productId
                ..orderId = schedule.orderId
                
                ..bookedTimes.addAll(schedule.bookedTimes?.map((e) => GDateTime(e.toUtc().toIso8601String())) ?? []),
            ),
    );
    final result = await _graphQLDataSource.request<GUpdateScheduleData>(request, type: 'UPDATE_SCHEDULE');
    if (result?.updateOrderSchedules == null) {
      return null;
    }
    return OrderResponse.fromJson(result?.toJson() ?? {});
  }

  @override
  Future<OrderResponse?> getSchedulesByCalendarId(String calendarId, {required ApiDataFetchPolicy fetchPolicy}) async {
    final request = GGetOrderSchedulesByCalendarReq((b) => b
      ..vars.calendarId = calendarId
      ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy));
    final result = await _graphQLDataSource.request<GGetOrderSchedulesByCalendarData>(request, type: 'GET_SCHEDULES_BY_CALENDAR_ID', isMainError: true);
    return OrderResponse.fromJson(result?.getOrderSchedulesByCalendar.toJson() ?? {});
  }
}
