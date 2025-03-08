import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';

part 'calendar.model.freezed.dart';
part 'calendar.model.g.dart';

enum DateSelectionType { SINGLE_DATE, MULTIPLE_DATE, DATE_RANGE, MULTIPLE_DATE_RANGE }

@freezed
class Calendar with _$Calendar {
  const Calendar._();
  const factory Calendar({
    String? id,
    List<LocalizedField>? name,
    String? productId,
    String? type,
    DateTime? fromDate,
    DateTime? toDate,
    String? businessId,
    String? branchId,
    List<DateTime>? disabledDays,
    List<DateTime>? disabledHours,
    List<CalendarOrderInfo>? orderInfo,
    String? dateSelectionType,
    List<Schedule>? bookings,
    Product? product,
  }) = _Calendar;

  factory Calendar.fromJson(Map<String, dynamic> json) => _$CalendarFromJson(json);

  List<DateTime> getDisabledDates(List<Schedule> schedules) {
    final disabledDates = [...disabledDays ?? [], ...disabledHours ?? []];

    // Add dates between fromDate and toDate where dayOfWeek is not in orderInfo
    if (fromDate != null && toDate != null) {
      final allowedDaysOfWeek = orderInfo?.map((info) => info.dayOfWeek).toList() ?? [];

      // Iterate through all dates between fromDate and toDate
      for (var date = fromDate!; date.isBefore(toDate!.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
        // Convert to 1-7 format where 7 is Sunday
        int dayOfWeek = date.weekday == 7 ? 7 : date.weekday;
        // If this day of week is not in orderInfo, add the date to disabled dates
        if (!allowedDaysOfWeek.contains(dayOfWeek)) {
          disabledDates.add(date);
        }
      }
    }

    // Group booked dates by day and check against maxOrderPerDay
    final bookedDatesFlattened = schedules.map((e) => e.bookedTimes ?? []).flatten().toList();
    final bookedDatesByDay = groupBy(bookedDatesFlattened, (DateTime date) => 
      DateTime(date.year, date.month, date.day).toString());
    for (var entry in bookedDatesByDay.entries) {
      final date = DateTime.parse(entry.key);
      final dayOfWeek = date.weekday == 7 ? 7 : date.weekday;
      final orderInfoForDay = orderInfo?.firstWhereOrNull((info) => info.dayOfWeek == dayOfWeek);
      if (orderInfoForDay != null && entry.value.length >= (orderInfoForDay.maxOrderPerDay ?? 0)) {
        disabledDates.add(date);
      }
    } 

    return disabledDates.map((date) => date as DateTime).toList();
  }
}
