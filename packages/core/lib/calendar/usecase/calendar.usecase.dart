import 'package:imela_core/calendar/dto/calendar.response.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/calendar/repo/calendar.repository.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:injectable/injectable.dart';

@injectable
class CalendarUsecase {
  final ICalendarRepository _calendarRepository;

  const CalendarUsecase(
    @Named(CalendarRepository.injectName) this._calendarRepository,
  );


  Future<CalendarResponse?> getCalendar(String calendarId, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _calendarRepository.getCalendar(calendarId);
    if (!(result?.success ?? false) && fetchPolicy == ApiDataFetchPolicy.cacheFirst) {
      result = await _calendarRepository.getCalendar(calendarId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<CalendarResponse?> getProductsCalendar(String businessId, String branchId, List<String> productIds, {ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _calendarRepository.getProductsCalendar(businessId: businessId, branchId: branchId, productIds: productIds, fetchPolicy: fetchPolicy);
    if (!(result?.success ?? false)) {
      result = await _calendarRepository.getProductsCalendar(businessId: businessId, branchId: branchId, productIds: productIds, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<CalendarResponse?> getBusinessCalendars(String businessId, {String? branchId, ApiDataFetchPolicy fetchPolicy = ApiDataFetchPolicy.cacheFirst}) async {
    var result = await _calendarRepository.getBusinessCalendars(businessId, branchId: branchId, fetchPolicy: fetchPolicy);
    if (!(result?.success ?? false)) {
      result = await _calendarRepository.getBusinessCalendars(businessId, branchId: branchId, fetchPolicy: ApiDataFetchPolicy.networkOnly);
    }
    return result;
  }

  Future<CalendarResponse?> updateCalendar(Calendar calendar) async {
    // Convert calendar model to required inputs
    
    return await _calendarRepository.updateCalendar(
      calendar.id!,
      name: calendar.name ?? [],
      productId: calendar.productId!,
      fromDate: calendar.fromDate!,
      toDate: calendar.toDate!, 
      disabledDays: calendar.disabledDays ?? [],
      disabledHours: calendar.disabledHours ?? [],
      orderInfo: calendar.orderInfo ?? [],
    );
  }
}

class CalendarOrderInfoInput {
  final int dayOfWeek;
  final int maxOrderPerDay;
  final int maxOrderPerHour;

  CalendarOrderInfoInput({
    required this.dayOfWeek,
    required this.maxOrderPerDay,
    required this.maxOrderPerHour,
  });
}