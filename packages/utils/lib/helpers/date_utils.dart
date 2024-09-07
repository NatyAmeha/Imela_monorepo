
import 'package:flutter/material.dart';

class DateHelper {
  static Duration getDateDifference({DateTime? startDate, DateTime? endDate}) {
    if (startDate == null || endDate == null) {
      return Duration.zero;
    }
    final diff =  endDate.difference(startDate);
    return diff;
  }

  static DateTimeRange? getDateRange(List<String> stringArray){
     if(stringArray.length != 2){
      return null;
     }

     final startDate= DateTime.tryParse(stringArray[0]);
     final endDate = DateTime.tryParse(stringArray[1]);
     if(startDate == null || endDate == null){
      return null;
     }
     return DateTimeRange(start: startDate, end: endDate);
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
