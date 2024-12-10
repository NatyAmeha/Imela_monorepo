import 'package:syncfusion_flutter_calendar/calendar.dart';

enum CalendarViewType {
  week,
  timelineWeek,
  timelineMonth,
  timelineDay,
  schedule,
}

extension CalendarViewTypeExtension on CalendarViewType {
  CalendarView get view => switch (this) {
        CalendarViewType.week => CalendarView.week,
        CalendarViewType.timelineWeek => CalendarView.timelineWeek,
        CalendarViewType.timelineMonth => CalendarView.timelineMonth,
        CalendarViewType.timelineDay => CalendarView.timelineDay,
        CalendarViewType.schedule => CalendarView.schedule,
      };
}
