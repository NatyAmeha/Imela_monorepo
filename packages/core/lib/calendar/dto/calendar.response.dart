import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';

part 'calendar.response.freezed.dart';
part 'calendar.response.g.dart';

@freezed
class CalendarResponse with _$CalendarResponse {
  const CalendarResponse._();
  const factory CalendarResponse({
    bool? success,
    String? message,
    Calendar? calendar,
    List<Calendar>? calendars,
    Schedule? calendarBooking,
    List<DateTime>? disabledDatesForBooking,
  }) = _CalendarResponse;

  factory CalendarResponse.fromJson(Map<String, dynamic> json) => _$CalendarResponseFromJson(json);

  List<DateTime> getDisabledDatesForBooking() {
    return [...(disabledDatesForBooking ?? []), ...(calendar?.disabledDays ?? [])];
  }
}
