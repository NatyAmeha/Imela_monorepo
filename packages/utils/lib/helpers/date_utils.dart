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

  static DateTimeRange? parseDateRange(List<String> stringArray, {String? format}) {
    if (stringArray.length != 2) {
      return null;
    }
    final startDate = parseDate(stringArray[0], format: format);
    final endDate = parseDate(stringArray[1], format: format);
    if (startDate == null || endDate == null) {
      return null;
    }
    return DateTimeRange(start: startDate, end: endDate);
  }

  static DateTime? parseDate(String dateString, {String? format}) {
    if (format == null) {
      return DateTime.tryParse(dateString);
    }
    return DateFormat(format).parse(dateString);
  }
}

extension DateUtils on DateTime? {
  String toFormattedString() {
    if (this == null) {
      return '';
    }
    return '${this!.day}/${this!.month}/${this!.year}';
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
