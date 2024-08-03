import 'package:flutter/material.dart';

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