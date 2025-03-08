import 'package:imela_core/calendar/dto/calendar.response.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';
import 'package:imela_data/network/graphql/calendar/__generated__/get_business_calendars.data.gql.dart';
import 'package:imela_data/network/graphql/calendar/__generated__/get_business_calendars.req.gql.dart';
import 'package:imela_data/network/graphql/calendar/__generated__/get_calendar.data.gql.dart';
import 'package:imela_data/network/graphql/calendar/__generated__/get_calendar.req.gql.dart';
import 'package:imela_data/network/graphql/calendar/__generated__/get_products_calendar.data.gql.dart';
import 'package:imela_data/network/graphql/calendar/__generated__/get_products_calendar.req.gql.dart';
import 'package:imela_data/network/graphql/calendar/__generated__/update_calendar.data.gql.dart';
import 'package:imela_data/network/graphql/calendar/__generated__/update_calendar.req.gql.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

abstract class ICalendarRepository {
  Future<CalendarResponse?> getCalendar(String calendarId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<CalendarResponse?> getProductsCalendar({required String businessId, required String branchId, required List<String> productIds, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<CalendarResponse?> getBusinessCalendars(String businessId, {String? branchId, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst});
  Future<CalendarResponse?> updateCalendar(String calendarId, {
    required List<LocalizedField> name,
    required String productId,
    required DateTime fromDate,
    required DateTime toDate,
    required List<DateTime> disabledDays,
    required List<DateTime> disabledHours,
    required List<CalendarOrderInfo> orderInfo,
  });
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

  @override
  Future<CalendarResponse?> getProductsCalendar({required String businessId, required String branchId, required List<String> productIds, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetProductsCalendarReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.branchId = branchId
        ..vars.productIds.addAll(productIds)
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final response = await _graphQLDataSource.request<GGetProductsCalendarData>(request, type: 'Get Products Calendar', isMainError: true);
    if (response == null) {
      return null;
    }
    return CalendarResponse.fromJson(response.getProductsCalendar.toJson());
  }

  @override
  Future<CalendarResponse?> getBusinessCalendars(String businessId, {String? branchId, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    final request = GGetBusinessCalendarsReq(
      (b) => b
        ..vars.businessId = businessId
        ..vars.branchId = branchId
        ..fetchPolicy = _graphQLDataSource.getFetchPolicy(fetchPolicy),
    );
    final response = await _graphQLDataSource.request<GGetBusinessCalendarsData>(request, type: 'Get Business Calendars', isMainError: true);
    if (response == null) {
      return null;
    }
    return CalendarResponse.fromJson(response.getBusinessCalendars.toJson());
  }

  @override
  Future<CalendarResponse?> updateCalendar(String calendarId, {
    required List<LocalizedField> name,
    required String productId,
    required DateTime fromDate,
    required DateTime toDate,
    required List<DateTime> disabledDays,
    required List<DateTime> disabledHours,
    required List<CalendarOrderInfo> orderInfo,
  }) async {
    final request = GUpdateCalendarReq(
      (b) => b
        ..vars.calendarId = calendarId
        ..vars.input.name.addAll(name.toLocalizedFieldInput())
        ..vars.input.productId = productId
        ..vars.input.fromDate.update((b) => GraphqlInputUtils.toDateTimeInput(b, dateTime: fromDate))
        ..vars.input.toDate.update((b) => GraphqlInputUtils.toDateTimeInput(b, dateTime: toDate))
        ..vars.input.disabledDays.addAll(disabledDays.map((d) => GDateTime(d.toIso8601String())))
        ..vars.input.disabledHours.addAll(disabledHours.map((d) => GDateTime(d.toIso8601String())))
        ..vars.input.orderInfo.addAll(orderInfo.toCalendarOrderInfoInput()),
    );
    
    final response = await _graphQLDataSource.request<GUpdateCalendarData>(
      request, 
      type: 'UPDATE_CALENDAR',
      isMainError: true,
    );
    
    return response?.updateCalendar == null
      ? null
      : CalendarResponse.fromJson(response!.updateCalendar.toJson());
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
