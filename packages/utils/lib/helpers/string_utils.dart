import 'package:flutter/material.dart';

extension StringUtilsExtension on String? {
  DateTime? toDateTime() {
    if (this == null) {
      null;
    }
    return DateTime.parse(this!);
  }
}

extension StringArrayUtilsExtension on List<String>? {
  String toCommaSeparatedString() {
    if (this == null) {
      return '';
    }
    return this!.join(', ');
  }

  List<DateTime>? toDateTimeList() {
    if (this == null) {
      return null;
    }
    return this!.map((e) => DateTime.parse(e)).toList();
  }

  DateTimeRange? toDateRange() {
    if (this == null || this!.length != 2) {
      return null;
    }
    return DateTimeRange(start: DateTime.parse(this![0]), end: DateTime.parse(this![1]));
  }
}
