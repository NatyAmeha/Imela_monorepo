import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/calendar/model/calendar.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';

part 'calendar_booking.model.freezed.dart';
part 'calendar_booking.model.g.dart';

@freezed
class CalendarBooking with _$CalendarBooking {
  const CalendarBooking._();
  const factory CalendarBooking({
    String? id,
    String? calendarId,
    String? orderId,
    String? productId,
    List<String>? staffIds,
    List<LocalizedField>? note,
    List<DateTime>? bookedTimes,
    @Default(false) bool isRange,
    DateTime? createdAt,
    DateTime? updatedAt,
    Calendar? calendar,
  }) = _CalendarBooking;

  factory CalendarBooking.fromJson(Map<String, dynamic> json) => _$CalendarBookingFromJson(json);
}

@freezed
class CalendarOrderInfo with _$CalendarOrderInfo {
  const CalendarOrderInfo._();
  const factory CalendarOrderInfo({
    String? id,
    int? dayOfWeek,
    int? maxOrderPerDay,
    int? maxOrderPerHour,
  }) = _CalendarOrderInfo;

  factory CalendarOrderInfo.fromJson(Map<String, dynamic> json) => _$CalendarOrderInfoFromJson(json);
}

extension CalendarBookingListExtensions on List<CalendarBooking> {
  List<DateTime> getDisabledDates(Calendar calendar) {
    final disabledDates = <DateTime>[];

    // Iterate over each booking
    for (var booking in this) {
      if (booking.bookedTimes == null) continue;

      // Check each booked time
      for (var bookedTime in booking.bookedTimes!) {
        final dayOfWeek = bookedTime.weekday;
        print('dayOfWeek $dayOfWeek');
        final orderInfo = calendar.orderInfo?.firstWhereOrNull((info) => info.dayOfWeek == dayOfWeek);

        if (orderInfo != null) {
          // Count bookings for the specific day and hour
          final bookingsOnDay = where((b) => b.bookedTimes?.any((bt) => bt.day == bookedTime.day) ?? false).length;
          final bookingsOnHour = where((b) => b.bookedTimes?.any((bt) => bt.hour == bookedTime.hour) ?? false).length;

          // Check against maxOrderPerDay and maxOrderPerHour
          if (bookingsOnDay >= (orderInfo.maxOrderPerDay ?? 0) || bookingsOnHour >= (orderInfo.maxOrderPerHour ?? 0)) {
            disabledDates.add(bookedTime);
          }
        }
      }
    }

    return disabledDates;
  }
}
