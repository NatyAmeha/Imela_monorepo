import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateTimePicker extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final List<DateTime> disabledDates;
  final String? headerText;
  final Color? headerBackgroundColor;
  final TextStyle? headerTextStyle;
  final bool enablePastDates;
  final bool showTodayButton;
  final bool allowViewNavigation;
  final String? confirmText;
  final String? cancelText;
  final bool showTimePicker;
  final bool showHeader;
  final bool isHorizontalScroll;
  final ValueChanged<List<DateTime>?>? onConfirm;
  final VoidCallback? onCancel;
  final bool enableMultiSelect;
  final List<DateTime>? initialDates;
  final int? minSelections;
  final int? maxSelections;
  final Function(String)? onError;

  const DateTimePicker({
    Key? key,
    this.initialDate,
    this.initialDates,
    this.firstDate,
    this.lastDate,
    this.disabledDates = const [],
    this.headerText,
    this.headerBackgroundColor,
    this.headerTextStyle,
    this.enablePastDates = true,
    this.showTodayButton = true,
    this.allowViewNavigation = true,
    this.confirmText,
    this.cancelText,
    this.showTimePicker = false,
    this.showHeader = true,
    this.isHorizontalScroll = false,
    this.onConfirm,
    this.onCancel,
    this.enableMultiSelect = false,
    this.minSelections,
    this.maxSelections,
    this.onError,
  }) : super(key: key);

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  List<DateTime> selectedDates = [];
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.enableMultiSelect && widget.initialDates != null) {
      selectedDates = List.from(widget.initialDates!);
    } else if (widget.initialDate != null) {
      selectedDates = [widget.initialDate!];
    }
    if (widget.initialDate != null) {
      selectedTime = TimeOfDay.fromDateTime(widget.initialDate!);
    }
  }

  Future<void> _showTimePicker() async {
    if (selectedDates.isNotEmpty) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime ?? TimeOfDay.fromDateTime(selectedDates[0]),
      );
      if (pickedTime != null) {
        setState(() {
          selectedTime = pickedTime;
        });
      }
    }
  }

  List<DateTime>? _getSelectedDateTimes() {
    if (selectedDates.isEmpty) return null;
    if (!widget.showTimePicker || selectedTime == null) return selectedDates;
    
    return selectedDates.map((date) => DateTime(
      date.year,
      date.month,
      date.day,
      selectedTime!.hour,
      selectedTime!.minute,
    )).toList();
  }

  bool _validateSelections(List<DateTime> dates) {
    if (widget.minSelections != null && dates.length < widget.minSelections!) {
      widget.onError?.call('Please select at least ${widget.minSelections} dates');
      return false;
    }
    if (widget.maxSelections != null && dates.length > widget.maxSelections!) {
      widget.onError?.call('You can select maximum ${widget.maxSelections} dates');
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
            title: Text(widget.headerText ?? 'Select Date'),
            actions: [
              if (widget.showTimePicker && selectedDates.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: _showTimePicker,
                ),
              TextButton(
                onPressed: () {
                  if (!_validateSelections(selectedDates)) {
                    return;
                  }
                  final dateTimes = _getSelectedDateTimes();
                  widget.onConfirm?.call(dateTimes);
                  Navigator.of(context).pop(dateTimes);
                },
                child: Text(widget.confirmText ?? 'Confirm'),
              ),
            ],
          ),
        Expanded(
          child: SfDateRangePicker(
            selectionMode: widget.enableMultiSelect 
              ? DateRangePickerSelectionMode.multiple
              : DateRangePickerSelectionMode.single,
            initialSelectedDates: widget.enableMultiSelect ? widget.initialDates : null,
            initialSelectedDate: !widget.enableMultiSelect ? widget.initialDate : null,
            minDate: widget.firstDate ?? DateTime(2000),
            maxDate: widget.lastDate ?? DateTime(2100),
            enablePastDates: widget.enablePastDates,
            view: DateRangePickerView.month,
            navigationMode: DateRangePickerNavigationMode.snap,
            headerStyle: DateRangePickerHeaderStyle(
              textAlign: TextAlign.center,
              backgroundColor: widget.headerBackgroundColor,
              textStyle: widget.headerTextStyle,
            ),
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) async {
              if (widget.enableMultiSelect && args.value is List<DateTime>) {
                final newDates = List<DateTime>.from(args.value as List<DateTime>);
                if (widget.maxSelections != null && 
                    newDates.length > widget.maxSelections!) {
                  widget.onError?.call(
                    'You can select maximum ${widget.maxSelections} dates'
                  );
                  return;
                }
                setState(() {
                  selectedDates = newDates;
                });
              } else if (!widget.enableMultiSelect && args.value is DateTime) {
                setState(() {
                  selectedDates = [args.value as DateTime];
                  if (widget.showTimePicker && selectedTime == null) {
                    selectedTime = TimeOfDay.now();
                  }
                });
                if (widget.showTimePicker) {
                  await _showTimePicker();
                }
              }
              widget.onConfirm?.call(_getSelectedDateTimes());
            },
            navigationDirection: widget.isHorizontalScroll ? DateRangePickerNavigationDirection.horizontal : DateRangePickerNavigationDirection.vertical,
            monthViewSettings: DateRangePickerMonthViewSettings(
              blackoutDates: widget.disabledDates,
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
