import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateHelper {
  static Duration getDateDifference({DateTime? startDate, DateTime? endDate}) {
    if (startDate == null || endDate == null) {
      return Duration.zero;
    }
    final diff = endDate.difference(startDate);
    return diff;
  }

  static DateTimeRange? getDateRange(List<String> stringArray) {
    if (stringArray.length < 2) {
      return null;
    }
    final dateRangeInfo = DateHelper.parseDateRange(stringArray, format: 'dd/MM/yyyy');

    if (dateRangeInfo == null) {
      return null;
    }
    return dateRangeInfo;
  }

  static double getNumberofDaysFromDateRange(DateTimeRange? dateRange) {
    if (dateRange == null) {
      return 0;
    }
    return dateRange.duration.inDays.toDouble();
  }

  static DateTimeRange? parseDateRange(List<String> stringArray, {String? format}) {
    if (stringArray.length != 2) {
      return null;
    }
    final startDate = DateFormat("dd/MM/yyyy").tryParse(stringArray[0]);
    final endDate = DateFormat("dd/MM/yyyy").tryParse(stringArray[1]);

    if (startDate == null || endDate == null) {
      return null;
    }
    return DateTimeRange(start: startDate, end: endDate);
  }

  static DateTime parseDate(String dateString, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).parse(dateString);
  }
}

extension DateUtils on DateTime? {
  String toFormattedString({String format = 'dd/MM/yyyy'}) {
    if (this == null) {
      return '';
    }
    if (this!.hour == 0 && this!.minute == 0) {
      return DateFormat('dd/MM/yyy').format(this!);
    }
    return DateFormat(format).format(this!);
  }
}

extension DateRangeUtils on DateTimeRange? {
  String toFormattedString() {
    if (this == null) {
      return '';
    }
    return '${this!.start.toFormattedString()} - ${this!.end.toFormattedString()}';
  }
}
