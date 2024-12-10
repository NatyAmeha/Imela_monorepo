import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';
import 'package:imela_core/product/model/product.model.dart';

part 'calendar.model.freezed.dart';
part 'calendar.model.g.dart';

@freezed
class Calendar with _$Calendar {
  const Calendar._();
  const factory Calendar({
    String? id,
    String? productId,
    DateTime? fromDate,
    DateTime? toDate,
    List<DateTime>? disabledDays,
    List<DateTime>? disabledHours,
    List<CalendarOrderInfo>? orderInfo,
    List<CalendarBooking>? bookings,
    Product? product,
  }) = _Calendar;

  factory Calendar.fromJson(Map<String, dynamic> json) => _$CalendarFromJson(json);
}
