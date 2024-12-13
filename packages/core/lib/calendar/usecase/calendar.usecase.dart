import 'package:imela_core/calendar/dto/calendar.response.dart';
import 'package:imela_core/calendar/repo/calendar.repository.dart';
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

}