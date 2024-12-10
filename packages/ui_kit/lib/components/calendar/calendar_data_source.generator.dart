import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:imela_core/calendar/model/calendar_booking.model.dart';

class OrderBookingScheduleDataSource extends CalendarDataSource<CalendarBooking> {
  OrderBookingScheduleDataSource(List<CalendarBooking> bookings) {
    appointments = bookings.map((e) {
      print('booking data ${e.bookedTimes?.first.toLocal()}');
      final startTime = e.bookedTimes?.first.toLocal();
      final lastTime = e.bookedTimes?.length == 1 ? startTime?.add(const Duration(minutes: 60)) : e.bookedTimes?.last.toLocal();
      return Appointment(
        id: e.id,
        startTime: startTime ?? DateTime.now(),
        endTime: lastTime ?? DateTime.now(),
        subject: e.note?.first.value ?? '',
        notes: e.orderId,
        resourceIds: e.staffIds ?? [],

      );
    }).toList();
    // resources = [
    //   CalendarResource(
    //     id: 'doctor_one',
    //     displayName: 'Doctor One',
    //     color: Colors.red,
    //   ),
    //   CalendarResource(
    //     id: 'doctor_two',
    //     displayName: 'Doctor Two',
    //     color: Colors.blue,
    //   ),
    // ];
  }
}
