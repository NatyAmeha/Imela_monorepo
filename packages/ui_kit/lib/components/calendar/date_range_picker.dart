import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateRangePicker extends StatefulWidget {
  final DateTimeRange? initialDateRange;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final List<DateTime> disabledDates;
  final String? headerText;
  final Color? headerBackgroundColor;
  final TextStyle? headerTextStyle;
  final List<DateTime>? blackoutDates;
  final bool enablePastDates;
  final bool showTodayButton;
  final bool allowViewNavigation;
  final String? confirmText;
  final bool isHorizontalScroll;
  final ValueChanged<DateTimeRange?>? onConfirm;
  final VoidCallback? onCancel;
  final bool showHeader;
  final int? minDays;
  final int? maxDays;
  final Function(String)? onError;

  const DateRangePicker({
    Key? key,
    this.initialDateRange,
    this.firstDate,
    this.lastDate,
    this.disabledDates = const [],
    this.headerText,
    this.headerBackgroundColor,
    this.headerTextStyle,
    this.blackoutDates,
    this.enablePastDates = true,
    this.showTodayButton = true,
    this.allowViewNavigation = true,
    this.confirmText,
    this.onConfirm,
    this.onCancel,
    this.showHeader = true,
    this.isHorizontalScroll = false,
    this.minDays,
    this.maxDays,
    this.onError,
  }) : super(key: key);

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  DateTimeRange? selectedDateRange;

  bool _validateDateRange(DateTimeRange? range) {
    if (range == null) {
      widget.onError?.call('Please select a date range');
      return false;
    }

    final days = range.end.difference(range.start).inDays + 1;

    if (widget.minDays != null && days < widget.minDays!) {
      widget.onError?.call('Please select at least ${widget.minDays} days');
      return false;
    }

    if (widget.maxDays != null && days > widget.maxDays!) {
      widget.onError?.call('Selection cannot exceed ${widget.maxDays} days');
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showHeader)
          AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                widget.onCancel?.call();
                Navigator.of(context).pop(null);
              },
            ),
            title: Text(widget.headerText ?? 'Select Dates'),
            actions: [
              TextButton(
                onPressed: () {
                  if (!_validateDateRange(selectedDateRange)) {
                    return;
                  }
                  widget.onConfirm?.call(selectedDateRange);
                  Navigator.of(context).pop(selectedDateRange);
                },
                child: Text(widget.confirmText ?? 'Confirm'),
              ),
            ],
          ),
        Expanded(
          child: SfDateRangePicker(
            selectionMode: DateRangePickerSelectionMode.range,
            initialSelectedRange: widget.initialDateRange != null ? PickerDateRange(widget.initialDateRange!.start, widget.initialDateRange!.end) : null,
            minDate: widget.firstDate,
            maxDate: widget.lastDate,
            enablePastDates: widget.enablePastDates,
            view: DateRangePickerView.month,
            navigationMode: DateRangePickerNavigationMode.snap,
            headerStyle: DateRangePickerHeaderStyle(
              textAlign: TextAlign.center,
              backgroundColor: widget.headerBackgroundColor,
              textStyle: widget.headerTextStyle,
            ),
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              if (args.value is PickerDateRange) {
                final range = args.value as PickerDateRange;
                if (range.startDate != null && range.endDate != null) {
                  final newRange = DateTimeRange(
                    start: range.startDate!,
                    end: range.endDate!,
                  );

                  final days = newRange.end.difference(newRange.start).inDays + 1;

                  if (widget.maxDays != null && days > widget.maxDays!) {
                    widget.onError?.call(
                      'Selection cannot exceed ${widget.maxDays} days'
                    );
                    return;
                  }

                  setState(() {
                    selectedDateRange = newRange;
                  });
                  
                  if (_validateDateRange(selectedDateRange)) {
                    widget.onConfirm?.call(selectedDateRange);
                  }
                }
              }
            },
            monthCellStyle: const DateRangePickerMonthCellStyle(
              blackoutDateTextStyle: TextStyle(
                color: Colors.red,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.red,
                decorationThickness: 2,
              ),
            ),
            navigationDirection: widget.isHorizontalScroll ? DateRangePickerNavigationDirection.horizontal : DateRangePickerNavigationDirection.vertical,
            monthViewSettings: DateRangePickerMonthViewSettings(
              blackoutDates: [...widget.disabledDates, ...(widget.blackoutDates ?? [])],
              enableSwipeSelection: false,
            ),
            allowViewNavigation: widget.allowViewNavigation,
            showTodayButton: widget.showTodayButton,
          ),
        ),
      ],
    );
  }
}
