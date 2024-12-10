import 'package:imela_core/calendar/dto/calendar.response.dart';
import 'package:imela_data/network/graphql/calendar/__generated__/get_calendar.data.gql.dart';
import 'package:imela_data/network/graphql/calendar/__generated__/get_calendar.req.gql.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

abstract class ICalendarRepository {
  Future<CalendarResponse?> getCalendar(String calendarId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  // Future<CalendarResponse?> createCalendarBooking(String calendarId, List<DateTime> bookingTimes);
}

@Injectable(as: ICalendarRepository)
@Named(CalendarRepository.injectName)
class CalendarRepository implements ICalendarRepository {
  static const injectName = 'CalendarRepository';
  final IGraphQLDataSource _graphQLDataSource;
  // final IDBDataSource _dbDataSource;

  const CalendarRepository(
    @Named(GraphqlDatasource.injectName) this._graphQLDataSource,
    // @Named(POSDBDataSource.injectName) this._dbDataSource,
  );
  @override
  Future<CalendarResponse?> getCalendar(String calendarId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetCalendarReq(
      (b) => b
        ..vars.calendarId = calendarId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final response = await _graphQLDataSource.request<GGetCalendarData>(request, type: 'Get Calendar', isMainError: true);
    if (response == null) {
      return null;
    }
    return CalendarResponse.fromJson(response.getCalendar.toJson());
  }

  // @override
  // Future<CalendarResponse?> createCalendarBooking(String calendarId, List<DateTime> bookingTimes) async {
  //   final request = GCreateCalendarBookingReq(
  //     (b) => b
  //       ..vars.input.calendarId = calendarId
  //       ..vars.input.bookedTimes.addAll(bookingTimes.map((e) => GDateTime(e.toUtc().toIso8601String())).toList()),
  //   );
  //   final response = await _graphQLDataSource.request<GCreateCalendarBookingData>(request, type: 'Create Calendar Booking', isMainError: true);
  //   if (response == null) {
  //     return null;
  //   }
  //   return CalendarResponse.fromJson(response.createCalendarBooking.toJson());
  // }
}
