import 'package:flutter/material.dart';

class DateHelper {
  static Duration getDateDifference({DateTime? startDate, DateTime? endDate}) {
    if (startDate == null || endDate == null) {
      return Duration.zero;
    }
    return endDate.difference(startDate);
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
